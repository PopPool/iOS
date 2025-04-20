//
//  UITextField+.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/4/24.
//

import UIKit

extension UITextField {
    func setPlaceholder(text: String, color: UIColor, font: UIFont) {
        self.attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [.foregroundColor: color, .font: font]
        )
    }
}
