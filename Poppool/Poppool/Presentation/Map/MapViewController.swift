import UIKit
import FloatingPanel
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import GoogleMaps

final class MapViewController: BaseViewController, View {
    typealias Reactor = MapReactor
    
    var disposeBag = DisposeBag()
    let mainView = MapView()
    
    private var currentFilterBottomSheet: FilterBottomSheetViewController?
    private var filterChipsTopY: CGFloat = 0
    
    var fpc: FloatingPanelController?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
            let frameInView = self.mainView.filterChips.convert(self.mainView.filterChips.bounds, to: self.view)
            self.filterChipsTopY = frameInView.minY
            
            print("[DEBUG] filterChipsTopY after layout: \(self.filterChipsTopY)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    private func setUp() {
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 37.5666, longitude: 126.9784)
        let markerView = MapMarker()
        markerView.injection(with: .init(title: "서울", count: 3))
        marker.iconView = markerView
        marker.map = mainView.mapView
        markerView.frame = CGRect(x: 0, y: 0, width: 80, height: 28)
    }
    
    
    func bind(reactor: Reactor) {
        // 지역 필터 탭 이벤트
        mainView.filterChips.locationChip.rx.tap
            .map { Reactor.Action.filterTapped(.location) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 카테고리 필터 탭 이벤트
        mainView.filterChips.categoryChip.rx.tap
            .map { Reactor.Action.filterTapped(.category) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 리스트 버튼 탭 이벤트 - FloatingPanel 표시
        mainView.listButton.rx.tap
            .bind { [weak self] _ in
                guard let self = self else { return }
                
                let reactor = StoreListReactor()
                let listVC = StoreListViewController(reactor: reactor)
                
                let fpc = FloatingPanelController()
                self.fpc = fpc
                // Delegate 설정 (추후 패널 상태 변화 감지 시 사용 가능)
                fpc.delegate = self
                fpc.set(contentViewController: listVC)
                fpc.layout = StoreListPanelLayout()
                fpc.surfaceView.grabberHandle.isHidden = true
                       fpc.surfaceView.layer.shadowColor = UIColor.clear.cgColor
                       fpc.surfaceView.layer.shadowRadius = 0
                       fpc.surfaceView.layer.shadowOffset = .zero
                       fpc.surfaceView.layer.shadowOpacity = 0
                fpc.addPanel(toParent: self)

                
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.selectedLocationFilters }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] locationFilters in
                guard let self = self else { return }
                let locationText = locationFilters.isEmpty
                ? "지역선택"
                : (locationFilters.count > 1 ? "\(locationFilters[0]) 외 \(locationFilters.count - 1)개" : locationFilters[0])
                self.mainView.filterChips.update(locationText: locationText, categoryText: nil)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.selectedCategoryFilters }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] categoryFilters in
                print("[DEBUG] Updated Category Filters: \(categoryFilters)")
                
                guard let self = self else { return }
                let categoryText = categoryFilters.isEmpty
                ? "카테고리"
                : (categoryFilters.count > 1 ? "\(categoryFilters[0]) 외 \(categoryFilters.count - 1)개" : categoryFilters[0])
                self.mainView.filterChips.update(locationText: nil, categoryText: categoryText)
            }
            .disposed(by: disposeBag)
        
        mainView.filterChips.onRemoveLocation = {
            reactor.action.onNext(.clearFilters(.location))
        }
        mainView.filterChips.onRemoveCategory = {
            reactor.action.onNext(.clearFilters(.category))
        }
        
        Observable.combineLatest(
            reactor.state.map { $0.selectedLocationFilters.isEmpty },
            reactor.state.map { $0.selectedCategoryFilters.isEmpty }
        )
        .observe(on: MainScheduler.instance)
        .bind { [weak self] isLocationEmpty, isCategoryEmpty in
            guard let self = self else { return }
            if isLocationEmpty {
                self.mainView.filterChips.update(locationText: "지역선택", categoryText: nil)
            }
            if isCategoryEmpty {
                self.mainView.filterChips.update(locationText: nil, categoryText: "카테고리")
            }
        }
        .disposed(by: disposeBag)
        
        reactor.state.map { $0.activeFilterType }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] filterType in
                guard let self = self else { return }
                if let filterType = filterType {
                    self.presentFilterBottomSheet(for: filterType)
                } else {
                    self.dismissFilterBottomSheet()
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    func presentFilterBottomSheet(for filterType: FilterType) {
        // Create and set up the bottom sheet
        let sheetReactor = FilterBottomSheetReactor()
        let viewController = FilterBottomSheetViewController(reactor: sheetReactor)

        let initialIndex = (filterType == .location) ? 0 : 1
        viewController.containerView.segmentedControl.selectedSegmentIndex = initialIndex
        sheetReactor.action.onNext(FilterBottomSheetReactor.Action.segmentChanged(initialIndex))

        // Update the onSave closure to maintain both filter types
        viewController.onSave = { [weak self] (selectedOptions: [String]) in
            guard let self = self else { return }

            // Update only the specific filter type while preserving the other
            self.reactor?.action.onNext(.filterUpdated(filterType, selectedOptions))
            self.reactor?.action.onNext(.filterTapped(nil))
        }

        viewController.onDismiss = { [weak self] in
            self?.reactor?.action.onNext(.filterTapped(nil))
        }

        viewController.modalPresentationStyle = .overFullScreen
        present(viewController, animated: false) {
            viewController.showBottomSheet()
        }

        currentFilterBottomSheet = viewController
    }

    private func dismissFilterBottomSheet() {
        if let bottomSheet = currentFilterBottomSheet {
            bottomSheet.hideBottomSheet()
        }
        currentFilterBottomSheet = nil
    }
}

// MARK: - FloatingPanelControllerDelegate
extension MapViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        switch fpc.state {
        case .full:
            let panelY = fpc.surfaceView.frame.minY
            let stackY = mainView.topStackView.frame.maxY

            if panelY <= stackY {
                mainView.topStackView.layer.zPosition = 1
                fpc.surfaceView.layer.zPosition = 0
            }

            mainView.mapView.isHidden = true
            fpc.surfaceView.grabberHandle.isHidden = true

        case .half, .tip:
            // 원래 상태로 복구
            mainView.topStackView.layer.zPosition = 0
            mainView.mapView.isHidden = false
            fpc.surfaceView.grabberHandle.isHidden = false

        default:
            break
        }
    }

    func floatingPanelDidMove(_ fpc: FloatingPanelController) {
        let panelY = fpc.surfaceView.frame.minY
        let stackY = mainView.topStackView.frame.maxY

        // 패널이 스택뷰에 닿았을 때만 zPosition 변경
        if panelY <= stackY {
            mainView.topStackView.layer.zPosition = 1
            fpc.surfaceView.layer.zPosition = 0
        } else {
            mainView.topStackView.layer.zPosition = 0
        }
    }
}
