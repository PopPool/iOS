import UIKit

public extension UILabel {
    func setLineHeightText(text: String?, font: UIFont?, lineHeight: CGFloat = 1.3) {
        guard let text = text, let font = font else { return }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.lineHeightMultiple = lineHeight
        self.attributedText = NSMutableAttributedString(
            string: text,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: font
            ]
        )
    }

    /// 기존 attributedText 속성을 유지하며 텍스트만 교체합니다.
    func updateText(to text: String) {
        guard let current = self.attributedText, current.length > 0 else {
            self.text = text
            return
        }
        let attributes = current.attributes(at: 0, effectiveRange: nil)
        self.attributedText = NSAttributedString(string: text, attributes: attributes)
    }

    /// Style이 포함된 텍스트를 적용합니다.
    func setText(to text: String, with style: PPFontStyle) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = style.lineHeightMultiple
        paragraphStyle.maximumLineHeight = style.lineHeight
        paragraphStyle.minimumLineHeight = style.lineHeight

        self.attributedText = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.PPFont(style: style),
                .paragraphStyle: paragraphStyle,
                .baselineOffset: style.baseLineOffset
            ]
        )
    }
}
