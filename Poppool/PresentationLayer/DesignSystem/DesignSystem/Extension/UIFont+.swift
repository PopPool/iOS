import UIKit

private final class BundleFinder {
    static let module = Bundle(for: BundleFinder.self)
}

fileprivate extension Bundle {
    static let module = BundleFinder.module
}

public extension UIFont {
    static func korFont(style: FontStyle, size: CGFloat) -> UIFont {
        let fontName = "GothicA1-\(style.rawValue)"

        if let font = UIFont(name: fontName, size: size) { return font } else { return registerAndGetFont(name: fontName, size: size) }
    }

    static func engFont(style: FontStyle, size: CGFloat) -> UIFont {
        let fontName = "Poppins-\(style.rawValue)"

        if let font = UIFont(name: fontName, size: size) { return font } else { return registerAndGetFont(name: fontName, size: size) }
    }

    static func poppoolFont(style: PoppoolFont) -> UIFont {
        if let font = UIFont(name: style.fontName, size: style.size) {
            return font
        } else {
            return registerAndGetFont(name: style.fontName, size: style.size)
        }
    }

    private static func registerAndGetFont(name: String, size: CGFloat) -> UIFont {
        let url = Bundle.module.url(forResource: name, withExtension: "ttf")!
        CTFontManagerRegisterFontURLs([url as CFURL] as CFArray, .process, true, nil)
        return UIFont(name: name, size: size)!

    }

    enum FontStyle: String {
        case bold = "Bold"
        case medium = "Medium"
        case regular = "Regular"
        case light = "Light"
    }
}
