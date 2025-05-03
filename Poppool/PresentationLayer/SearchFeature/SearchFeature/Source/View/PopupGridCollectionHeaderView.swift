import UIKit

import DesignSystem

import SnapKit
import RxSwift
import Then

final class PopupGridCollectionHeaderView: UICollectionReusableView {

    enum Identifier: String {
        case searchResult = "PopupGridCollectionHeaderView.searchResult"
    }

    // MARK: - Properties

    var disposeBag = DisposeBag()

    private let cellCountLabel = PPLabel(style: .regular, fontSize: 13).then {
        $0.textColor = .g400
    }

    private let sortedTitleLabel = PPLabel(style: .regular, fontSize: 13)

    private let dropDownImageView = UIImageView().then {
        $0.image = UIImage(named: "icon_dropdown")
        $0.isUserInteractionEnabled = false

    }

    let sortedButton = UIButton()

    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: .zero)

        self.addViews()
        self.setupConstraints()

        self.backgroundColor = .blue
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#file), \(#function) Error")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}

// MARK: - SetUp
private extension PopupGridCollectionHeaderView {
    func addViews() {
        [cellCountLabel, sortedButton].forEach {
            addSubview($0)
        }

        [sortedTitleLabel, dropDownImageView].forEach {
            sortedButton.addSubview($0)
        }
    }

    func setupConstraints() {
        cellCountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.verticalEdges.equalToSuperview()
        }

        sortedButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.verticalEdges.equalToSuperview()
        }

        sortedTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.verticalEdges.equalToSuperview()
        }

        dropDownImageView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.width.equalTo(dropDownImageView.snp.height)
            make.leading.equalTo(sortedTitleLabel.snp.trailing).offset(6)
            make.trailing.equalToSuperview()
        }
    }
}

extension PopupGridCollectionHeaderView: Inputable {
    struct Input {
        var count: Int64
        var sortedTitle: String?
    }

    func injection(with input: Input) {
        sortedTitleLabel.text = input.sortedTitle
        cellCountLabel.text = "총 \(input.count)개"
    }
}
