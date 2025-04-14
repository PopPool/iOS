import CoreLocation
import NMapsMap
import ReactorKit
import RxSwift
import SnapKit
import UIKit

final class MapGuideViewController: UIViewController, View {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private let popupStoreIdentifier: Int64
    private var currentCarouselStoreList: [MapPopUpStore] = [] // 현재 선택된 스토어 목록

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
        let labelInstance = UILabel()
        labelInstance.text = "찾아가는 길"
        labelInstance.font = UIFont.boldSystemFont(ofSize: 17)
        labelInstance.textColor = .black
        return labelInstance
    }()

    private let closeButton: UIButton = {
        let buttonInstance = UIButton(type: .system)
        let image = UIImage(named: "icon_xmark")?.withRenderingMode(.alwaysOriginal)
        buttonInstance.setImage(image, for: .normal)
        return buttonInstance
    }()

    private let mapView: NMFMapView = {
        let mapViewInstance = NMFMapView()
        mapViewInstance.layer.borderWidth = 1
        mapViewInstance.layer.borderColor = UIColor.g100.cgColor
        mapViewInstance.layer.cornerRadius = 12
        return mapViewInstance
    }()

    private let expandButton: UIButton = {
        let buttonInstance = UIButton()
        buttonInstance.setImage(UIImage(named: "Expandable"), for: .normal)
        buttonInstance.backgroundColor = UIColor.white
        buttonInstance.layer.cornerRadius = 16
        buttonInstance.clipsToBounds = true
        return buttonInstance
    }()

    private let promptLabel: UILabel = {
        let labelInstance = UILabel()
        labelInstance.text = "지도 앱으로\n바로 찾아볼까요?"
        labelInstance.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        labelInstance.textColor = .darkGray
        labelInstance.numberOfLines = 2
        return labelInstance
    }()

    private let naverButton: UIButton = {
        let buttonInstance = UIButton()
        buttonInstance.setImage(UIImage(named: "naver"), for: .normal)
        buttonInstance.layer.cornerRadius = 24
        buttonInstance.layer.borderWidth = 1
        buttonInstance.layer.borderColor = UIColor.g100.cgColor
        buttonInstance.clipsToBounds = true
        return buttonInstance
    }()

    private let kakaoButton: UIButton = {
        let buttonInstance = UIButton()
        buttonInstance.setImage(UIImage(named: "kakao"), for: .normal)
        buttonInstance.layer.cornerRadius = 24
        buttonInstance.layer.borderWidth = 1
        buttonInstance.layer.borderColor = UIColor.g100.cgColor
        buttonInstance.clipsToBounds = true
        return buttonInstance
    }()

    private let appleButton: UIButton = {
        let buttonInstance = UIButton()
        buttonInstance.setImage(UIImage(named: "AppleMap"), for: .normal)
        buttonInstance.layer.cornerRadius = 24
        buttonInstance.layer.borderWidth = 1
        buttonInstance.layer.borderColor = UIColor.g100.cgColor
        buttonInstance.clipsToBounds = true
        return buttonInstance
    }()

    private var modalCardBottomConstraint: Constraint?

    // MARK: - Initializer
    init(popUpStoreId: Int64) {
        self.popupStoreIdentifier = popUpStoreId
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen // 모달 스타일 설정
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTapGesture() // 탭 제스처 설정 추가
        presentModalCard()
    }

    // MARK: - Gesture Setup
    /// 딤드 영역 탭 제스처 설정
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnDimmingView))
        dimmingView.addGestureRecognizer(tapGesture)
        dimmingView.isUserInteractionEnabled = true // 중요: 상호작용 활성화
    }

    /// 딤드 영역 탭 처리: 탭 위치가 모달 카드 영역이 아닌 경우에만 닫기
    @objc private func handleTapOnDimmingView(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: view)
        if !modalCardView.frame.contains(tapLocation) {
            dismissModalCard()
        }
    }

    // MARK: - ReactorKit Binding
    func bind(reactor: MapGuideReactor) {
        reactor.action.onNext(.viewDidLoad(self.popupStoreIdentifier))

        // 닫기 버튼
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismissModalCard()
            })
            .disposed(by: disposeBag)

        // 지도 앱 열기
        naverButton.rx.tap
            .map { Reactor.Action.openMapApp("naver") }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        kakaoButton.rx.tap
            .map { Reactor.Action.openMapApp("kakao") }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        appleButton.rx.tap
            .map { Reactor.Action.openMapApp("apple") }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 확장 버튼 탭 처리 및 지도 풀스크린 전환
        expandButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else { return }

                let providerInstance = ProviderImpl()
                let repositoryInstance = MapRepositoryImpl(provider: providerInstance)
                let useCaseInstance = MapUseCaseImpl(repository: repositoryInstance)
                let directionRepositoryInstance = MapDirectionRepositoryImpl(provider: providerInstance)
                let mapReactorInstance = MapReactor(useCase: useCaseInstance, directionRepository: directionRepositoryInstance)

                if let selectedStore = strongSelf.currentCarouselStoreList.first {
                    mapReactorInstance.action.onNext(.didSelectItem(selectedStore))

                    // 현재 지도에 표시된 마커 생성 또는 가져오기
                    let markerInstance = NMFMarker()
                    markerInstance.position = NMGLatLng(lat: selectedStore.latitude, lng: selectedStore.longitude)
                    markerInstance.iconImage = NMFOverlayImage(name: "TapMarker")
                    markerInstance.width = 44
                    markerInstance.height = 44
                    markerInstance.anchor = CGPoint(x: 0.5, y: 1.0)
                    markerInstance.userInfo = ["storeData": selectedStore]

                    // 풀스크린 지도 뷰 컨트롤러에 선택된 마커 정보 전달
                    let fullScreenMapViewController = FullScreenMapViewController(store: selectedStore, existingMarker: markerInstance)
                    fullScreenMapViewController.reactor = mapReactorInstance

                    let navigationController = UINavigationController(rootViewController: fullScreenMapViewController)
                    navigationController.modalPresentationStyle = .fullScreen
                    strongSelf.present(navigationController, animated: true)
                } else {
                    mapReactorInstance.action.onNext(.viewDidLoad(strongSelf.popupStoreIdentifier))

                    mapReactorInstance.state
                        .map { $0.searchResult }
                        .distinctUntilChanged()
                        .compactMap { $0 }
                        .take(1)
                        .observe(on: MainScheduler.instance)
                        .subscribe(onNext: { store in
                            let markerInstance = NMFMarker()
                            markerInstance.position = NMGLatLng(lat: store.latitude, lng: store.longitude)
                            markerInstance.iconImage = NMFOverlayImage(name: "TapMarker")
                            markerInstance.width = 44
                            markerInstance.height = 44
                            markerInstance.anchor = CGPoint(x: 0.5, y: 1.0)
                            markerInstance.userInfo = ["storeData": store]

                            let fullScreenMapViewController = FullScreenMapViewController(store: store, existingMarker: markerInstance)
                            fullScreenMapViewController.reactor = mapReactorInstance

                            let navigationController = UINavigationController(rootViewController: fullScreenMapViewController)
                            navigationController.modalPresentationStyle = .fullScreen
                            strongSelf.present(navigationController, animated: true)
                        })
                        .disposed(by: strongSelf.disposeBag)
                }
            })
            .disposed(by: disposeBag)

        // 목적지 좌표에 따른 마커 및 카메라 설정
        reactor.state
            .map { $0.destinationCoordinate }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] coordinate in
                self?.setupMarker(at: coordinate)
            })
            .disposed(by: disposeBag)

        // searchResult로 현재 캐러셀 스토어 목록 업데이트
        reactor.state
            .map { $0.searchResult }
            .distinctUntilChanged()
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] store in
                self?.currentCarouselStoreList = [store]
            })
            .disposed(by: disposeBag)

        // Dismiss 처리
        reactor.state
            .map { $0.shouldDismiss }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.dismissModalCard()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .clear // 배경색을 clear로 설정하여 항상 딤드 뷰가 보이도록 함
        view.addSubview(dimmingView)
        dimmingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(modalCardView)
        modalCardView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(408)
            self.modalCardBottomConstraint = make.bottom.equalToSuperview().offset(408).constraint
        }

        let topContainerView = UIView()
        modalCardView.addSubview(topContainerView)
        topContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }

        topContainerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }

        topContainerView.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(24)
        }

        modalCardView.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.top.equalTo(topContainerView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(240) // 높이 약간 조정
        }

        modalCardView.addSubview(expandButton)
        expandButton.snp.makeConstraints { make in
            make.bottom.equalTo(mapView.snp.bottom).offset(-10)
            make.trailing.equalTo(mapView.snp.trailing).offset(-10)
            make.width.height.equalTo(32)
        }

        let bottomContainerView = UIView()
        modalCardView.addSubview(bottomContainerView)
        bottomContainerView.snp.makeConstraints { make in
            make.top.equalTo(mapView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
            make.bottom.equalTo(modalCardView.snp.bottom).inset(60)
        }

        bottomContainerView.addSubview(promptLabel)
        promptLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        let applicationStackView = UIStackView(arrangedSubviews: [naverButton, kakaoButton, appleButton])
        applicationStackView.axis = .horizontal
        applicationStackView.alignment = .center
        applicationStackView.spacing = 16
        applicationStackView.distribution = .fillEqually

        bottomContainerView.addSubview(applicationStackView)
        applicationStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            [naverButton, kakaoButton, appleButton].forEach { button in
                button.snp.makeConstraints { constraint in
                    constraint.size.equalTo(CGSize(width: 48, height: 48))
                }
            }
        }
    }

    private func presentModalCard() {
        self.dimmingView.alpha = 1

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.modalCardBottomConstraint?.update(offset: 0)
            self.view.layoutIfNeeded()
        }
    }

    private func setupMarker(at coordinate: CLLocationCoordinate2D) {
        mapView.subviews.forEach { subview in
            if subview is NMFMarker {
                subview.removeFromSuperview()
            }
        }

        // 새 마커 생성 및 설정
        let markerInstance = NMFMarker()
        markerInstance.position = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
        markerInstance.iconImage = NMFOverlayImage(name: "TapMarker")
        markerInstance.width = 44
        markerInstance.height = 44
        markerInstance.anchor = CGPoint(x: 0.5, y: 1.0)

        // 먼저 마커를 지도에 추가
        markerInstance.mapView = mapView

        // 카메라 위치 업데이트
        let cameraUpdate = NMFCameraUpdate(
            scrollTo: NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude),
            zoomTo: 15.0
        )
        cameraUpdate.animation = .easeIn
        cameraUpdate.animationDuration = 0.3
        mapView.moveCamera(cameraUpdate)
    }

    private func dismissModalCard() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.dimmingView.alpha = 0
            self.modalCardBottomConstraint?.update(offset: 408)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
}
