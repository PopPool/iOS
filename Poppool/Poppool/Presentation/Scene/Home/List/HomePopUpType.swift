//
//  HomePopUpType.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/2/24.
//

import Foundation

enum HomePopUpType {
    case curation
    case new
    case popular
    
    var title: String {
        switch self {
        case .curation:
            return "큐레이션 팝업 전체보기"
        case .new:
            return "신규 팝업 전체보기"
        case .popular:
            return "인기 팝업 전체보기"
        }
    }
    
    var path: String {
        switch self {
        case .curation:
            return "custom"
        case .new:
            return "new"
        case .popular:
            return "popular"
        }
    }
}
