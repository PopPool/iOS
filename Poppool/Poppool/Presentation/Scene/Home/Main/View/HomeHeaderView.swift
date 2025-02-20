//
//  HomeHeaderView.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/30/24.
//

import UIKit

import SnapKit

final class HomeHeaderView: UIView {
    
    // MARK: - Components
    
    let searchBarButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 4
        return button
    }()
    
    let blurEffect = UIBlurEffect(style: .regular)
    lazy var blurView = UIVisualEffectView(effect: blurEffect)
    
    private let searchIconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_search_black")
        return view
    }()
    
    private let searchLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 14, text: "팝업스토어명을 입력해보세요")
        label.textColor = .g1000
        label.isUserInteractionEnabled = false
        return label
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
private extension HomeHeaderView {
    
    func setUpConstraints() {
        blurView.isUserInteractionEnabled = false
        blurView.layer.cornerRadius = 4
        blurView.clipsToBounds = true
        searchBarButton.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalTo(searchBarButton)
        }
        
        self.addSubview(searchBarButton)
        searchBarButton.snp.makeConstraints { make in
            make.height.equalTo(37)
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview()
        }
        
        searchBarButton.addSubview(searchIconImageView)
        searchIconImageView.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(12)
        }
        
        searchBarButton.addSubview(searchLabel)
        searchLabel.snp.makeConstraints { make in
            make.centerY.equalTo(searchIconImageView)
            make.leading.equalTo(searchIconImageView.snp.trailing).offset(4)
        }
    }
}
