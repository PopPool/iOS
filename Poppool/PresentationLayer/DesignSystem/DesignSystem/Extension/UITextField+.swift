import UIKit

public extension UITextField {
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
