//
//  LoadingIndicator.swift
//  PopPool
//
//  Created by Porori on 9/3/24.
//

import UIKit
import Lottie
import SnapKit

final class LoadingIndicator: UIView {
    
    private let animationView: LottieAnimationView = {
        let view = LottieAnimationView(name: Constants.lottie.loading)
        view.animationSpeed = 1.5
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
        setUpConstraint()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        self.backgroundColor = .clear
    }
    
    private func setUpConstraint() {
        self.addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    public func startIndicator() {
        animationView.play()
        animationView.loopMode = .loop
    }
    
    public func stopIndicator() {
        self.removeFromSuperview()
        animationView.stop()
        animationView.removeFromSuperview()
    }
}
