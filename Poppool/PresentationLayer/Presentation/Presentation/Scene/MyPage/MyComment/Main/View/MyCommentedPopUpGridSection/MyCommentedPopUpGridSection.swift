import UIKit

import DesignSystem

import RxSwift

struct MyCommentedPopUpGridSection: Sectionable {

    var currentPage: PublishSubject<Int> = .init()

    typealias CellType = MyCommentedPopUpGridSectionCell

    var inputDataList: [CellType.Input]

    var supplementaryItems: [any SectionSupplementaryItemable]?

    var decorationItems: [any SectionDecorationItemable]?

    func setSection(section: Int, env: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute((UIScreen.main.bounds.width - 40 - 8) / 2),
            heightDimension: .estimated(1000)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1000)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(8)

        // 섹션 생성
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
        section.interGroupSpacing = 16
        return section
    }
}
