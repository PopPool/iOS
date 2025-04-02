import UIKit
import SnapKit
import ReactorKit
import RxSwift
import CoreLocation
import NMapsMap

final class MapGuideViewController: UIViewController, View {

    // MARK: - Constants
    private enum Constant {
        // Modal Card
        static let modalCardHeight: CGFloat = 408
        static let modalCardInitialBottomOffset: CGFloat = 408
        static let modalCardAnimationDuration: TimeInterval = 0.3
        static let modalCardAnimationDamping: CGFloat = 0.8
        static let modalCardAnimationInitialVelocity: CGFloat = 0.5

        // Top Container
        static let topContainerTopOffset: CGFloat = 20
        static let topContainerHeight: CGFloat = 44

        // Title Label
        static let titleLabelLeadingOffset: CGFloat = 20

        // Close Button
        static let closeButtonTrailingInset: CGFloat = 16
        static let closeButtonSize: CGFloat = 24

        // MapView
        static let mapViewTopOffset: CGFloat = 20
        static let mapViewHorizontalInset: CGFloat = 20
        static let mapViewHeight: CGFloat = 240
        static let mapZoomLevel: Double = 15.0

        // Expand Button
        static let expandButtonBottomOffset: CGFloat = -10
        static let expandButtonTrailingOffset: CGFloat = -10
        static let expandButtonSize: CGFloat = 32

        // Bottom Container
        static let bottomContainerTopOffset: CGFloat = 20
        static let bottomContainerHorizontalInset: CGFloat = 20
        static let bottomContainerHeight: CGFloat = 44
        static let bottomContainerBottomInset: CGFloat = 60

        // Throttle
        static let expandButtonThrottleMilliseconds: Int = 300
    }

    // MARK: - Properties
    var disposeBag = DisposeBag()
    private let popUpStoreId: Int64
    private var currentCarouselStores: [MapPopUpStore] = [] // 현재 선택된 스토어 목록

    // MARK: - UI Components
    private let dimmingView: UIView = {
        let viewInstance = UIView()
        viewInstance.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        viewInstance.alpha = 0
        return viewInstance
    }()

