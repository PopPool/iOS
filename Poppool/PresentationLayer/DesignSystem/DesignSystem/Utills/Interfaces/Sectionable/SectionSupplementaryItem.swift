import UIKit

import Infrastructure

/// `SectionSupplementaryItem` 구조체는 섹션에 추가될 Supplementary View에 대한 정보를 정의합니다.
/// 제네릭 타입 `View`는 `UICollectionReusableView`와 `InOutputable` 프로토콜을 준수해야 합니다.
public struct SectionSupplementaryItem<View: UICollectionReusableView & Inputable>: SectionSupplementaryItemable {
    public typealias ReusableView = View
    public var widthDimension: NSCollectionLayoutDimension
    public var heightDimension: NSCollectionLayoutDimension
    public var elementKind: String
    public var alignment: NSRectAlignment
    public var reusableView: ReusableView
    public var viewInput: ReusableView.Input
}

/// `SectionSupplementaryItemable` 프로토콜은 Supplementary View에 대한 인터페이스를 정의합니다.
/// 해당 프로토콜을 준수하는 타입은 Supplementary View를 설정하고 반환하는 기능을 가져야 합니다.
public protocol SectionSupplementaryItemable {

    /// Supplementary View의 타입을 정의합니다. 이 뷰는 `UICollectionReusableView`와 `Inputable` 프로토콜을 준수해야 합니다.
    associatedtype ReusableView: UICollectionReusableView, Inputable

    /// Supplementary View의 너비를 정의합니다.
    var widthDimension: NSCollectionLayoutDimension { get set }

    /// Supplementary View의 높이를 정의합니다.
    var heightDimension: NSCollectionLayoutDimension { get set }

    /// Supplementary View의 종류를 나타내는 문자열입니다.
    var elementKind: String { get set }

    /// Supplementary View의 정렬 방법을 정의합니다.
    var alignment: NSRectAlignment { get set }

    /// Supplementary View의 인스턴스입니다.
    var reusableView: ReusableView { get set }

    /// Supplementary View에 주입될 데이터입니다.
    var viewInput: ReusableView.Input { get set }
}

extension SectionSupplementaryItemable {

    /// 주어진 인덱스 경로에 해당하는 Supplementary View를 생성하고 반환합니다.
    ///
    /// - Parameters:
    ///   - collectionView: 컬렉션 뷰
    ///   - kind: Supplementary View의 종류
    ///   - indexPath: Supplementary View의 인덱스 경로
    /// - Returns: 설정된 Supplementary View를 반환합니다.
    func getItem(
        collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {

        collectionView.register(
            ReusableView.self,
            forSupplementaryViewOfKind: kind,
            withReuseIdentifier: reusableView.identifiers
        )

        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: reusableView.identifiers,
            for: indexPath
        ) as? ReusableView else {
            Logger.log(
                message: "ReusableView Error",
                category: .error,
                fileName: #file,
                line: #line
            )
            return UICollectionReusableView()
        }
        view.injection(with: viewInput)
        return view
    }
}
