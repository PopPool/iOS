import UIKit

public class PPLabel: UILabel {

    @available(*, deprecated, renamed: "init(text:style:)",message: "타이포를 직접 지정하는 대신 PPFontStyle을 이용하세요")
    public init(
        style: UIFont.FontStyle = .regular,
        fontSize: CGFloat = 12,
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

    public init(
        text: String = " ", // 값이 없으면 Attribute가 적용이 안돼서 기본값은 공백
        style: PPFontStyle
    ) {
        super.init(frame: .zero)
        self.setText(to: text, with: style)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
