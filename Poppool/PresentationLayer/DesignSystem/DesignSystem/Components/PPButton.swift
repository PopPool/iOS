import UIKit

import Infrastructure

public class PPButton: UIButton {

    public enum ButtonStyle {
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

    public init(
        buttonStyle: ButtonStyle,
        fontStyle: PPFontStyle = .KOm16,
        text: String,
        disabledText: String = " ",
        cornerRadius: CGFloat = 4
    ) {
        super.init(frame: .zero)

        self.setTitleColor(buttonStyle.textColor, for: .normal)
        self.setTitleColor(buttonStyle.disabledTextColor, for: .disabled)

        self.setBackgroundColor(buttonStyle.backgroundColor, for: .normal)
        self.setBackgroundColor(buttonStyle.disabledBackgroundColor, for: .disabled)

        self.setText(to: text, with: fontStyle, for: .normal)
        self.setText(to: disabledText, with: fontStyle, for: .disabled)

        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
    }

    @available(*, deprecated, message: "PPFontStyle로 파싱하는 init을 사용해주세요.")
    public init(
        style: ButtonStyle,
        text: String,
        disabledText: String = "",
        font: UIFont? = .korFont(style: .medium, size: 16),
        cornerRadius: CGFloat = 4
    ) {
        super.init(frame: .zero)

        guard let parseResult = parseToPPFontStyle(text: text, font: font),
              let PPFontStyle = PPFontStyle(rawValue: parseResult)
        else {
            Logger.log("PPFontStyle로 파싱할 수 없는 폰트입니다.", category: .error)
            return
        }

        self.setTitleColor(style.textColor, for: .normal)
        self.setTitleColor(style.disabledTextColor, for: .disabled)

        self.setBackgroundColor(style.backgroundColor, for: .normal)
        self.setBackgroundColor(style.disabledBackgroundColor, for: .disabled)

        self.setText(to: text, with: PPFontStyle, for: .normal)
        self.setText(to: disabledText, with: PPFontStyle, for: .disabled)

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
    public func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))

        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.setBackgroundImage(backgroundImage, for: state)
    }
}

private extension PPButton {
    func parseToPPFontStyle(text: String?, font: UIFont?) -> String? {
        guard let font = font else { return nil }

        var result = ""

        let splitResult = font.fontName.split(separator: "-")
        splitResult[0] == "Poppins" ? result.append("EN") : result.append("KO")

        switch splitResult[1] {
        case "Light": result.append("l")
        case "Regular": result.append("r")
        case "Medium": result.append("m")
        case "Bold": result.append("b")
        default: return nil
        }

        result.append("\(Int(font.pointSize))")

        return result
    }
}
