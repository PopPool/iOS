//
//  SignUpTermsView.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/25/24.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class SignUpTermsView: UIView {
    
    // MARK: - Components
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_check")
        return view
    }()
    
    private let titleLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 14)
        label.text = "some"
        return label
    }()
    
    let righticonButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "icon_right_gray"), for: .normal)
        return view
    }()
    
    let button: UIButton = {
        let button = UIButton()
        return button
    }()
    
    let isSelected: BehaviorRelay<Bool> = .init(value: false)
    
    let disposeBag = DisposeBag()
    
    // MARK: - init
    init(title: String?) {
        super.init(frame: .zero)
        setUpConstraints()
        bind()
        titleLabel.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SetUp
private extension SignUpTermsView {
    
    func setUpConstraints() {
        self.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
        }
        
        self.addSubview(righticonButton)
        righticonButton.snp.makeConstraints { make in
            make.size.equalTo(22)
            make.top.bottom.trailing.equalToSuperview()
        }
        
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(imageView.snp.trailing).offset(8)
            make.trailing.equalTo(righticonButton.snp.leading)
        }
    
        self.addSubview(button)
        button.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(righticonButton.snp.leading)
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
                    owner.imageView.image = UIImage(named: "icon_check_fill")
                } else {
                    owner.imageView.image = UIImage(named: "icon_check")
                }
            }
            .disposed(by: disposeBag)
    }
}
