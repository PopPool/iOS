//
//  MyCommentView.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/8/25.
//

import UIKit

import SnapKit

final class MyCommentView: UIView {
    
    // MARK: - Components
    let headerView: PPReturnHeaderView = {
        let view = PPReturnHeaderView()
        view.headerLabel.setLineHeightText(text: "내가 쓴 코멘트", font: .KorFont(style: .regular, size: 15))
        return view
    }()
    
    // MARK: - init
    init() {
        super.init(frame: .zero)
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SetUp
private extension MyCommentView {
    
    func setUpConstraints() {
        self.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
    }
}
