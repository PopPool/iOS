//
//  IndicatorMaker.swift
//  MomsVillage
//
//  Created by SeoJunYoung on 10/14/24.
//

import UIKit

import Lottie
import SnapKit

struct IndicatorMaker {

    static let indicatorImageView: LottieAnimationView = {
        let view = LottieAnimationView(name: "indicator")
        view.loopMode = .loop
        return view
    }()

    static let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.1)
        return view
    }()

    static func showIndicator() {
        DispatchQueue.main.async {
            guard let topVC = UIApplication.topViewController() else {
                print("Error: Cannot find top view controller")
                return
            }

            topVC.view.addSubview(overlayView)
            overlayView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            overlayView.addSubview(indicatorImageView)
            indicatorImageView.snp.makeConstraints { make in
                make.size.equalTo(200)
                make.center.equalToSuperview()
            }
            indicatorImageView.play()
            topVC.view.isUserInteractionEnabled = false
        }
    }

    static func hideIndicator() {
        DispatchQueue.main.async {
            indicatorImageView.stop()
            overlayView.removeFromSuperview()
            indicatorImageView.removeFromSuperview()
            UIApplication.topViewController()?.view.isUserInteractionEnabled = true
        }
    }
}
