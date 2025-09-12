import UIKit

public extension UIButton {
    /// Style을 필요로하는 Text가 포함된 일반 버튼에서 사용
    func setText(
        to text: String = " ",
        with style: PPFontStyle,
        color: UIColor = .g1000,
        for controlState: UIControl.State = .normal
    ) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = style.lineHeightMultiple
        paragraphStyle.maximumLineHeight = style.lineHeight
        paragraphStyle.minimumLineHeight = style.lineHeight

        let attributedString = NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont.PPFont(style: style),
                .paragraphStyle: paragraphStyle,
                .baselineOffset: style.baseLineOffset,
                .foregroundColor: color
            ]
        )

        self.setAttributedTitle(attributedString, for: controlState)
    }
}
