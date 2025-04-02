//
//  UIFont+.swift
//  PopPool
//
//  Created by Porori on 6/20/24.
//

import Foundation
import UIKit

extension UIFont {

    static func KorFont(style: FontStyle, size: CGFloat) -> UIFont? {
        return UIFont(name: "GothicA1\(style.rawValue)", size: size)
    }

    static func EngFont(style: FontStyle, size: CGFloat) -> UIFont? {
        return UIFont(name: "Poppins\(style.rawValue)", size: size)
    }

    enum FontStyle: String {
        case bold = "-Bold"
        case medium = "-Medium"
        case regular = "-Regular"
        case light = "-Light"
    }
}
