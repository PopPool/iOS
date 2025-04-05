//
//  SearchMainView.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/7/24.
//

import UIKit

import SnapKit

final class SearchMainView: UIView {

    // MARK: - Components
    private let searchTrailingView: UIView = {
        let view = UIView()
        view.backgroundColor = .g50
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()

    private let searchIconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_search_gray")
        return view
    }()

    private let searchStackView: UIStackView = {
        let view = UIStackView()
        view.spacing = 4
        view.alignment = .center
        return view
    }()

    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.g1000, for: .normal)
        button.titleLabel?.font = .korFont(style: .regular, size: 14)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()

    let searchTextField: UITextField = {
        let view = UITextField()
        view.font = .korFont(style: .regular, size: 14)
        view.setPlaceholder(text: "팝업스토어명을 입력해보세요", color: .g400, font: .korFont(style: .regular, size: 14)!)
        return view
    }()

    let clearButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_clearButton"), for: .normal)
        return button
    }()

    private var headerStackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.spacing = 16
        return view
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
private extension SearchMainView {

    func setUpConstraints() {
        searchTrailingView.snp.makeConstraints { make in
            make.height.equalTo(37)
        }
        headerStackView.addArrangedSubview(searchTrailingView)
        headerStackView.addArrangedSubview(cancelButton)
        self.addSubview(headerStackView)
        headerStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(7)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(16)
        }
        searchTrailingView.addSubview(searchStackView)
        searchStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(12)
        }
        searchStackView.addArrangedSubview(searchIconImageView)
        searchStackView.addArrangedSubview(searchTextField)
        searchStackView.addArrangedSubview(clearButton)

        searchIconImageView.snp.makeConstraints { make in
            make.size.equalTo(20)
        }

        searchTextField.snp.makeConstraints { make in
            make.height.equalTo(21)
        }

        clearButton.snp.makeConstraints { make in
            make.size.equalTo(16)
        }
    }
}
