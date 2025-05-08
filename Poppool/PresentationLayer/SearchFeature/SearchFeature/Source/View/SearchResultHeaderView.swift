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

    private let afterSearchTitleLabel = PPLabel(style: .bold, fontSize: 16).then {
        $0.isHidden = true
    }

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
        [afterSearchTitleLabel, cellCountLabel, filterStatusButton].forEach {
            addSubview($0)
        }

        [filterStatusLabel, dropDownImageView].forEach {
            filterStatusButton.addSubview($0)
        }
    }

    func setupConstraints() {
        afterSearchTitleLabel.snp.makeConstraints { make in
            make.height.equalTo(0)
            make.horizontalEdges.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(cellCountLabel.snp.top).offset(-4)
        }

        cellCountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalTo(20)
            make.bottom.equalToSuperview()
        }

        filterStatusButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.height.equalTo(22)
            make.bottom.equalToSuperview()
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

extension SearchResultHeaderView {
    func configureHeader(title: String?, count: Int?, filterText: String?) {
        if let afterSearchTitle = title,
           let count = count {
            filterStatusButton.isHidden = true
            afterSearchTitleLabel.isHidden = false
            afterSearchTitleLabel.text = afterSearchTitle + " 포함된 팝업"
            cellCountLabel.text = "총 \(count)개를 찾았어요."

            if count == 0 { self.isHidden = true }
            else {
                self.isHidden = false
                afterSearchTitleLabel.snp.updateConstraints { make in
                    make.height.equalTo(24)
                }
            }

        } else if let count, let filterText {
            filterStatusButton.isHidden = false
            afterSearchTitleLabel.isHidden = true
            cellCountLabel.text = "총 \(count)개"
            filterStatusLabel.text = filterText

            self.isHidden = false
            afterSearchTitleLabel.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
        }
    }
}
