//
//  SplashView.swift
//  Poppool
//
//  Created by Porori on 11/25/24.
//

import UIKit
import SnapKit
import Lottie

final class SplashView: UIView {
    
    // MARK: - Components
    
    private let animationView =  LottieAnimationView(name: Constants.lottie.splashAnimation)
    
    // MARK: - init
    init() {
        super.init(frame: .zero)
        setUpConstraints()
        playAnimation()
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
            make.edges.equalToSuperview()
        }
    }
    
    func playAnimation() {
        animationView.play { _ in
            UIView.animate(withDuration: 0.5, animations: {
                self.animationView.alpha = 0
            }, completion: { _ in
                self.animationView.alpha = 1
                self.animationView.removeFromSuperview()
                self.alpha = 1
            })
        }
    }
}
