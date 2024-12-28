//
//  AgeSelectedButton.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/26/24.
//

import UIKit

import SnapKit

final class AgeSelectedButton: UIView {
    
    // MARK: - Components
    private let contentStackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        return view
    }()
    
    private let defaultLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 14, text: "나이를 선택해주세요")
        label.textColor = .g400
        return label
    }()
    
    private let rightImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_dropdown")
        return view
    }()
    
    private let ageTitleLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 11, text: "나이")
        label.textColor = .g400
        return label
    }()
    
    private let ageLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 14, text: "")
        label.textColor = .g1000
        return label
    }()
    
    private let verticalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        view.isHidden = true
        view.spacing = 4
        return view
    }()
    
    let button: UIButton = {
        let button = UIButton()
        return button
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
private extension AgeSelectedButton {
    
    func setUpConstraints() {
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 4
        self.layer.borderColor = UIColor.g200.cgColor
        
        self.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        rightImageView.snp.makeConstraints { make in
            make.size.equalTo(20)
        }
        verticalStackView.addArrangedSubview(ageTitleLabel)
        verticalStackView.addArrangedSubview(ageLabel)
        
        contentStackView.addArrangedSubview(defaultLabel)
        contentStackView.addArrangedSubview(verticalStackView)
        contentStackView.addArrangedSubview(rightImageView)
        
        self.addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension AgeSelectedButton: Inputable {
    struct Input {
        var age: Int?
    }
    
    func injection(with input: Input) {
        if let age = input.age {
            verticalStackView.isHidden = false
            ageLabel.text = "\(age)세"
            defaultLabel.isHidden = true
        } else {
            verticalStackView.isHidden = true
            defaultLabel.isHidden = false
        }
    }
}
