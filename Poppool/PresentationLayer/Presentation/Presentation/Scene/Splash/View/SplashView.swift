//
//  SplashView.swift
//  Poppool
//
//  Created by Porori on 11/25/24.
//

import UIKit

import Lottie
import SnapKit

final class SplashView: UIView {

    // MARK: - Components

    let animationView: LottieAnimationView = {
        let view = LottieAnimationView(name: "PP_splash")
        view.contentMode = .scaleAspectFit
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
private extension SplashView {

    func setUpConstraints() {
        addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
            make.centerY.equalToSuperview().offset(-72)
        }
    }
}
