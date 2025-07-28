import UIKit

public extension UITextField {
    @available(*, deprecated, message: "직접 속성을 넣는 방법 대신 타이포시스템을 이용하는 `setPlaceholder(text:color:style:)`을 이용해주세요")
    func setPlaceholder(text: String, color: UIColor, font: UIFont) {
        self.attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [.foregroundColor: color, .font: font]
        )
    }

    func setPlaceholder(text: String, color: UIColor, style: PPFontStyle) {
        let paragraphStyle = NSMutableParagraphStyle()
        let font = UIFont.PPFont(style: style)

        paragraphStyle.lineHeightMultiple = style.lineHeightMultiple
        paragraphStyle.maximumLineHeight = style.lineHeight
        paragraphStyle.minimumLineHeight = style.lineHeight

        self.attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle,
                .baselineOffset: style.baseLineOffset,
                .font: font
            ]
        )
    }
}
