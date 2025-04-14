//
//  HomeTitleSection.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/30/24.
//

import UIKit

import RxSwift

struct HomeTitleSection: Sectionable {

    var currentPage: PublishSubject<Int> = .init()

    typealias CellType = HomeTitleSectionCell

    var inputDataList: [CellType.Input]

    var supplementaryItems: [any SectionSupplementaryItemable]?

    var decorationItems: [any SectionDecorationItemable]?

    func setSection(section: Int, env: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        // 섹션 생성
//        section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 16)

        return NSCollectionLayoutSection(group: group)
    }
}
