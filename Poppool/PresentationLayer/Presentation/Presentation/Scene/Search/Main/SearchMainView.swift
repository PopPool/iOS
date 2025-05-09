import UIKit

import DesignSystem

import SnapKit
import Then

final class SearchMainView: UIView {

    // MARK: - Components
    private let searchTrailingView = UIView().then {
        $0.backgroundColor = .g50
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }

    private let searchIconImageView = UIImageView().then {
        $0.image = UIImage(named: "icon_search_gray")
    }

    private let searchStackView = UIStackView().then {
        $0.spacing = 4
        $0.alignment = .center
    }

    let cancelButton = UIButton(type: .system).then {
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(.g1000, for: .normal)
        $0.titleLabel?.font = .korFont(style: .regular, size: 14)
        $0.imageView?.contentMode = .scaleAspectFit
    }

    let searchTextField = UITextField().then {
        $0.font = .korFont(style: .regular, size: 14)
        $0.setPlaceholder(
            text: "팝업스토어명을 입력해보세요",
            color: .g400,
            font: .korFont(style: .regular, size: 14)
        )
    }

    let clearButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_clear_button"), for: .normal)
    }

    private var headerStackView = UIStackView().then {
        $0.alignment = .center
        $0.spacing = 16
    }

    // MARK: - init
    init() {
        super.init(frame: .zero)

        self.addViews()
        self.setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("\(#file), \(#function) Error")
    }
}

// MARK: - SetUp
private extension SearchMainView {

    func addViews() {
        [headerStackView]
            .forEach { self.addSubview($0) }

        [searchTrailingView, cancelButton]
            .forEach { headerStackView.addArrangedSubview($0) }

        [searchStackView]
            .forEach { searchTrailingView.addSubview($0) }

        [searchIconImageView, searchTextField, clearButton]
            .forEach { searchStackView.addArrangedSubview($0) }
    }

    func setUpConstraints() {
        searchTrailingView.snp.makeConstraints { make in
            make.height.equalTo(37)
        }

        headerStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(7)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(16)
        }

        searchStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(12)
        }

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
