import UIKit

import DesignSystem

import SnapKit
import Then

final class CategorySelectView: UIView {

    // MARK: - Components
    private let titleLabel: PPLabel = {
        return PPLabel(style: .bold, fontSize: 18, text: "카테고리를 선택해주세요")
    }()

    let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_xmark"), for: .normal)
    }

    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        $0.setCollectionViewLayout(makeLayout(), animated: false)
        $0.isScrollEnabled = false

        $0.register(
            TagCollectionViewCell.self,
            forCellWithReuseIdentifier: TagCollectionViewCell.identifiers
        )
    }

    let buttonStackView = UIStackView().then {
        $0.distribution = .fillEqually
        $0.spacing = 12
    }

    let resetButton = PPButton(style: .secondary, text: "초기화")

    let saveButton = PPButton(style: .primary, text: "옵션저장", disabledText: "옵션저장")

    // MARK: - init
    init() {
        super.init(frame: .zero)

        self.addViews()
        self.setupConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("\(#file), \(#function) Error")
    }
}

// MARK: - SetUp
private extension CategorySelectView {

    func addViews() {
        [titleLabel, closeButton, collectionView, buttonStackView].forEach {
            self.addSubview($0)
        }

        [resetButton, saveButton].forEach {
            buttonStackView.addArrangedSubview($0)
        }
    }

    // FIXME: 레이아웃 에러로 인한 Modal이 살짝 내려가지는 문제 발생중
    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(32)
        }

        closeButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(titleLabel)
        }

        collectionView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.height.equalTo(195)
        }

        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
            make.bottom.equalTo(self.safeAreaLayoutGuide)
        }
    }
}

private extension CategorySelectView {

    func makeLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .estimated(26),
                heightDimension: .absolute(36)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(1000)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = .fixed(12)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
            section.interGroupSpacing = 16

            return section
        }
    }
}
