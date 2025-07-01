import UIKit

public class PPLabel: UILabel {

    public init(
        style: UIFont.FontStyle,
        fontSize: CGFloat,
        text: String = "",
        lineHeight: CGFloat = 1.2
    ) {
        super.init(frame: .zero)
        self.font = .korFont(style: style, size: fontSize)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineHeight
        self.attributedText = NSMutableAttributedString(
            string: text,
            attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle]
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
