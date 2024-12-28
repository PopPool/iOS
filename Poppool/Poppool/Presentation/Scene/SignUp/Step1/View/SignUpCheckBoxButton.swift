//
//  SignUpCheckBoxButton.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/25/24.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class SignUpCheckBoxButton: UIView {
    
    // MARK: - Components
    private let checkImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_checkBox")
        return view
    }()
    
    private let buttonLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 15, text: "약관에 모두 동의할게요")
        return label
    }()
    
    let button: UIButton = {
        let button = UIButton()
        return button
    }()
    
    let disposeBag = DisposeBag()
    
    let isSelected: BehaviorRelay<Bool> = .init(value: false)
    
    // MARK: - init
    init() {
        super.init(frame: .zero)
        setUpConstraints()
        bind()
        self.backgroundColor = .g50
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SetUp
private extension SignUpCheckBoxButton {
    
    func setUpConstraints() {
        self.addSubview(checkImageView)
        checkImageView.snp.makeConstraints { make in
            make.size.equalTo(16)
            make.centerY.equalToSuperview()
            make.leading.equalTo(20)
        }
        
        self.addSubview(buttonLabel)
        buttonLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(checkImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(20)
        }
        
        self.addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func bind() {
        button.rx.tap
            .withUnretained(self)
            .subscribe { (owner, _) in
                owner.isSelected.accept(!owner.isSelected.value)
            }
            .disposed(by: disposeBag)
        
        isSelected
            .withUnretained(self)
            .subscribe { (owner, isSelected) in
                if isSelected {
                    owner.checkImageView.image = UIImage(named: "icon_checkBox_fill")
                } else {
                    owner.checkImageView.image = UIImage(named: "icon_checkBox")
                }
            }
            .disposed(by: disposeBag)
    }
}
