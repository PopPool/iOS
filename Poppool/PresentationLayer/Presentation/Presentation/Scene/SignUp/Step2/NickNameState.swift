//
//  NickNameState.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/25/24.
//

import UIKit

enum NickNameState {
    case empty
    case emptyActive
    case length
    case lengthActive
    case korAndEng
    case korAndEngActive
    case duplicated
    case duplicatedActive
    case validate
    case validateActive
    case check
    case checkActive
    case myNickName
    case myNickNameActive
    case shortLength
    case shortLengthActive
    case longLength
    case longLengthActive

    var borderColor: UIColor? {
        switch self {
        case .empty, .duplicated, .validate, .check, .myNickName:
            return .g200
        case .emptyActive, .duplicatedActive, .validateActive, .checkActive, .myNickNameActive:
            return .g1000
        case .length, .lengthActive, .korAndEng, .korAndEngActive, .shortLength, .shortLengthActive, .longLength, .longLengthActive:
            return .re500
        }
    }

    var description: String? {
        switch self {
        case .empty, .emptyActive:
            return "한글, 영문만 입력할 수 있어요"
        case .length, .lengthActive:
            return "2글자 이상 입력해주세요\n10글자까지만 입력할 수 있어요"
        case .shortLength, .shortLengthActive:
            return "2글자 이상 입력해주세요"
        case .longLength, .longLengthActive:
            return "10글자까지만 입력할 수 있어요"
        case .korAndEng, .korAndEngActive:
            return "한글, 영문으로만 입력해주세요"
        case .duplicated, .duplicatedActive:
            return "이미 사용되고 있는 별명이에요"
        case .validate, .validateActive:
            return "사용 가능한 별명이에요"
        case .check, .checkActive:
            return "중복체크를 진행해주세요"
        case .myNickNameActive:
            return "이미 설정된 닉네임입니다"
        case .myNickName:
            return nil
        }
    }

    var textColor: UIColor? {
        switch self {
        case .empty, .emptyActive, .check, .checkActive:
            return .g500
        case .length, .lengthActive, .korAndEng, .korAndEngActive, .duplicated, .duplicatedActive, .shortLength, .shortLengthActive, .longLength, .longLengthActive:
            return .re500
        case .validate, .validateActive, .myNickName, .myNickNameActive:
            return .blu500
        }
    }

    var textFieldTextColor: UIColor? {
        switch self {
        case .length, .lengthActive, .korAndEng, .korAndEngActive, .duplicated, .duplicatedActive, .shortLength, .shortLengthActive, .longLength, .longLengthActive:
            return .re500
        default:
            return .g1000
        }
    }

    var isHiddenClearButton: Bool {
        switch self {
        case .lengthActive, .korAndEngActive, .duplicatedActive, .validateActive, .checkActive, .myNickNameActive, .shortLengthActive, .longLengthActive:
            return false
        default:
            return true
        }
    }

    var isHiddenCheckButton: Bool {
        switch self {
        case .length, .korAndEng, .duplicated, .validate, .check, .shortLength, .longLength, .myNickName:
            return false
        default:
            return true
        }
    }

    var isShakeAnimation: Bool {
        switch self {
        case .lengthActive, .korAndEngActive, .duplicatedActive:
            return true
        default:
            return false
        }
    }

    var duplicatedCheckButtonIsEnabled: Bool {
        switch self {
        case .check, .checkActive:
            return true
        default:
            return false
        }
    }
}
