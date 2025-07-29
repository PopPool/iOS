import UIKit

import DesignSystem
import Infrastructure

import SnapKit
import Then

final class SearchResultEmptyCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    private let emptyLabel = PPLabel(style: .KOm14).then {
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.textColor = .g400
    }

    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addViews()
        self.setupConstraints()
        self.configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("\(#file), \(#function) Error")
    }
}

// MARK: - SetUp
private extension SearchResultEmptyCollectionViewCell {
    func addViews() {
        [emptyLabel].forEach {
            self.addSubview($0)
        }
    }

    func setupConstraints() {
        emptyLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(145)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(42)
        }
    }

    func configureUI() { }
}

extension SearchResultEmptyCollectionViewCell {
    func configureCell(title: String) {
        self.emptyLabel.updateText(to: title)
    }
}
