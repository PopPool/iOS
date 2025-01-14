//
//  IntroState.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/11/25.
//

import UIKit

enum IntroState {
    case empty
    case emptyActive
    case validate
    case validateActive
    case longLength
    case longLengthActive
    
    var borderColor: UIColor? {
        switch self {
        case .empty, .validate:
            return .g200
        case .emptyActive, .validateActive:
            return .g1000
        case .longLength, .longLengthActive:
            return .re500
        }
    }
    
    var description: String? {
        switch self {
        case .empty, .emptyActive, .validate, .validateActive:
            return nil
        case .longLength, .longLengthActive:
            return "최대 30글자까지 입력해주세요"
        }
    }
    
    var textColor: UIColor? {
        switch self {
        case .empty, .emptyActive, .validate, .validateActive:
            return .g500
        case .longLength, .longLengthActive:
            return .re500
        }
    }
    
    var textFieldTextColor: UIColor? {
        switch self {
        case .longLength, .longLengthActive:
            return .re500
        default:
            return .g1000
        }
    }
    
    var placeHolderIsHidden: Bool {
        switch self {
        case .empty, .emptyActive:
            return false
        default:
            return true
        }
    }
}
