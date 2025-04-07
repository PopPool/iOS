//
//  PPButton.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/25/24.
//

import UIKit

class PPButton: UIButton {

    enum ButtonStyle {
        case primary
        case secondary
        case tertiary
        case kakao
        case apple

        var backgroundColor: UIColor {
            switch self {
            case .primary:
                return .blu500
            case .secondary:
                return .g50
            case .tertiary:
                return .blu500
            case .kakao:
                return .init(hexCode: "#F8E049")
            case .apple:
                return .g900
            }
        }

        var textColor: UIColor {
            switch self {
            case .primary:
                return .w100
            case .secondary:
                return .blu500
            case .tertiary:
                return .blu500
            case .kakao:
                return .g1000
            case .apple:
                return .w100
            }
        }

        var disabledBackgroundColor: UIColor {
            switch self {
            case .primary:
                return .g100
            case .secondary:
                return .g50
            case .tertiary, .apple, .kakao:
                return .blu500
            }
        }

        var disabledTextColor: UIColor {
            switch self {
            case .primary:
                return .g400
            case .secondary:
                return .g50
            case .tertiary, .apple, .kakao:
                return .blu500
            }
        }
    }

    init(
        style: ButtonStyle,
        text: String,
        disabledText: String = "",
        font: UIFont? = .korFont(style: .medium, size: 16),
        cornerRadius: CGFloat = 4
    ) {
        super.init(frame: .zero)

        self.setTitle(text, for: .normal)
        self.setTitle(disabledText, for: .disabled)

        self.setTitleColor(style.textColor, for: .normal)
        self.setTitleColor(style.disabledTextColor, for: .disabled)

        self.setBackgroundColor(style.backgroundColor, for: .normal)
        self.setBackgroundColor(style.disabledBackgroundColor, for: .disabled)

        self.titleLabel?.font = font
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 버튼 배경색 설정
    /// - Parameters:
    ///   - color: 색상
    ///   - state: 상태
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))

        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.setBackgroundImage(backgroundImage, for: state)
    }
}
