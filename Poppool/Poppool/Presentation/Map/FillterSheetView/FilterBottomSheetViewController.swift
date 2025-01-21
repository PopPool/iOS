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
    }

    // MARK: - Setup
    private func setupLayout() {
        view.backgroundColor = .clear
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true

        view.addSubview(dimmedView)
        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height * 0.85)
            bottomConstraint = make.bottom.equalToSuperview().offset(UIScreen.main.bounds.height).constraint
        }
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

               let location = reactor.currentState.locations[selectedIndex]  // Optional 체크 필요 없음

               // 현재 location에 대한 configure 재설정
               self.containerView.balloonBackgroundView.configure(
                   with: location.sub,
                   selectedRegions: [], // 빈 배열로 초기화
                   mainRegionTitle: location.main,
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
                self.hideBottomSheet()
            }
            .disposed(by: disposeBag)


        containerView.closeButton.rx.tap
            .withUnretained(self)
            .bind { owner, _ in
                owner.hideBottomSheet()
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
                           with: location.sub,
                           selectedRegions: selectedSubRegions,  // selectedSubRegions가 빈 배열이면 모두 선택 해제 상태가 됨
                           mainRegionTitle: location.main,
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
            .observe(on: MainScheduler.instance)
            .bind { [weak self] selectedOptions in
                self?.containerView.filterChipsView.updateChips(with: selectedOptions)
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

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapDimmedView))
        dimmedView.addGestureRecognizer(tapGesture)
        dimmedView.isUserInteractionEnabled = true

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        containerView.addGestureRecognizer(panGesture)
    }

    func showBottomSheet() {
        containerView.update(locationText: savedLocation, categoryText: savedCategory)
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
//        print("[DEBUG] 👆 Category Option Selected: \(category)")
//        print("[DEBUG] 💾 Current Saved Filters:")
//        print("[DEBUG] 📍 Location: \(reactor?.currentState.selectedSubRegions ?? [])")
//        print("[DEBUG] 🏷️ Category: \(reactor?.currentState.selectedCategories ?? [])")
        reactor?.action.onNext(.toggleCategory(category))
    }
}
