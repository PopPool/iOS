import UIKit

import DesignSystem

import SnapKit
import Then

public class PPSearchBarView: UIView {

    private let stackView = UIStackView().then {
        $0.spacing = 16
        $0.alignment = .center
        $0.axis = .horizontal
    }

    let searchBar = UISearchBar().then {
        $0.searchTextField.setPlaceholder(text: "팝업스토어명을 입력해보세요", color: .g400, font: .korFont(style: .regular, size: 14))
        $0.tintColor = .g400
        $0.backgroundColor = .g50
        $0.setImage(UIImage(named: "icon_search_gray"), for: .search, state: .normal)
        $0.searchBarStyle = .minimal
        $0.searchTextField.clearButtonMode = .never
        $0.searchTextField.subviews.first?.isHidden = true
    }

    let clearButton = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "icon_clear_button"), for: .normal)
        $0.isHidden = true
    }

    let cancelButton = UIButton(type: .system).then {
        $0.setTitle("취소", for: .normal)
        $0.tintColor = .g1000
        $0.titleLabel?.font = .korFont(style: .regular, size: 14)
    }

    public init() {
        super.init(frame: .zero)

        self.addViews()
        self.setupConstraints()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("\(#file), \(#function) Error")
    }
}

private extension PPSearchBarView {
    func addViews() {
        [stackView].forEach {
            self.addSubview($0)
        }

        [searchBar, cancelButton].forEach {
            self.stackView.addArrangedSubview($0)
        }

        [clearButton].forEach {
            self.searchBar.addSubview($0)
        }
    }

    func setupConstraints() {
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(7)
        }

        searchBar.snp.makeConstraints { make in
            make.height.equalToSuperview()
        }

        clearButton.snp.makeConstraints { make in
             make.trailing.equalToSuperview().inset(12)
             make.centerY.equalToSuperview()
             make.size.equalTo(20)
         }

        cancelButton.snp.makeConstraints { make in
            make.height.equalToSuperview()
        }
    }
}
