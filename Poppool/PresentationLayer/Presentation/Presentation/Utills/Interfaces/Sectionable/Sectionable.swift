import UIKit

import Infrastructure

import RxSwift
import SnapKit

/// `Sectionable` 프로토콜은 컬렉션 뷰의 섹션 및 셀을 설정하기 위한 인터페이스를 정의합니다.
/// 해당 프로토콜은 제네릭 타입 `CellType`을 사용하여 유연하게 컬렉션 뷰 셀을 처리할 수 있습니다.
protocol Sectionable {

    /// 컬렉션 뷰 셀의 타입을 정의합니다. 이 셀은 `UICollectionViewCell`과 `Inputable` 프로토콜을 준수해야 합니다.
    associatedtype CellType: UICollectionViewCell, Inputable

    /// 셀에 입력될 데이터의 리스트를 정의합니다.
    var inputDataList: [CellType.Input] { get set }

    /// 섹션에 추가될 Supplementary View의 리스트를 정의합니다.
    var supplementaryItems: [any SectionSupplementaryItemable]? { get set }

    /// 섹션에 추가될 Decoration View의 리스트를 정의합니다.
    var decorationItems: [any SectionDecorationItemable]? { get set }

    /// 섹션의 페이지
    var currentPage: PublishSubject<Int> { get set }

    /// 주어진 섹션 인덱스와 레이아웃 환경을 바탕으로 `NSCollectionLayoutSection`을 반환합니다.
    ///
    /// - Parameters:
    ///   - section: 섹션의 인덱스
    ///   - env: 레이아웃 환경
    /// - Returns: 섹션 레이아웃을 반환합니다.
    func getSection(section: Int, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection

    /// 섹션의 레이아웃을 설정합니다.
    ///
    /// - Parameters:
    ///   - section: 섹션의 인덱스
    ///   - env: 레이아웃 환경
    /// - Returns: 설정된 섹션 레이아웃을 반환합니다.
    func setSection(section: Int, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection

    /// 주어진 인덱스 경로에 해당하는 셀을 반환합니다.
    ///
    /// - Parameters:
    ///   - collectionView: 컬렉션 뷰
    ///   - indexPath: 셀의 인덱스 경로
    /// - Returns: 셀을 반환합니다.
    func getCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell

    /// Supplementary View를 반환합니다.
    ///
    /// - Parameters:
    ///   - collectionView: 컬렉션 뷰
    ///   - kind: Supplementary View의 종류
    ///   - indexPath: Supplementary View의 인덱스 경로
    /// - Returns: Supplementary View를 반환합니다.
    func getSupplementaryItem(
        collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView
}

extension Sectionable {

    /// `setSection` 메서드를 호출하여 섹션 레이아웃을 설정하고, Supplementary View를 추가합니다.
    ///
    /// - Parameters:
    ///   - section: 섹션의 인덱스
    ///   - env: 레이아웃 환경
    /// - Returns: 설정된 섹션 레이아웃을 반환합니다.
    func getSection(section: Int, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {

        let section = setSection(section: section, env: env)
        section.visibleItemsInvalidationHandler = { _, contentOffset, environment in
            let bannerIndex = Int(max(0, round(contentOffset.x / environment.container.contentSize.width)))  // 음수가 되는 것을 방지하기 위해 max 사용
            currentPage.onNext(bannerIndex)
        }

        if let supplementaryItems = supplementaryItems {

            let items = supplementaryItems.map {

                let size = NSCollectionLayoutSize(
                    widthDimension: $0.widthDimension,
                    heightDimension: $0.heightDimension
                )

                return NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: size,
                    elementKind: $0.elementKind,
                    alignment: $0.alignment
                )
            }
            section.boundarySupplementaryItems = items
        }

        if let decorationItems = decorationItems {

            let items = decorationItems.map {

                return NSCollectionLayoutDecorationItem.background(
                    elementKind: $0.elementKind
                )
            }
            section.decorationItems = items
        }
        return section
    }

    /// `inputDataList`의 비어 있지 않은지를 반환합니다.
    var isEmpty: Bool {
        return inputDataList.isEmpty
    }

    /// `inputDataList`의 아이템 수를 반환합니다.
    var dataCount: Int {
        return inputDataList.count

    }
    /// 주어진 인덱스 경로에 해당하는 셀을 생성하고 반환합니다.
    ///
    /// - Parameters:
    ///   - collectionView: 컬렉션 뷰
    ///   - indexPath: 셀의 인덱스 경로
    /// - Returns: 설정된 셀을 반환합니다.
    func getCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellType.identifiers,
            for: indexPath
        ) as? CellType else {
            Logger.log(
                message: "dequeueReusableCell Fail",
                category: .error,
                fileName: #file,
                line: #line
            )
            return UICollectionViewCell()
        }
        let input = inputDataList[indexPath.row]
        cell.injection(with: input)
        return cell
    }

    /// 주어진 Supplementary View를 생성하고 반환합니다.
    ///
    /// - Parameters:
    ///   - collectionView: 컬렉션 뷰
    ///   - kind: Supplementary View의 종류
    ///   - indexPath: Supplementary View의 인덱스 경로
    /// - Returns: 설정된 Supplementary View를 반환합니다.
    func getSupplementaryItem(
        collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {

        guard let item = supplementaryItems?.filter({ $0.elementKind == kind }).first else {
            Logger.log(
                message: "ReusableView Not Register",
                category: .error,
                fileName: #file,
                line: #line
            )
            fatalError()
        }

        return item.getItem(collectionView: collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
}
