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
    private var bottomConstraint: Constraint?
    private var containerHeightConstraint: Constraint?

    let containerView = FilterBottomSheetView()
    private var containerViewBottomConstraint: NSLayoutConstraint?
    private var savedLocation: String?
    private var savedCategory: String?
    private var tagSection: TagSection?

    private lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.4)
        view.alpha = 0
        return view
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
        setupLayout()
        setupGestures()
        setupCollectionView()
        containerView.isUserInteractionEnabled = true
        containerView.filterChipsView.onRemoveChip = { [weak self] removedOption in
            guard let self = self, let reactor = self.reactor else { return }

            let isCategory = reactor.currentState.selectedCategories.contains(removedOption)
            let isSubRegion = reactor.currentState.selectedSubRegions.contains(removedOption)

            if isCategory {
                reactor.action.onNext(.toggleCategory(removedOption))
            } else if isSubRegion {
                reactor.action.onNext(.toggleSubRegion(removedOption))
            }

            DispatchQueue.main.async {
                let activeSegment = reactor.currentState.activeSegment

                if isCategory && activeSegment == 1 {
                    self.containerView.categoryCollectionView.reloadData()
                } else if isSubRegion && activeSegment == 0 {
                    if let selectedIndex = reactor.currentState.selectedLocationIndex {
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
                    }
                }

                self.updateContainerHeight()
                self.containerView.updateContentVisibility(isCategorySelected: activeSegment == 1)
            }
        }

    }

    // MARK: - Setup
    private func setupLayout() {
        view.backgroundColor = .clear

        view.addSubview(dimmedView)
        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            containerHeightConstraint = make.height.greaterThanOrEqualTo(400).constraint
            bottomConstraint = make.bottom.equalToSuperview().offset(UIScreen.main.bounds.height).constraint
        }

        view.sendSubviewToBack(dimmedView)
        dimmedView.isUserInteractionEnabled = true

    }

    private func setupCollectionView() {
        containerView.categoryCollectionView.dataSource = self
        containerView.categoryCollectionView.delegate = self
    }

    // MARK: - Binding
    func bind(reactor: Reactor) {
        // 1. 세그먼트 컨트롤 바인딩
        containerView.segmentedControl.rx.selectedSegmentIndex
            .map { Reactor.Action.segmentChanged($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 2. 리셋 버튼 바인딩
        containerView.resetButton.rx.tap
           .do(onNext: { [weak self] _ in
               guard let self = self,
                     let reactor = self.reactor,
                     let selectedIndex = reactor.currentState.selectedLocationIndex else { return }

               let location = reactor.currentState.locations[selectedIndex]
               // 현재 location에 대한 configure 재설정
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


        // 5. 탭 변경
        reactor.state.map { $0.activeSegment }
            .distinctUntilChanged()
            .bind { [weak self] activeSegment in
                guard let self = self else { return }
                if activeSegment == 0 {
                    let dynamicHeight = self.containerView.balloonBackgroundView.calculateHeight()
                    self.containerView.updateBalloonHeight(isHidden: false, dynamicHeight: dynamicHeight)
                } else if activeSegment == 1 {
                    self.containerView.updateBalloonHeight(isHidden: true)
                }
                self.containerView.updateContentVisibility(isCategorySelected: activeSegment == 1)

                // 여기에 컨테이너 높이 업데이트 추가
                self.updateContainerHeight()
            }
            .disposed(by: disposeBag)


        // 6. 위치 데이터 바인딩
        let locations = reactor.state
            .map { $0.locations }
            .distinctUntilChanged()
            .share(replay: 1)
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


        let locationAndSubRegions = reactor.state
            .map { ($0.selectedLocationIndex, $0.selectedSubRegions) }
            .distinctUntilChanged { prev, curr in
                let isIndexSame = prev.0 == curr.0
                let isSubRegionsSame = prev.1 == curr.1
                return isIndexSame && isSubRegionsSame
            }
            .share(replay: 1)

        locationAndSubRegions
            .observe(on: MainScheduler.instance)
            .bind { [weak self] data in
                guard let self = self, let reactor = self.reactor else { return }
                let (selectedIndexOptional, selectedSubRegions) = data


                guard let selectedIndex = selectedIndexOptional,
                      selectedIndex >= 0,
                      selectedIndex < reactor.currentState.locations.count else { return }

                let location = reactor.currentState.locations[selectedIndex]
                self.containerView.balloonBackgroundView.configure(
                    for: location.main,                // 첫 번째 인자는 메인 지역(String)
                    subRegions: location.sub,            // 두 번째 인자는 [String]
                    selectedRegions: selectedSubRegions, // 세 번째 인자는 [String]
                    selectionHandler: { [weak self] subRegion in
                        self?.reactor?.action.onNext(.toggleSubRegion(subRegion))
                    },
                    allSelectionHandler: { [weak self] in
                        self?.reactor?.action.onNext(.toggleAllSubRegions)
                    }
                )


                if let button = self.containerView.locationContentView.subviews[selectedIndex] as? UIButton {
                    self.containerView.updateBalloonPosition(for: button)
                }

                DispatchQueue.main.async {
                    let dynamicHeight = self.containerView.balloonBackgroundView.calculateHeight()
                    self.containerView.updateBalloonHeight(isHidden: false, dynamicHeight: dynamicHeight)
                }

                self.containerView.balloonBackgroundView.isHidden = false
            }
            .disposed(by: disposeBag)

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



        reactor.state.map { $0.selectedSubRegions + $0.selectedCategories }
            .distinctUntilChanged()
            .bind { [weak self] selectedOptions in
                UIView.performWithoutAnimation {
                    self?.containerView.filterChipsView.updateChips(with: selectedOptions)
                    self?.containerView.layoutIfNeeded()
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
                    // 저장된 지역 필터 설정
                    if !state.savedSubRegions.isEmpty {
                        state.savedSubRegions.forEach { region in
                            reactor.action.onNext(.toggleSubRegion(region))
                        }
                    }

                    // 저장된 카테고리 필터 설정
                    if !state.savedCategories.isEmpty {
                        state.savedCategories.forEach { category in
                            reactor.action.onNext(.toggleCategory(category))
                        }
                    }

                    // 지역이 선택되어 있다면 해당 지역 버튼도 활성화
                    if let locations = state.savedSubRegions.first?.split(separator: "/").first.map(String.init),
                       let index = reactor.currentState.locations.firstIndex(where: { $0.main == locations }) {
                        reactor.action.onNext(.selectLocation(index))
                    }
                })
                .disposed(by: disposeBag)

            Observable.combineLatest(
                reactor.state.map { $0.savedSubRegions }.distinctUntilChanged(),
                reactor.state.map { $0.savedCategories }.distinctUntilChanged()
            )
            .take(1)
            .subscribe(onNext: { [weak self] (subRegions, categories) in
                guard let self = self else { return }

                subRegions.forEach { region in
                    reactor.action.onNext(.toggleSubRegion(region))
                }

                categories.forEach { category in
                    reactor.action.onNext(.toggleCategory(category))
                }

                self.containerView.categoryCollectionView.reloadData()
                self.containerView.balloonBackgroundView.setNeedsDisplay()
            })
            .disposed(by: disposeBag)

    }

    private func updateContentVisibility(_ isCategoryTab: Bool, subRegionCount: Int) {
        UIView.animate(withDuration: 0.3) {
            self.containerView.updateContentVisibility(isCategorySelected: isCategoryTab)
            if !isCategoryTab {
                self.containerView.updateBalloonHeight(isHidden: false, dynamicHeight: subRegionCount > 0 ? self.containerView.balloonBackgroundView.calculateHeight() : 80)
            }
            self.view.layoutIfNeeded()
        }
    }
    func updateContainerHeight() {
        let contentHeight: CGFloat

        if containerView.segmentedControl.selectedSegmentIndex == 0 {
            // 지역탭일 때
            contentHeight = containerView.balloonBackgroundView.calculateHeight() +
                           containerView.filterChipsView.frame.height +
                           containerView.segmentedControl.frame.height +
                           containerView.saveButton.frame.height + 100 // 패딩 및 여유 높이
        } else {
            // 카테고리탭일 때
            contentHeight = containerView.categoryCollectionView.contentSize.height +
                           containerView.filterChipsView.frame.height +
                           containerView.segmentedControl.frame.height +
                           containerView.saveButton.frame.height + 100
        }

        // 최소 400, 최대는 화면 높이의 80%로 제한
        let finalHeight = min(max(contentHeight, 400), UIScreen.main.bounds.height * 0.8)
        containerHeightConstraint?.update(offset: finalHeight)

        // 컨테이너 크기 변경 후 레이아웃 업데이트
        view.layoutIfNeeded()
    }


    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapDimmedView))
        tapGesture.delegate = self
        dimmedView.addGestureRecognizer(tapGesture)
        dimmedView.isUserInteractionEnabled = true

        // 패닝 제스처는 유지
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        containerView.addGestureRecognizer(panGesture)
    }

    @objc private func handleDimmedViewTap() {
           hideBottomSheet()
       }
    func showBottomSheet() {
        guard let reactor = reactor else { return }

        // 1. 이전에 저장된 지역 필터가 있다면 해당 지역 버튼 활성화
        if let locations = reactor.currentState.savedSubRegions.first?.split(separator: "/").first.map(String.init),
           let index = reactor.currentState.locations.firstIndex(where: { $0.main == locations }) {
            reactor.action.onNext(.selectLocation(index))


        }

        // 4. 필터 칩 뷰 업데이트
        containerView.update(
            locationText: reactor.currentState.savedSubRegions.joined(separator: ", "),
            categoryText: reactor.currentState.savedCategories.joined(separator: ", ")
        )

        // 5. 애니메이션
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.dimmedView.alpha = 1
            self.bottomConstraint?.update(offset: 0)
            self.view.layoutIfNeeded()
        }
    }



    func hideBottomSheet() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.dimmedView.alpha = 0
            self.bottomConstraint?.update(offset: UIScreen.main.bounds.height)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false)
            self.onDismiss?()
        }
    }

    @objc private func handleTapDimmedView() {
        hideBottomSheet()
    }

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
}

extension FilterBottomSheetViewController: UICollectionViewDataSource {
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
extension FilterBottomSheetViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let category = tagSection?.inputDataList[indexPath.item].title else { return }
        reactor?.action.onNext(.toggleCategory(category))
    }
}
extension FilterBottomSheetViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer.view == dimmedView {
            // 딤드 영역에서만 터치 인식
            let touchPoint = touch.location(in: view)
            return !containerView.frame.contains(touchPoint)
        }
        return true
    }
}
