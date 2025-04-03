import SnapKit
import UIKit

final class FilterBottomSheetView: UIView {
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
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
        return PPSegmentedControl(type: .tab, segments: ["지역", "카테고리"], selectedSegmentIndex: 0)
    }()

    let locationScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    let locationContentView = UIView()
    var categoryHeightConstraint: Constraint?

    let categoryCollectionView: UICollectionView = {
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
        collectionView.register(TagSectionCell.self, forCellWithReuseIdentifier: TagSectionCell.identifiers)
        return collectionView
    }()

    let balloonBackgroundView = BalloonBackgroundView()

    let resetButton: PPButton = {
        return PPButton(style: .secondary, text: "초기화")
    }()

    let saveButton: PPButton = {
        return PPButton(style: .primary, text: "옵션저장", disabledText: "옵션저장")
    }()

    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()

    let filterChipsView: FilterChipsView = {
        return FilterChipsView()
    }()

    private var balloonHeightConstraint: Constraint?

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

        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(segmentedControl)
        containerView.addSubview(locationScrollView)
        locationScrollView.addSubview(locationContentView)
        containerView.addSubview(balloonBackgroundView)
        containerView.addSubview(categoryCollectionView)
        containerView.addSubview(filterChipsView)

        buttonStack.addArrangedSubview(resetButton)
        buttonStack.addArrangedSubview(saveButton)
        containerView.addSubview(buttonStack)

        setupConstraints()
    }

    private func setupConstraints() {
        self.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width)
        }

        containerView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.snp.top)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(30)
        }

        closeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(24)
        }

        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }

        locationScrollView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(36)
        }

        locationContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }

        categoryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            categoryHeightConstraint = make.height.equalTo(160).constraint
        }

        balloonBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(locationScrollView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            balloonHeightConstraint = make.height.equalTo(0).constraint
        }

        filterChipsView.snp.makeConstraints { make in
            make.top.equalTo(balloonBackgroundView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(80)
        }

        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(filterChipsView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(40)
            make.height.equalTo(52)
        }
    }

    func setupLocationScrollView(locations: [Location], buttonAction: @escaping (Int, UIButton) -> Void) {
        locationContentView.subviews.forEach { $0.removeFromSuperview() }
        locationScrollView.delegate = self as? UIScrollViewDelegate

        var lastButton: UIButton?

        for (index, location) in locations.enumerated() {
            let button = createStyledButton(title: location.main)
            button.tag = index

            button.addTarget(self, action: #selector(locationButtonTapped(_:)), for: .touchUpInside)

            // actionHandler 클로저 저장
            button.layer.setValue(index, forKey: "buttonIndex")
            objc_setAssociatedObject(button, &AssociatedKeys.actionHandler, { [weak self] in
                buttonAction(index, button)
                self?.updateMainLocationSelection(index)
            }, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            locationContentView.addSubview(button)

            button.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                if let lastButton = lastButton {
                    make.leading.equalTo(lastButton.snp.trailing).offset(12)
                } else {
                    make.leading.equalToSuperview().offset(16)
                }
            }

            lastButton = button
        }

        if let lastButton = lastButton {
            lastButton.snp.makeConstraints { make in
                make.trailing.equalToSuperview().inset(16)
            }
        }
    }

    private struct AssociatedKeys {
        static var actionHandler = "actionHandler"
    }

    @objc private func locationButtonTapped(_ sender: UIButton) {
        if let actionHandler = objc_getAssociatedObject(sender, &AssociatedKeys.actionHandler) as? () -> Void {
            actionHandler()
        }
    }

    func updateCategoryButtonSelection(_ category: String) {
        categoryCollectionView.subviews.forEach { subview in
            if let stackView = subview as? UIStackView {
                stackView.arrangedSubviews.forEach { view in
                    if let button = view as? UIButton, button.title(for: .normal) == category {
                        let isSelected = button.backgroundColor == .blu500
                        if isSelected {
                            button.backgroundColor = .white
                            button.setTitleColor(.g500, for: .normal)
                            button.layer.borderWidth = 1
                            button.layer.borderColor = UIColor.g200.cgColor
                        } else {
                            button.backgroundColor = .blu500
                            button.setTitleColor(.white, for: .normal)
                            button.layer.borderWidth = 0
                        }
                    }
                }
            }
        }
    }

    func updateContentVisibility(isCategorySelected: Bool) {
        self.locationScrollView.isHidden = isCategorySelected
        self.balloonBackgroundView.isHidden = isCategorySelected
        self.categoryCollectionView.isHidden = !isCategorySelected

        self.locationScrollView.alpha = isCategorySelected ? 0 : 1
        self.balloonBackgroundView.alpha = isCategorySelected ? 0 : 1
        self.categoryCollectionView.alpha = isCategorySelected ? 1 : 0

        let newHeight = isCategorySelected ? 170 : self.balloonBackgroundView.calculateHeight()
        self.balloonHeightConstraint?.update(offset: newHeight)
    }

    private func createCategoryButton(title: String, isSelected: Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        button.layer.cornerRadius = 14
        button.layer.masksToBounds = true

        button.contentEdgeInsets = UIEdgeInsets(top: 9, left: 16, bottom: 9, right: 16)

        if isSelected {
            button.backgroundColor = .blu500
            button.setTitleColor(.white, for: .normal)
        } else {
            button.backgroundColor = .white
            button.setTitleColor(.g500, for: .normal)
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.g200.cgColor
        }

        return button
    }

    private func createStyledButton(title: String, isSelected: Bool = false) -> PPButton {
        let button = PPButton(
            style: .secondary,
            text: title,
            font: .KorFont(style: .medium, size: 13),
            cornerRadius: 18
        )
        button.setBackgroundColor(.w100, for: .normal)
        button.setTitleColor(.g400, for: .normal)
        button.layer.borderColor = UIColor.g200.cgColor
        button.layer.borderWidth = 1

        if isSelected {
            button.setBackgroundColor(.blu500, for: .normal)
            button.setTitleColor(.w100, for: .normal)
            button.layer.borderWidth = 0
        }

        button.contentEdgeInsets = UIEdgeInsets(top: 9, left: 16, bottom: 9, right: 16)

        return button
    }

    func updateMainLocationSelection(_ index: Int) {
        locationContentView.subviews.enumerated().forEach { (idx, view) in
            guard let button = view as? PPButton else { return }
            if idx == index {
                button.setBackgroundColor(.blu500, for: .normal)
                button.setTitleColor(.w100, for: .normal)
                button.layer.borderWidth = 0
                button.titleLabel?.font = .KorFont(style: .bold, size: 13)
            } else {
                button.setBackgroundColor(.w100, for: .normal)
                button.setTitleColor(.g400, for: .normal)
                button.layer.borderColor = UIColor.g200.cgColor
                button.titleLabel?.font = .KorFont(style: .medium, size: 13)
                button.layer.borderWidth = 1
            }
        }
    }

    func updateBalloonHeight(isHidden: Bool, dynamicHeight: CGFloat = 160) {
        balloonBackgroundView.alpha = isHidden ? 0 : 1
        balloonBackgroundView.isHidden = isHidden
        balloonHeightConstraint?.update(offset: isHidden ? 0 : dynamicHeight)
        self.layoutIfNeeded()
    }

    func updateBalloonPosition(for button: UIButton) {
        DispatchQueue.main.async {
            guard let window = button.window else { return }

            let buttonFrameInWindow = button.convert(button.bounds, to: window)
            let balloonFrameInWindow = self.balloonBackgroundView.convert(self.balloonBackgroundView.bounds, to: window)

            let buttonCenterX = buttonFrameInWindow.midX
            let relativeX = buttonCenterX - balloonFrameInWindow.minX
            let position = relativeX / self.balloonBackgroundView.bounds.width
            let minPosition: CGFloat = 0.1
            let maxPosition: CGFloat = 0.9
            let clampedPosition = min(maxPosition, max(minPosition, position))

            self.balloonBackgroundView.arrowPosition = clampedPosition
            self.balloonBackgroundView.setNeedsDisplay()
        }
    }

    private func updateBalloonPositionAccurately(for button: PPButton) {
        let buttonFrameInBalloon = button.convert(button.bounds, to: balloonBackgroundView)
        let arrowPosition = buttonFrameInBalloon.midX / balloonBackgroundView.bounds.width
        balloonBackgroundView.arrowPosition = arrowPosition
        balloonBackgroundView.setNeedsDisplay()
    }

    private func updateSelectedButtonPosition() {
        guard let selectedButton = locationContentView.subviews.first(where: { view in
            guard let button = view as? PPButton else { return false }
            return button.backgroundColor == .blu500
        }) as? PPButton else { return }

        updateBalloonPosition(for: selectedButton)
    }
}

// MARK: - Extensions
extension FilterBottomSheetView {
    func update(locationText: String?, categoryText: String?) {
        var filters: [String] = []

        if let locationText = locationText, !locationText.isEmpty {
            filters.append(locationText)
        }
        if let categoryText = categoryText, !categoryText.isEmpty {
            filters.append(categoryText)
        }

        filterChipsView.updateChips(with: filters)
    }
}

extension FilterBottomSheetView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateSelectedButtonPosition()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateSelectedButtonPosition()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateSelectedButtonPosition()
        }
    }
}
