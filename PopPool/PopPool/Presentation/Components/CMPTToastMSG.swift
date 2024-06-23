//
//  CMPTToastMSG.swift
//  PopPool
//
//  Created by Porori on 6/24/24.
//

import Foundation
import SnapKit
import UIKit

class CMPTToastMSG: UIView {
    private let bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .pb70
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.sizeToFit()
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .w100
        label.font = .KorFont(style: .regular, size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(message: String) {
        super.init(frame: .zero)
        setup()
        messageLabel.text = message
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(bgView)
        bgView.addSubview(messageLabel)
        
        bgView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(snp.bottom)
            make.height.equalTo(38)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
}
