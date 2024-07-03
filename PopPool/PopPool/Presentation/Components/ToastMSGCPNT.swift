//
//  ToastMSGCPNT.swift
//  PopPool
//
//  Created by Porori on 6/24/24.
//

import Foundation
import SnapKit
import UIKit

/// 토스트 메시지를 담는 view 객체입니다
final class ToastMSGCPNT: UIView {
    
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

extension ToastMSGCPNT {
    
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
            make.leading.trailing.equalToSuperview().inset(Constants.spaceGuide._16px)
            make.centerY.equalToSuperview()
        }
    }
}
