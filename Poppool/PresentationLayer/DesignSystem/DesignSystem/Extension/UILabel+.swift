import UIKit

public extension UILabel {
    @available(*, deprecated, message: "직접 속성을 넣는 방법 대신 타이포시스템을 이용하는 `updateText(to:)`또는 `setText(to:with:)`을 이용해주세요")
    func setLineHeightText(text: String?, font: UIFont?, lineHeight: CGFloat = 1.3) {
        guard let text = text, let font = font else { return }

        guard let parseResult = parseToPPFontStyle(text: text, font: font) else { return }

        self.setText(to: text, with: PPFontStyle(rawValue: parseResult) ?? .KOb32)
//
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineBreakMode = .byTruncatingTail
//        paragraphStyle.lineHeightMultiple = lineHeight
//        self.attributedText = NSMutableAttributedString(
//            string: text,
//            attributes: [
//                .paragraphStyle: paragraphStyle,
//                .font: font
//            ]
//        )
    }

    /// 기존 attributedText 속성을 유지하며 텍스트만 교체합니다.
    func updateText(to text: String?) {
        guard let current = self.attributedText, current.length > 0 else {
            self.text = text
            return
        }
        let attributes = current.attributes(at: 0, effectiveRange: nil)
        self.attributedText = NSAttributedString(string: text ?? " ", attributes: attributes)
    }

    /// 기존 attributed 속성을 유지하면서 텍스트 컬러만 변경합니다.
    func updateTextColor(to color: UIColor?) {
        if let current = self.attributedText, current.length > 0 {
            let mutable = NSMutableAttributedString(attributedString: current)
            let fullRange = NSRange(location: 0, length: mutable.length)
            mutable.addAttribute(.foregroundColor, value: color ?? .g1000, range: fullRange)
            self.attributedText = mutable
        } else {
            self.textColor = color
        }
    }

    /// Style이 포함된 텍스트를 적용합니다.
    func setText(to text: String?, with style: PPFontStyle) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.lineHeightMultiple = style.lineHeightMultiple
        paragraphStyle.maximumLineHeight = style.lineHeight
        paragraphStyle.minimumLineHeight = style.lineHeight

        self.attributedText = NSMutableAttributedString(
            string: text ?? " ",
            attributes: [
                .font: UIFont.PPFont(style: style),
                .paragraphStyle: paragraphStyle,
                .baselineOffset: style.baseLineOffset
            ]
        )
    }
}

private extension UILabel {
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
