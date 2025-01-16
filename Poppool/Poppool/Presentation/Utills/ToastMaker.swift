//
//  ToastMaker.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/25/24.
//

import Foundation
import UIKit
import SnapKit


import Foundation
import UIKit
import SnapKit

final class ToastMaker {
    
    // MARK: - Properties
    
    /// 현재 디바이스 최상단 Window를 지정
    static var window: UIWindow? {
        return UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }
    }
}

extension ToastMaker {
    
    // MARK: - Method
    
    /// 토스트 메시지를 생성하는 메서드
    /// - Parameter message: 토스트 메세지에 담길 String 타입
   static func createToast(message: String) {
        let toastMSG = ToastView(message: message)
        window?.addSubview(toastMSG)
        
        toastMSG.snp.makeConstraints { make in
            if let window = window {
                make.bottom.equalTo(window.snp.bottom).inset(120)
                make.centerX.equalTo(window.snp.centerX)
            }
        }
        
        UIView.animate(
            withDuration: 0.3,
            delay: 4,
            options: .curveEaseOut
        ) {
            toastMSG.alpha = 0
        } completion: { _ in
            toastMSG.removeFromSuperview()
        }
    }
}

/// 토스트 메시지를 담는 view 객체입니다
final class ToastView: UIView {
    
    // MARK: - Properties
    
    private let bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .pb70
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        view.sizeToFit()
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .w100
        label.font = .KorFont(style: .regular, size: 15)
        return label
    }()
    
    // MARK: - Initializer
    
    init(message: String) {
        super.init(frame: .zero)
        setup()
        messageLabel.text = message
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ToastView {
    
    // MARK: - Method
    
    private func setup() {
        addSubview(bgView)
        bgView.addSubview(messageLabel)
        
        bgView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(snp.bottom)
            make.top.equalTo(snp.top)
            make.height.equalTo(38)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
}
