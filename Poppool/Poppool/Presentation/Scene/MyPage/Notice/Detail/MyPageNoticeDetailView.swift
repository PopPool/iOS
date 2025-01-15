//
//  MyPageNoticeDetailView.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/13/25.
//

import UIKit

import SnapKit

final class MyPageNoticeDetailView: UIView {
    
    // MARK: - Components
    let headerView: PPReturnHeaderView = {
        let view = PPReturnHeaderView()
        view.headerLabel.setLineHeightText(text: "공지사항", font: .KorFont(style: .regular, size: 15))
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .g400
        return label
    }()
    let contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private let scrollView: UIScrollView = UIScrollView()
    private let contentView: UIView = UIView()
    
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
private extension MyPageNoticeDetailView {
    
    func setUpConstraints() {
        self.backgroundColor = .g50
        self.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        self.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(20)
        }
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(31)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
}
