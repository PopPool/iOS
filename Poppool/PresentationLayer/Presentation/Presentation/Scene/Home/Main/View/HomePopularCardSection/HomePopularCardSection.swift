//
//  HomePopularCardSection.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/30/24.
//

import UIKit

import RxSwift

struct HomePopularCardSection: Sectionable {

    var currentPage: PublishSubject<Int> = .init()

    typealias CellType = HomePopularCardSectionCell

    var inputDataList: [CellType.Input]

    var supplementaryItems: [any SectionSupplementaryItemable]?

    var decorationItems: [any SectionDecorationItemable]?

    func setSection(section: Int, env: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(232),
            heightDimension: .absolute(332)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(232),
            heightDimension: .absolute(332)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        // 섹션 생성
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
        section.interGroupSpacing = 16
        section.orthogonalScrollingBehavior = .continuous

        return section
    }
}
