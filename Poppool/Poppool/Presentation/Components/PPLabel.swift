//
//  PPLabel.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/25/24.
//

import UIKit

class PPLabel: UILabel {

    init(
        style: UIFont.FontStyle,
        fontSize: CGFloat,
        text: String = "",
        lineHeight: CGFloat = 1.2
    ) {
        super.init(frame: .zero)
        self.font = .KorFont(style: style, size: fontSize)
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
