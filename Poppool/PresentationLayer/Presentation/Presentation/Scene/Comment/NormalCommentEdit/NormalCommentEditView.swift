import UIKit

import DesignSystem

import SnapKit

final class NormalCommentEditView: UIView {

    // MARK: - Components

    let headerView: PPReturnHeaderView = {
        let view = PPReturnHeaderView()
        view.headerLabel.setLineHeightText(text: "코멘트 수정하기", font: .korFont(style: .regular, size: 15))
        return view
    }()

    let contentCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: .init())
        view.backgroundColor = .g50
        view.isScrollEnabled = false
        return view
    }()

    let saveButton: PPButton = {
        return PPButton(style: .primary, text: "저장", disabledText: "저장")
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
private extension NormalCommentEditView {

    func setUpConstraints() {
        self.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        self.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }

        self.addSubview(contentCollectionView)
        contentCollectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.bottom.equalTo(saveButton.snp.top)
            make.leading.trailing.equalToSuperview()
        }
    }
}
