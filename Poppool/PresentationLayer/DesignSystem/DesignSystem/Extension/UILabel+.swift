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
}
