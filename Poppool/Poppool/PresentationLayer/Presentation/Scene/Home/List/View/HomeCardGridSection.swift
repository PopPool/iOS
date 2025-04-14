//
//  HomeCardGridSection.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/3/24.
//

import UIKit

import RxSwift

struct HomeCardGridSection: Sectionable {

    var currentPage: PublishSubject<Int> = .init()

    typealias CellType = HomeCardSectionCell

    var inputDataList: [CellType.Input]

    var supplementaryItems: [any SectionSupplementaryItemable]?

    var decorationItems: [any SectionDecorationItemable]?

    func setSection(section: Int, env: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute((UIScreen.main.bounds.width - 40 - 16) / 2),
            heightDimension: .estimated(249)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(249)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(16)
        // 섹션 생성
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
        section.interGroupSpacing = 24
        return section
    }
}
