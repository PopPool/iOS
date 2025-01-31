//
//  BookMarkToastView.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/21/25.
//

import UIKit

import SnapKit

final class BookMarkToastView: UIView {
    
    // MARK: - Components
    
    private let bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .pb70
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()
    
    private let bookMarkLabel: UILabel = {
        let label = UILabel()
        label.setLineHeightText(text: "찜한 팝업에 저장했어요", font: .KorFont(style: .regular, size: 15), lineHeight: 1)
        label.textColor = .w100
        return label
    }()
    
    private let unbookMarkLabel: UILabel = {
        let label = PPLabel(style: .regular, fontSize: 15, text: "찜한 팝업을 해제했어요")
        label.setLineHeightText(text: "찜한 팝업을 해제했어요", font: .KorFont(style: .regular, size: 15), lineHeight: 1)
        label.textColor = .w100
        return label
    }()

    let moveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("보러가기", for: .normal)
        button.backgroundColor = .pb30
        button.setTitleColor(.blu300, for: .normal)
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        button.titleLabel?.font = .KorFont(style: .medium, size: 12)
        return button
    }()
    
    // MARK: - init
    init(isBookMark: Bool) {
        super.init(frame: .zero)
        self.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        if isBookMark {
            setUpBookMarkConstraints()
        } else {
            setUpUnBookMarkConstraints()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SetUp
private extension BookMarkToastView {
    
    func setUpBookMarkConstraints() {
        bgView.addSubview(moveButton)
        moveButton.snp.makeConstraints { make in
            make.height.equalTo(28)
            make.top.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(7)
            make.trailing.equalToSuperview().inset(16)
            make.width.equalTo(67)
        }
        bgView.addSubview(bookMarkLabel)
        bookMarkLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
    
    func setUpUnBookMarkConstraints() {
        bgView.addSubview(unbookMarkLabel)
        unbookMarkLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(7)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(23)
        }
    }
}
