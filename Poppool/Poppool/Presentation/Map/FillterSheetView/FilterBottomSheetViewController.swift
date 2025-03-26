
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class FilterBottomSheetViewController: UIViewController, View {
    typealias Reactor = FilterBottomSheetReactor
    typealias FilterData = (locations: [String], categories: [String])

    // MARK: - Properties
    var disposeBag = DisposeBag()
    var onSave: ((FilterData) -> Void)?
    var onDismiss: (() -> Void)?

    // Container height를 업데이트할 때 SnapKit Constraint를 직접 저장해 둠
    private var bottomConstraint: Constraint?
    private var containerHeightConstraint: Constraint?

    // 바텀시트 실제 UI
    let containerView = FilterBottomSheetView()

    // 필요하다면 다른 속성들
    private var savedLocation: String?
    private var savedCategory: String?
    private var tagSection: TagSection?

    private lazy var dimmedView: UIControl = {
        let control = UIControl()
        control.backgroundColor = .black.withAlphaComponent(0.4)
        control.alpha = 0
        control.addTarget(self, action: #selector(hideBottomSheet), for: .touchUpInside)
        return control
    }()


    // MARK: - Initialization
    init(reactor: Reactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()   // 오토레이아웃
        setupGestures()
        setupCollectionView()

        // ChipsView에서 필터 제거 로직
        containerView.filterChipsView.onRemoveChip = { [weak self] removedOption in
            guard let self = self, let reactor = self.reactor else { return }

            if reactor.currentState.selectedCategories.contains(removedOption) {
                reactor.action.onNext(.toggleCategory(removedOption))
            } else if reactor.currentState.selectedSubRegions.contains(removedOption) {
                reactor.action.onNext(.toggleSubRegion(removedOption))

                let currentSegment = self.containerView.segmentedControl.selectedSegmentIndex
                if currentSegment == 0 {
                    self.updateUIForCurrentTab(segment: currentSegment)
                }
            }
        }
    }


    // MARK: - Setup Layout
    private func setupLayout() {
        view.backgroundColor = .clear

        view.addSubview(dimmedView)
        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            containerHeightConstraint = make.height.equalTo(UIScreen.main.bounds.height * 0.7).constraint

            bottomConstraint = make.bottom.equalToSuperview().offset(UIScreen.main.bounds.height).constraint
        }

        containerView.isUserInteractionEnabled = true
    }

    // MARK: - Setup Gestures
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideBottomSheet))
        tapGesture.delegate = self
        dimmedView.addGestureRecognizer(tapGesture)
    }