    private let modalCardView: UIView = {
        let viewInstance = UIView()
        viewInstance.backgroundColor = .white
        viewInstance.layer.cornerRadius = 16
        viewInstance.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        viewInstance.layer.shadowColor = UIColor.black.cgColor
        viewInstance.layer.shadowOpacity = 0.1
        viewInstance.layer.shadowOffset = .zero
        viewInstance.layer.shadowRadius = 8
        return viewInstance
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "찾아가는 길"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .black
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "icon_xmark")?.withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        return button
    }()

    private let mapView: NMFMapView = {
        let mapViewInstance = NMFMapView()
        mapViewInstance.layer.borderWidth = 1
        mapViewInstance.layer.borderColor = UIColor.g100.cgColor
        mapViewInstance.layer.cornerRadius = 12
        return mapViewInstance
    }()

    private let expandButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Expandable"), for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        return button
    }()

    private let promptLabel: UILabel = {
        let label = UILabel()
        label.text = "지도 앱으로\n바로 찾아볼까요?"
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .darkGray
        label.numberOfLines = 2
        return label
    }()

    private let naverButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "naver"), for: .normal)
        button.layer.cornerRadius = 24
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.g100.cgColor
        button.clipsToBounds = true
        return button
    }()

    private let kakaoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "kakao"), for: .normal)
        button.layer.cornerRadius = 24
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.g100.cgColor
        button.clipsToBounds = true
        return button
    }()

    private let appleButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "AppleMap"), for: .normal)
        button.layer.cornerRadius = 24
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.g100.cgColor
        button.clipsToBounds = true
        return button
    }()

    private var modalCardBottomConstraint: Constraint?

    // MARK: - Initializer
    init(popUpStoreId: Int64) {
        self.popUpStoreId = popUpStoreId
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTapGesture()
        presentModalCard()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .clear
        view.addSubview(dimmingView)
        dimmingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(modalCardView)
        modalCardView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Constant.modalCardHeight)
            self.modalCardBottomConstraint = make.bottom.equalToSuperview().offset(Constant.modalCardInitialBottomOffset).constraint
        }

        let topContainer = UIView()
        modalCardView.addSubview(topContainer)
        topContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constant.topContainerTopOffset)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Constant.topContainerHeight)
        }

        topContainer.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(Constant.titleLabelLeadingOffset)
        }

        topContainer.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(Constant.closeButtonTrailingInset)
            make.width.height.equalTo(Constant.closeButtonSize)
        }

        modalCardView.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.top.equalTo(topContainer.snp.bottom).offset(Constant.mapViewTopOffset)
            make.leading.trailing.equalToSuperview().inset(Constant.mapViewHorizontalInset)
            make.height.equalTo(Constant.mapViewHeight)
        }

        modalCardView.addSubview(expandButton)
        expandButton.snp.makeConstraints { make in
            make.bottom.equalTo(mapView.snp.bottom).offset(Constant.expandButtonBottomOffset)
            make.trailing.equalTo(mapView.snp.trailing).offset(Constant.expandButtonTrailingOffset)
            make.width.height.equalTo(Constant.expandButtonSize)
        }

        let bottomContainer = UIView()
        modalCardView.addSubview(bottomContainer)
        bottomContainer.snp.makeConstraints { make in
            make.top.equalTo(mapView.snp.bottom).offset(Constant.bottomContainerTopOffset)
            make.leading.trailing.equalToSuperview().inset(Constant.bottomContainerHorizontalInset)
            make.height.equalTo(Constant.bottomContainerHeight)
            make.bottom.equalTo(modalCardView.snp.bottom).inset(Constant.bottomContainerBottomInset)
        }

        bottomContainer.addSubview(promptLabel)
        promptLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        let appStack = UIStackView(arrangedSubviews: [naverButton, kakaoButton, appleButton])
        appStack.axis = .horizontal
        appStack.alignment = .center
        appStack.spacing = 16
        appStack.distribution = .fillEqually

        bottomContainer.addSubview(appStack)
        appStack.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            [naverButton, kakaoButton, appleButton].forEach { button in
                button.snp.makeConstraints { make in
                    make.size.equalTo(CGSize(width: 48, height: 48))
                }
            }
        }
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnDimmingView))
        dimmingView.addGestureRecognizer(tapGesture)
        dimmingView.isUserInteractionEnabled = true
    }

    private func presentModalCard() {
        self.dimmingView.alpha = 1
        UIView.animate(
            withDuration: Constant.modalCardAnimationDuration,
            delay: 0,
            usingSpringWithDamping: Constant.modalCardAnimationDamping,
            initialSpringVelocity: Constant.modalCardAnimationInitialVelocity,
            options: .curveEaseOut
        ) {
            self.modalCardBottomConstraint?.update(offset: 0)
            self.view.layoutIfNeeded()
        }
    }

    private func setupMarker(at coordinate: CLLocationCoordinate2D) {
        // 기존 마커 제거
        self.mapView.subviews.forEach { subview in
            if subview is NMFMarker {
                subview.removeFromSuperview()
            }
        }

        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
        marker.iconImage = NMFOverlayImage(name: "TapMarker")
        marker.width = 44
        marker.height = 44
        marker.anchor = CGPoint(x: 0.5, y: 1.0)
        marker.mapView = self.mapView

        let cameraUpdate = NMFCameraUpdate(
            scrollTo: NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude),
            zoomTo: Constant.mapZoomLevel
        )
        cameraUpdate.animation = .easeIn
        cameraUpdate.animationDuration = Constant.modalCardAnimationDuration
        self.mapView.moveCamera(cameraUpdate)
    }

    private func dismissModalCard() {
        UIView.animate(withDuration: Constant.modalCardAnimationDuration, delay: 0, options: .curveEaseIn) {
            self.dimmingView.alpha = 0
            self.modalCardBottomConstraint?.update(offset: Constant.modalCardInitialBottomOffset)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }

    @objc private func handleTapOnDimmingView(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.view)
        if !modalCardView.frame.contains(location) {
            dismissModalCard()
        }
    }
}

