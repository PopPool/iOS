//
//  InstaGuideChildSection.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/15/24.
//

import UIKit

import RxSwift

struct InstaGuideChildSection: Sectionable {

    var currentPage: PublishSubject<Int> = .init()

    typealias CellType = InstaGuideChildSectionCell

    var inputDataList: [CellType.Input]

    var supplementaryItems: [any SectionSupplementaryItemable]?

    var decorationItems: [any SectionDecorationItemable]?

    func setSection(section: Int, env: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(500)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(500)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        // 섹션 생성
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .paging
        return section
    }
}
