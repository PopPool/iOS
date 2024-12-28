//
//  SectionBackGroundDecorationView.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/30/24.
//

import UIKit

class SectionBackGroundDecorationView: UICollectionReusableView {
    // Decoration view의 UI 요소를 추가합니다.
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .g700
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SectionBackGroundDecorationView: Inputable {
    struct Input {
        var backgroundColor: UIColor
    }
    
    func injection(with input: Input) {
        self.backgroundColor = input.backgroundColor
    }
}