//    @objc private func didTapDimmedView() {
//        // 딤드 뷰 탭 → 시트 닫기
//        hideBottomSheet()
//    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)

        switch gesture.state {
        case .changed:
            guard translation.y >= 0 else { return }
            bottomConstraint?.update(offset: translation.y)
            view.layoutIfNeeded()

        case .ended:
            let velocity = gesture.velocity(in: view)
            if translation.y > 150 || velocity.y > 1000 {
                // (pan) 시트 끌어내리면 닫기
                let currentSegment = containerView.segmentedControl.selectedSegmentIndex
                updateUIForCurrentTab(segment: currentSegment)
                hideBottomSheet()
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.bottomConstraint?.update(offset: 0)
                    self.view.layoutIfNeeded()
                }
            }
        default:
            break
        }
    }

    // MARK: - Public Show / Hide
    func showBottomSheet() {
        guard let reactor = reactor else { return }

        // (A) location 초기선택
        if let locations = reactor.currentState.savedSubRegions.first?.split(separator: "/").first.map(String.init),
           let index = reactor.currentState.locations.firstIndex(where: { $0.main == locations }) {
            reactor.action.onNext(.selectLocation(index))
        }

        // (B) 필터 칩 뷰 업데이트
        containerView.update(
            locationText: reactor.currentState.savedSubRegions.joined(separator: ", "),
            categoryText: reactor.currentState.savedCategories.joined(separator: ", ")
        )

        // (C) 시트 애니메이션
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.dimmedView.alpha = 1
            self.bottomConstraint?.update(offset: 0)
            self.view.layoutIfNeeded()
        }
    }

    @objc func hideBottomSheet() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.dimmedView.alpha = 0
            self.bottomConstraint?.update(offset: UIScreen.main.bounds.height)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false)
            self.onDismiss?()
        }
    }

    // MARK: - UI Update (for tabs)
    private func updateUIForCurrentTab(segment: Int) {
        UIView.performWithoutAnimation {
            // 탭 전환 시 모든 뷰 숨김
            containerView.categoryCollectionView.isHidden = true
            containerView.locationScrollView.isHidden = true
            containerView.balloonBackgroundView.isHidden = true

            if segment == 0 {
                // 지역 탭
                containerView.locationScrollView.isHidden = false
                if let selectedLocationIndex = reactor?.currentState.selectedLocationIndex,
                   let locations = reactor?.currentState.locations,
                   selectedLocationIndex >= 0, selectedLocationIndex < locations.count {

                    let location = locations[selectedLocationIndex]
                    containerView.balloonBackgroundView.configure(
                        for: location.main,
                        subRegions: location.sub,
                        selectedRegions: reactor?.currentState.selectedSubRegions ?? [],
                        selectionHandler: { [weak self] subRegion in
                            self?.reactor?.action.onNext(.toggleSubRegion(subRegion))
                        },
                        allSelectionHandler: { [weak self] in
                            self?.reactor?.action.onNext(.toggleAllSubRegions)
                        }
                    )

                    containerView.balloonBackgroundView.isHidden = false
                    let dynamicHeight = containerView.balloonBackgroundView.calculateHeight()
                    containerView.updateBalloonHeight(isHidden: false, dynamicHeight: dynamicHeight)
                }
            } else {
                           containerView.categoryCollectionView.isHidden = false
                           containerView.updateBalloonHeight(isHidden: true)

                           // ★ 카테고리 탭에 들어오면, 한 번 더 layout 후 시트 높이 갱신
                           DispatchQueue.main.async {
                               // 콜렉션뷰 레이아웃 강제 반영
                               self.containerView.categoryCollectionView.layoutIfNeeded()
                               let contentHeight = self.containerView.categoryCollectionView.contentSize.height

                               // 콜렉션뷰 높이 업데이트
                               self.containerView.categoryCollectionView.snp.updateConstraints { make in
                                   make.height.equalTo(contentHeight + 40)
                               }
                               self.containerView.layoutIfNeeded()

                               // 시트 높이 갱신
                               self.updateContainerHeight()
                           }
                       }

                       containerView.layoutIfNeeded()
                       view.layoutIfNeeded()
                   }

                   // 시트 높이 업데이트
                   updateContainerHeight()
               }

    private func updateContainerHeight() {
        let segmentIndex = containerView.segmentedControl.selectedSegmentIndex

        let headerHeight = containerView.headerView.frame.height
        let segmentHeight = containerView.segmentedControl.frame.height
        let filterHeight = containerView.filterChipsView.frame.height
        let buttonHeight: CGFloat = 52
        let padding: CGFloat = 60

        let contentHeight: CGFloat
        if segmentIndex == 0 {
            let locationHeight = containerView.locationScrollView.frame.height
            let balloonHeight = containerView.balloonBackgroundView.isHidden ? 0 : containerView.balloonBackgroundView.calculateHeight()
            contentHeight = headerHeight + segmentHeight + locationHeight + balloonHeight + filterHeight + buttonHeight + padding
        } else {
            let categoryHeight = containerView.categoryCollectionView.frame.height
            contentHeight = headerHeight + segmentHeight + categoryHeight + filterHeight + buttonHeight + padding
        }

        let minHeight: CGFloat = 300
        let maxHeight = UIScreen.main.bounds.height * 0.7
        let newHeight = min(max(contentHeight, minHeight), maxHeight)

        UIView.animate(withDuration: 0.2) {
            self.containerHeightConstraint?.update(offset: newHeight)
            self.view.layoutIfNeeded()
        }
    }

    private func setupCollectionView() {
        containerView.categoryCollectionView.dataSource = self
        containerView.categoryCollectionView.delegate = self
    }

    // MARK: - Reactor Binding
    func bind(reactor: Reactor) {
        // (1) 세그먼트 컨트롤
        containerView.segmentedControl.rx.selectedSegmentIndex
            .do(onNext: { [weak self] segmentIndex in
                self?.updateUIForCurrentTab(segment: segmentIndex)
                self?.updateContainerHeight()
            })
            .map { Reactor.Action.segmentChanged($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // (2) 리셋 버튼
        containerView.resetButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let self = self,
                      let reactor = self.reactor,
                      let selectedIndex = reactor.currentState.selectedLocationIndex else { return }

                let location = reactor.currentState.locations[selectedIndex]
                self.containerView.balloonBackgroundView.configure(
                    for: location.main,
                    subRegions: location.sub,
                    selectedRegions: reactor.currentState.selectedSubRegions,
                    selectionHandler: { [weak self] subRegion in
                        self?.reactor?.action.onNext(.toggleSubRegion(subRegion))
                    },
                    allSelectionHandler: { [weak self] in
                        self?.reactor?.action.onNext(.toggleAllSubRegions)
                    }
                )
            })
            .map { Reactor.Action.resetFilters }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // (3) 저장
        containerView.saveButton.rx.tap
            .bind { [weak self] _ in
                guard let self = self, let reactor = self.reactor else { return }
                let filterData: FilterData = (
                    locations: reactor.currentState.selectedSubRegions,
                    categories: reactor.currentState.selectedCategories
                )
                self.onSave?(filterData)
                reactor.action.onNext(.applyFilters(filterData.locations + filterData.categories))
                self.hideBottomSheet()
            }
            .disposed(by: disposeBag)

        // (4) 닫기
        containerView.closeButton.rx.tap
            .bind { [weak self] _ in
                guard let self = self, let reactor = self.reactor else { return }
                let filterData: FilterData = (
                    locations: reactor.currentState.selectedSubRegions,
                    categories: reactor.currentState.selectedCategories
                )
                self.onSave?(filterData)
                self.hideBottomSheet()
            }
            .disposed(by: disposeBag)

        // (5) 액티브 세그먼트
        reactor.state.map { $0.activeSegment }
            .distinctUntilChanged()
            .bind { [weak self] activeSegment in
                guard let self = self else { return }
                if activeSegment == 0 {
                    let dynamicHeight = self.containerView.balloonBackgroundView.calculateHeight()
                    self.containerView.updateBalloonHeight(isHidden: false, dynamicHeight: dynamicHeight)
                } else {
                    self.containerView.updateBalloonHeight(isHidden: true)
                }
                self.containerView.updateContentVisibility(isCategorySelected: activeSegment == 1)
            }
            .disposed(by: disposeBag)

        // (6) 위치 리스트
        let locations = reactor.state.map { $0.locations }.distinctUntilChanged().share(replay: 1)
        locations
            .observe(on: MainScheduler.instance)
            .bind { [weak self] locations in
                self?.containerView.setupLocationScrollView(locations: locations) { [weak self] index, button in
                    guard let self = self else { return }
                    if index == 0 {
                        if let selectedSubRegions = self.reactor?.currentState.selectedSubRegions,
                           !selectedSubRegions.isEmpty {
                            selectedSubRegions.forEach { region in
                                self.reactor?.action.onNext(.toggleSubRegion(region))
                            }
                        }
                    }
                    self.reactor?.action.onNext(.selectLocation(index))
                    self.containerView.updateBalloonPosition(for: button)
                }
            }
            .disposed(by: disposeBag)

        // (7) locationAndSubRegions
        reactor.state.map { ($0.selectedLocationIndex, $0.selectedSubRegions) }
            .distinctUntilChanged { prev, curr in
                let isIndexSame = prev.0 == curr.0
                let isSubRegionsSame = prev.1 == curr.1
                return isIndexSame && isSubRegionsSame
            }
            .share(replay: 1)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] data in
                guard let self = self, let reactor = self.reactor else { return }
                let (selectedIndexOptional, selectedSubRegions) = data

                guard let selectedIndex = selectedIndexOptional,
                      selectedIndex >= 0,
                      selectedIndex < reactor.currentState.locations.count else { return }

                // 현재 탭이 지역(0)인지 체크해서 풍선 뷰 노출할지 결정
                let currentSegment = self.containerView.segmentedControl.selectedSegmentIndex
                if currentSegment != 0 {
                    return
                }

                let location = reactor.currentState.locations[selectedIndex]
                self.containerView.balloonBackgroundView.configure(
                    for: location.main,
                    subRegions: location.sub,
                    selectedRegions: selectedSubRegions,
                    selectionHandler: { [weak self] subRegion in
                        self?.reactor?.action.onNext(.toggleSubRegion(subRegion))
                    },
                    allSelectionHandler: { [weak self] in
                        self?.reactor?.action.onNext(.toggleAllSubRegions)
                    }
                )

                // 화살표 위치
                let subviews = self.containerView.locationContentView.subviews
                if selectedIndex < subviews.count,
                   let button = subviews[selectedIndex] as? UIButton {
                    self.containerView.updateBalloonPosition(for: button)
                }

                DispatchQueue.main.async {
                    let dynamicHeight = self.containerView.balloonBackgroundView.calculateHeight()
                    self.containerView.updateBalloonHeight(isHidden: false, dynamicHeight: dynamicHeight)
                    self.updateContainerHeight()
                }
                self.containerView.balloonBackgroundView.isHidden = false
            }
            .disposed(by: disposeBag)

        // (8) 카테고리 바인딩
        Observable.combineLatest(
            reactor.state.map { $0.categories }.distinctUntilChanged(),
            reactor.state.map { $0.selectedCategories }.distinctUntilChanged()
        )
        .observe(on: MainScheduler.instance)
        .bind { [weak self] (categories, selectedCategories) in
            self?.tagSection = TagSection(inputDataList: categories.map {
                TagSectionCell.Input(
                    title: $0,
                    isSelected: selectedCategories.contains($0),
                    id: nil
                )
            })
            self?.containerView.categoryCollectionView.reloadData()

            DispatchQueue.main.async {
                let contentHeight = self?.containerView.categoryCollectionView.collectionViewLayout.collectionViewContentSize.height ?? 0
                self?.containerView.categoryCollectionView.snp.updateConstraints { make in
                    make.height.equalTo(contentHeight + 40)
                }
                self?.containerView.layoutIfNeeded()
            }
        }
        .disposed(by: disposeBag)

        // (9) 필터칩 업데이트
        reactor.state.map { $0.selectedSubRegions + $0.selectedCategories }
            .distinctUntilChanged()
            .bind { [weak self] selectedOptions in
                UIView.performWithoutAnimation {
                    self?.containerView.filterChipsView.updateChips(with: selectedOptions)
                    self?.containerView.layoutIfNeeded()
                    self?.updateContainerHeight()
                }
            }
            .disposed(by: disposeBag)

        reactor.state.map { $0.savedSubRegions + $0.savedCategories }
            .distinctUntilChanged()
            .bind { [weak self] selectedOptions in
                UIView.performWithoutAnimation {
                    self?.containerView.filterChipsView.updateChips(with: selectedOptions)
                    self?.containerView.layoutIfNeeded()
                }
            }
            .disposed(by: disposeBag)

        reactor.state.map { $0.isSaveEnabled }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] isEnabled in
                guard let self = self else { return }
                if isEnabled {
                    self.containerView.saveButton.isEnabled = true
                    self.containerView.saveButton.backgroundColor = .blu500
                    self.containerView.saveButton.setTitleColor(.white, for: .normal)
                } else {
                    self.containerView.saveButton.isEnabled = false
                    self.containerView.saveButton.backgroundColor = .g100
                    self.containerView.saveButton.setTitleColor(.g400, for: .disabled)
                }
            }
            .disposed(by: disposeBag)

        Observable.just(())
            .withLatestFrom(reactor.state)
            .take(1)
            .subscribe(onNext: { [weak self] state in
                // 저장된 지역 필터
                if !state.savedSubRegions.isEmpty {
                    state.savedSubRegions.forEach { region in
                        reactor.action.onNext(.toggleSubRegion(region))
                    }
                }
                // 저장된 카테고리 필터
                if !state.savedCategories.isEmpty {
                    state.savedCategories.forEach { category in
                        reactor.action.onNext(.toggleCategory(category))
                    }
                }

                // 위치 선택
                if let locMain = state.savedSubRegions.first?.split(separator: "/").first.map(String.init),
                   let idx = reactor.currentState.locations.firstIndex(where: { $0.main == locMain }) {
                    reactor.action.onNext(.selectLocation(idx))
                }
            })
            .disposed(by: disposeBag)

        // (12) 추가 combineLatest... (생략)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension FilterBottomSheetViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: self.view)

        if containerView.frame.contains(point) {
            return false
        }

        return true
    }
}

// MARK: - UICollectionViewDataSource
extension FilterBottomSheetViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return tagSection?.inputDataList.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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

// MARK: - UICollectionViewDelegateFlowLayout
extension FilterBottomSheetViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let category = tagSection?.inputDataList[indexPath.item].title else { return }
        reactor?.action.onNext(.toggleCategory(category))
    }
}
