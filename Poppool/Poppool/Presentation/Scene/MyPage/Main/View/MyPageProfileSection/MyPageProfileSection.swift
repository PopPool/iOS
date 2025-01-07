//
//  MyPageProfileSection.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/31/24.
//

import UIKit

import RxSwift

struct MyPageProfileSection: Sectionable {
    
    var currentPage: PublishSubject<Int> = .init()
    
    typealias CellType = MyPageProfileSectionCell
    
    var inputDataList: [CellType.Input]
    
    var supplementaryItems: [any SectionSupplementaryItemable]?
    
    var decorationItems: [any SectionDecorationItemable]?
    
    func setSection(section: Int, env: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1000)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(1000)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        // 섹션 생성
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
}
