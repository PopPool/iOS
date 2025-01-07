//
//  MyPageLogoutSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/4/25.
//

import UIKit

import SnapKit
import RxSwift

final class MyPageLogoutSectionCell: UICollectionViewCell {
    
    // MARK: - Components

    let logoutButton: PPButton = {
        let button = PPButton(style: .secondary, text: "로그아웃")
        return button
    }()
    
    var disposeBag = DisposeBag()
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}

// MARK: - SetUp
private extension MyPageLogoutSectionCell {
    func setUpConstraints() {
        contentView.addSubview(logoutButton)
        logoutButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension MyPageLogoutSectionCell: Inputable {
    struct Input {

    }
    
    func injection(with input: Input) {

    }
}
