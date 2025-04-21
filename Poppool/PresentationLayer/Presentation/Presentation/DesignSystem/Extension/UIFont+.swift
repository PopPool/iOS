import Foundation

import UIKit

public extension UIFont {
    static func korFont(style: FontStyle, size: CGFloat) -> UIFont? {
        return UIFont(name: "GothicA1\(style.rawValue)", size: size)
    }

    static func engFont(style: FontStyle, size: CGFloat) -> UIFont? {
        return UIFont(name: "Poppins\(style.rawValue)", size: size)
    }

    enum FontStyle: String {
        case bold = "-Bold"
        case medium = "-Medium"
        case regular = "-Regular"
        case light = "-Light"
    }
}
