//
//  SignUpMainView.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/25/24.
//

import UIKit

import SnapKit

final class SignUpMainView: UIView {

    // MARK: - Components
    let headerView: PPCancelHeaderView = PPCancelHeaderView()

    let progressIndicator: PPProgressIndicator = PPProgressIndicator(totalStep: 4, startPoint: 1)

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
private extension SignUpMainView {

    func setUpConstraints() {
        self.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        self.addSubview(progressIndicator)
        progressIndicator.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(17)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
}
