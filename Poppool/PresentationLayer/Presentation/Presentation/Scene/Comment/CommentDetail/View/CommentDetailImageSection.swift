//
//  CommentDetailImageSection.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/25/24.
//

import UIKit

import RxSwift

struct CommentDetailImageSection: Sectionable {

    var currentPage: PublishSubject<Int> = .init()

    typealias CellType = DetailCommentImageCell

    var inputDataList: [CellType.Input]

    var supplementaryItems: [any SectionSupplementaryItemable]?

    var decorationItems: [any SectionDecorationItemable]?

    func setSection(section: Int, env: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(80),
            heightDimension: .absolute(80)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(80),
            heightDimension: .absolute(80)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        // 섹션 생성
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 0)
        section.interGroupSpacing = 8
        section.orthogonalScrollingBehavior = .continuous
        return section
    }
}
