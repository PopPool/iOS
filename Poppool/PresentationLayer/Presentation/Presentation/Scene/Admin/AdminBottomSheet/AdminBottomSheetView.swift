import DesignSystem
import Infrastructure
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class AdminBottomSheetView: UIView {

    // MARK: - Properties
    private var contentHeightConstraint: Constraint?
    typealias Reactor = AdminBottomSheetReactor

    // MARK: - Components
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        return view
    }()

    let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    let titleLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 18, text: "보기 옵션을 선택해주세요")
        label.textColor = .black
        return label
    }()

    let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "icon_xmark"), for: .normal)
        button.tintColor = .black
        return button
    }()

    let segmentedControl: PPSegmentedControl = {
        return PPSegmentedControl(
            type: .tab,
            segments: ["상태값", "카테고리"],
            selectedSegmentIndex: 0
        )
    }()

    let contentCollectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { section, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .estimated(26),
                heightDimension: .absolute(36)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(36)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            group.interItemSpacing = .fixed(12)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(
                top: 20,
                leading: 20,
                bottom: 20,
                trailing: 20
            )
            section.interGroupSpacing = 16
            return section
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        // Register cell here if needed, e.g. collectionView.register(TagSectionCell.self, forCellWithReuseIdentifier: TagSectionCell.identifiers)
        return collectionView
    }()

    let filterChipsView = FilterChipsView()

    let resetButton: PPButton = {
        let button = PPButton(
            style: .secondary,
            text: "초기화",
            font: .korFont(style: .medium, size: 16),
            cornerRadius: 4
        )
        button.isEnabled = false
        button.contentEdgeInsets = UIEdgeInsets(
            top: 9, left: 16, bottom: 9, right: 12
        )
        return button
    }()

    let saveButton: PPButton = {
        let button = PPButton(
            style: .primary,
            text: "옵션저장",
            disabledText: "옵션저장",
            font: .korFont(style: .medium, size: 16),
            cornerRadius: 4
        )
        button.isEnabled = false
        button.contentEdgeInsets = UIEdgeInsets(
            top: 9, left: 16, bottom: 9, right: 12
        )
        return button
    }()

    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupLayout() {
        backgroundColor = .clear
        addSubview(containerView)

        containerView.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(closeButton)

        [segmentedControl, contentCollectionView, filterChipsView, buttonStack].forEach {
            containerView.addSubview($0)
        }

        buttonStack.addArrangedSubview(resetButton)
        buttonStack.addArrangedSubview(saveButton)

        setupConstraints()
    }

    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview()
        }

        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        closeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }

        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }

        contentCollectionView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            contentHeightConstraint = make.height.equalTo(160).constraint
        }

        filterChipsView.snp.makeConstraints { make in
            make.top.equalTo(contentCollectionView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(filterChipsView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(40)
            make.height.equalTo(52)
        }
    }

    // MARK: - Public Methods
    func calculateCollectionViewHeight(for items: [String]) -> CGFloat {
        let sectionInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        let itemSpacing: CGFloat = 12
        let lineSpacing: CGFloat = 16

        let collectionViewWidth = UIScreen.main.bounds.width
        let availableWidth = collectionViewWidth - sectionInsets.left - sectionInsets.right

        var currentRowWidth: CGFloat = 0
        var numberOfRows = 1

        for (index, item) in items.enumerated() {
            let text = item as NSString
            let textSize = text.size(withAttributes: [
                .font: UIFont.korFont(style: .medium, size: 13)
            ])
            let itemWidth = textSize.width + 32 // padding: 16 left/right each

            if index == 0 {
                currentRowWidth = itemWidth
            } else {
                let widthWithSpacing = currentRowWidth + itemSpacing + itemWidth
                if widthWithSpacing > availableWidth {
                    numberOfRows += 1
                    currentRowWidth = itemWidth
                } else {
                    currentRowWidth = widthWithSpacing
                }
            }
        }

        let itemHeight: CGFloat = 36
        return sectionInsets.top + sectionInsets.bottom +
                         (CGFloat(numberOfRows) * itemHeight) +
                         (CGFloat(max(0, numberOfRows - 1)) * lineSpacing)
    }
}