// MARK: - ReactorKit Binding
extension MapGuideViewController {
    func bind(reactor: MapGuideReactor) {
        reactor.action.onNext(.viewDidLoad(self.popUpStoreId))

        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismissModalCard()
            })
            .disposed(by: self.disposeBag)

        naverButton.rx.tap
            .map { Reactor.Action.openMapApp("naver") }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        kakaoButton.rx.tap
            .map { Reactor.Action.openMapApp("kakao") }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        appleButton.rx.tap
            .map { Reactor.Action.openMapApp("apple") }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        expandButton.rx.tap
            .throttle(.milliseconds(Constant.expandButtonThrottleMilliseconds), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let provider = ProviderImpl()
                let useCase = DefaultMapUseCase(repository: DefaultMapRepository(provider: provider))
                let directionRepository = DefaultMapDirectionRepository(provider: provider)
                let reactorInstance = MapReactor(useCase: useCase, directionRepository: directionRepository)

                if let selectedStore = self.currentCarouselStores.first {
                    reactorInstance.action.onNext(.didSelectItem(selectedStore))

                    let marker = NMFMarker()
                    marker.position = NMGLatLng(lat: selectedStore.latitude, lng: selectedStore.longitude)
                    marker.iconImage = NMFOverlayImage(name: "TapMarker")
                    marker.width = 44
                    marker.height = 44
                    marker.anchor = CGPoint(x: 0.5, y: 1.0)
                    marker.userInfo = ["storeData": selectedStore]

                    let fullScreenMapViewController = FullScreenMapViewController(store: selectedStore, existingMarker: marker)
                    fullScreenMapViewController.reactor = reactorInstance

                    let navigationController = UINavigationController(rootViewController: fullScreenMapViewController)
                    navigationController.modalPresentationStyle = .fullScreen
                    self.present(navigationController, animated: true)
                } else {
                    reactorInstance.action.onNext(.viewDidLoad(self.popUpStoreId))

                    reactorInstance.state
                        .map { $0.searchResult }
                        .distinctUntilChanged()
                        .compactMap { $0 }
                        .take(1)
                        .observe(on: MainScheduler.instance)
                        .subscribe(onNext: { store in
                            let marker = NMFMarker()
                            marker.position = NMGLatLng(lat: store.latitude, lng: store.longitude)
                            marker.iconImage = NMFOverlayImage(name: "TapMarker")
                            marker.width = 44
                            marker.height = 44
                            marker.anchor = CGPoint(x: 0.5, y: 1.0)
                            marker.userInfo = ["storeData": store]

                            let fullScreenMapViewController = FullScreenMapViewController(store: store, existingMarker: marker)
                            fullScreenMapViewController.reactor = reactorInstance

                            let navigationController = UINavigationController(rootViewController: fullScreenMapViewController)
                            navigationController.modalPresentationStyle = .fullScreen
                            self.present(navigationController, animated: true)
                        })
                        .disposed(by: self.disposeBag)
                }
            })
            .disposed(by: self.disposeBag)

        reactor.state
            .map { $0.destinationCoordinate }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] coordinate in
                self?.setupMarker(at: coordinate)
            })
            .disposed(by: self.disposeBag)

        reactor.state
            .map { $0.searchResult }
            .distinctUntilChanged()
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] store in
                self?.currentCarouselStores = [store]
            })
            .disposed(by: self.disposeBag)

        reactor.state
            .map { $0.shouldDismiss }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.dismissModalCard()
            })
            .disposed(by: self.disposeBag)
    }
}
