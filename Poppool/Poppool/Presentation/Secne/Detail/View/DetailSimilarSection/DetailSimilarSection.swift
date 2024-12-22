//
//  DetailSimilarSection.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/19/24.
//

import UIKit

import RxSwift

struct DetailSimilarSection: Sectionable {
    
    var currentPage: PublishSubject<Int> = .init()
    
    typealias CellType = DetailSimilarSectionCell
    
    var inputDataList: [CellType.Input]
    
    var supplementaryItems: [any SectionSupplementaryItemable]?
    
    var decorationItems: [any SectionDecorationItemable]?
    
    func setSection(section: Int, env: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(163),
            heightDimension: .absolute(254)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(163),
            heightDimension: .absolute(254)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        // 섹션 생성
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 0)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 12
        
        return section
    }
}
