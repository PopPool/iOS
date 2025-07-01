import UIKit

public extension UITextField {
    func setPlaceholder(text: String, color: UIColor, font: UIFont) {
        self.attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [.foregroundColor: color, .font: font]
        )
    }
}
