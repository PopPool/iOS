import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AdminBottomSheetViewController: BaseViewController {

    // MARK: - Properties
    private let mainView = AdminBottomSheetView()
    private let dimmedView = UIView()
    var disposeBag = DisposeBag()

    private var selectedStatusOptions: Set<String> = []
    private var selectedCategoryOptions: Set<String> = []
    private var tagSection: TagSection?

    var onSave: (([String]) -> Void)?
    var onDismiss: (() -> Void)?

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupViews()
        setupCollectionView()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showBottomSheet()
    }

    // MARK: - Setup
    private func setupViews() {
        view.addSubview(dimmedView)
        dimmedView.backgroundColor = .black.withAlphaComponent(0.4)
        dimmedView.alpha = 0

        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped))
        dimmedView.addGestureRecognizer(tapGesture)
        dimmedView.isUserInteractionEnabled = true

        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(view.bounds.height * 0.45)  // 높이 조정
            make.bottom.equalTo(view.snp.bottom)
        }

//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
//        panGesture.delegate = self
//        mainView.addGestureRecognizer(panGesture)
    }

    private func setupCollectionView() {
        mainView.contentCollectionView.dataSource = self
        mainView.contentCollectionView.delegate = self
        mainView.contentCollectionView.register(TagSectionCell.self, forCellWithReuseIdentifier: TagSectionCell.identifiers)
    }

    private func bind() {
        // Close Button
        mainView.closeButton.rx.tap
            .bind { [weak self] in
                self?.hideBottomSheet()
            }
            .disposed(by: disposeBag)

        // Save Button
        mainView.saveButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                let selectedOptions = self.mainView.segmentedControl.selectedSegmentIndex == 0 ?
                Array(self.selectedStatusOptions) : Array(self.selectedCategoryOptions)
                self.onSave?(selectedOptions)
                self.hideBottomSheet()
            }
            .disposed(by: disposeBag)

        // Reset Button
        mainView.resetButton.rx.tap
            .bind { [weak self] in
                self?.selectedStatusOptions.removeAll()
                self?.selectedCategoryOptions.removeAll()
                self?.updateButtonStates()
                self?.updateCollectionView()
            }
            .disposed(by: disposeBag)

        // Segment Control
        mainView.segmentedControl.rx.selectedSegmentIndex
            .bind { [weak self] index in
                self?.mainView.updateContentVisibility(isCategorySelected: index == 1)
                self?.updateCollectionView()
            }
            .disposed(by: disposeBag)
    }

    private func updateCollectionView() {
        let isStatusTab = mainView.segmentedControl.selectedSegmentIndex == 0
        let items = isStatusTab ?
            ["전체", "운영", "종료"] :
            ["게임", "라이프스타일", "반려동물", "뷰티", "스포츠", "애니메이션",
             "엔터테이먼트", "여행", "예술", "음식/요리", "키즈", "패션"]

        let selectedItems = isStatusTab ? selectedStatusOptions : selectedCategoryOptions

        tagSection = TagSection(inputDataList: items.map {
            TagSectionCell.Input(
                title: $0,
                isSelected: selectedItems.contains($0),
                id: nil
            )
        })

        mainView.contentCollectionView.reloadData()
        mainView.filterChipsView.updateChips(with: Array(selectedItems))

    }
    private func toggleStatusOption(_ option: String) {
        if selectedStatusOptions.contains(option) {
            selectedStatusOptions.remove(option)
        } else {
            if option == "전체" {
                selectedStatusOptions = ["전체"]
            } else {
                selectedStatusOptions.remove("전체")
                selectedStatusOptions.insert(option)
            }
        }
    }

    private func toggleCategoryOption(_ option: String) {
        if selectedCategoryOptions.contains(option) {
            selectedCategoryOptions.remove(option)
        } else {
            selectedCategoryOptions.insert(option)
        }
    }
    private func updateButtonStates() {
        let hasSelectedOptions = !selectedStatusOptions.isEmpty || !selectedCategoryOptions.isEmpty
        mainView.saveButton.isEnabled = hasSelectedOptions
        mainView.resetButton.isEnabled = hasSelectedOptions

        if hasSelectedOptions {
            mainView.saveButton.backgroundColor = .blu500
            mainView.saveButton.setTitleColor(.white, for: .normal)
        } else {
            mainView.saveButton.backgroundColor = .g100
            mainView.saveButton.setTitleColor(.g400, for: .disabled)
        }
        let selectedOptions = mainView.segmentedControl.selectedSegmentIndex == 0 ?
                Array(selectedStatusOptions) : Array(selectedCategoryOptions)
            mainView.filterChipsView.updateChips(with: selectedOptions)
        
    }


//    private func updateButtonStates() {
//        let hasSelectedOptions = !selectedStatusOptions.isEmpty || !selectedCategoryOptions.isEmpty
//        mainView.updateButtonStates(isEnabled: hasSelectedOptions)
//    }

    // MARK: - Gestures
    @objc private func dimmedViewTapped() {
        hideBottomSheet()
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)

        switch gesture.state {
        case .changed:
            guard translation.y >= 0 else { return }
            mainView.transform = CGAffineTransform(translationX: 0, y: translation.y)
            dimmedView.alpha = 1 - (translation.y / 500)

        case .ended:
            let velocity = gesture.velocity(in: view)
            if translation.y > 150 || velocity.y > 1000 {
                hideBottomSheet()
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.mainView.transform = .identity
                    self.dimmedView.alpha = 1
                }
            }

        default:
            break
        }
    }

    // MARK: - Animation Methods
    func showBottomSheet() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.dimmedView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }

    func hideBottomSheet() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.dimmedView.alpha = 0
            self.mainView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        } completion: { _ in
            self.dismiss(animated: false)
            self.onDismiss?()
        }
    }
}
extension AdminBottomSheetViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagSection?.inputDataList.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TagSectionCell.identifiers,
            for: indexPath
        ) as? TagSectionCell else {
            return UICollectionViewCell()
        }

        if let input = tagSection?.inputDataList[indexPath.item] {
            cell.injection(with: input)
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension AdminBottomSheetViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let title = tagSection?.inputDataList[indexPath.item].title else { return }

        if mainView.segmentedControl.selectedSegmentIndex == 0 {
            toggleStatusOption(title)
        } else {
            toggleCategoryOption(title)
        }

        updateCollectionView()
        updateButtonStates()
    }
}
extension AdminBottomSheetViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // 세그먼트 컨트롤이나 컬렉션뷰를 터치했을 때는 pan gesture 무시
        if let touchView = touch.view {
            if touchView == mainView.segmentedControl ||
               touchView.isDescendant(of: mainView.segmentedControl) ||
               touchView == mainView.contentCollectionView ||
               touchView.isDescendant(of: mainView.contentCollectionView) {
                return false
            }
        }
        return true
    }
}
