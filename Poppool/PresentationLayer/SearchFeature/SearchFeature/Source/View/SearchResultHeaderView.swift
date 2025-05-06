import UIKit

import DesignSystem

import SnapKit
import RxSwift
import Then

public final class SearchResultHeaderView: UICollectionReusableView {

    enum Identifier: String {
        case searchResult = "PopupGridCollectionHeaderView.searchResult"
    }

    // MARK: - Properties

    var disposeBag = DisposeBag()

    private let cellCountLabel = PPLabel(style: .regular, fontSize: 13).then {
        $0.textColor = .g400
    }

    private let filterStatusLabel = PPLabel(style: .regular, fontSize: 13)

    private let dropDownImageView = UIImageView().then {
        $0.image = UIImage(named: "icon_dropdown")
        $0.isUserInteractionEnabled = false
    }

    let filterStatusButton = UIButton()

    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: .zero)

        self.addViews()
        self.setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#file), \(#function) Error")
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}

// MARK: - SetUp
private extension SearchResultHeaderView {
    func addViews() {
        [cellCountLabel, filterStatusButton].forEach {
            addSubview($0)
        }

        [filterStatusLabel, dropDownImageView].forEach {
            filterStatusButton.addSubview($0)
        }
    }

    func setupConstraints() {
        cellCountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalTo(22)
            make.centerY.equalToSuperview()
        }

        filterStatusButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.height.equalTo(22)
            make.centerY.equalToSuperview()
        }

        filterStatusLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        dropDownImageView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.width.equalTo(dropDownImageView.snp.height)
            make.leading.equalTo(filterStatusLabel.snp.trailing).offset(6)
            make.trailing.equalToSuperview()
        }
    }
}

extension SearchResultHeaderView: Inputable {
    public struct Input {
        var count: Int?
        var filterStatusTitle: String?
    }

    public func injection(with input: Input) {
        if let count = input.count {
            cellCountLabel.text = "총 \(count)개"
        }

        if let filterStatusTitle = input.filterStatusTitle {
            filterStatusLabel.text = filterStatusTitle
        }
    }
}
