import UIKit
import SnapKit
import ReactorKit
import RxSwift
import CoreLocation
import NMapsMap

final class MapGuideViewController: UIViewController, View {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private let popUpStoreId: Int64
    private var currentCarouselStores: [MapPopUpStore] = [] // 현재 선택된 스토어 목록

    init(popUpStoreId: Int64) {
        self.popUpStoreId = popUpStoreId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let dimmingView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        v.alpha = 0
        return v
    }()

    private let modalCardView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.1
        v.layer.shadowOffset = .zero
        v.layer.shadowRadius = 8
        return v
    }()

    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "찾아가는 길"
        lb.font = UIFont.boldSystemFont(ofSize: 17)
        lb.textColor = .black
        return lb
    }()

    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        let image = UIImage(named: "icon_xmark")?.withRenderingMode(.alwaysOriginal)
        btn.setImage(image, for: .normal)
        return btn
    }()

    private let mapView: NMFMapView = {
        let map = NMFMapView()
        map.layer.borderWidth = 1
        map.layer.borderColor = UIColor.g100.cgColor
        map.layer.cornerRadius = 12
        return map
    }()

    private let expandButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "Expandable"), for: .normal)
        btn.backgroundColor = UIColor.white
        btn.layer.cornerRadius = 16
        btn.clipsToBounds = true
        return btn
    }()

    private let promptLabel: UILabel = {
        let lb = UILabel()
        lb.text = "지도 앱으로\n바로 찾아볼까요?"
        lb.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        lb.textColor = .darkGray
        lb.numberOfLines = 2
        return lb
    }()

    private let naverButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "naver"), for: .normal)
        btn.layer.cornerRadius = 24
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.g100.cgColor
        btn.clipsToBounds = true
        return btn
    }()

    private let kakaoButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "kakao"), for: .normal)
        btn.layer.cornerRadius = 24
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.g100.cgColor
        btn.clipsToBounds = true
        return btn
    }()

    private let tmapButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "TMap"), for: .normal)
        btn.layer.cornerRadius = 24
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.g100.cgColor
        btn.clipsToBounds = true
        return btn
    }()

    private var modalCardBottomConstraint: Constraint?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presentModalCard()
    }

    func bind(reactor: MapGuideReactor) {
        reactor.action.onNext(.viewDidLoad(self.popUpStoreId))

        // 닫기 버튼
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
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
        tmapButton.rx.tap
            .map { Reactor.Action.openMapApp("tmap") }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        expandButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                let provider = ProviderImpl()
                let useCase = DefaultMapUseCase(repository: DefaultMapRepository(provider: provider))
                let directionRepository = DefaultMapDirectionRepository(provider: provider)
                let reactor = MapReactor(useCase: useCase, directionRepository: directionRepository)

                if let selectedStore = self.currentCarouselStores.first {
                    reactor.action.onNext(.didSelectItem(selectedStore))

                    // store: 매개변수명 사용
                    let fullScreenMapVC = FullScreenMapViewController(store: selectedStore)
                    fullScreenMapVC.reactor = reactor

                    let nav = UINavigationController(rootViewController: fullScreenMapVC)
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav, animated: true)
                } else {
                    reactor.action.onNext(.viewDidLoad(self.popUpStoreId))

                    reactor.state
                        .map { $0.searchResult }
                        .distinctUntilChanged()
                        .compactMap { $0 }
                        .take(1)
                        .subscribe(onNext: { store in
                            // store: 매개변수명 사용
                            let fullScreenMapVC = FullScreenMapViewController(store: store)
                            fullScreenMapVC.reactor = reactor

                            let nav = UINavigationController(rootViewController: fullScreenMapVC)
                            nav.modalPresentationStyle = .fullScreen
                            self.present(nav, animated: true)
                        })
                        .disposed(by: self.disposeBag)
                }
            })
            .disposed(by: disposeBag)


        // 목적지 좌표로 마커 및 카메라 설정
        reactor.state
            .map { $0.destinationCoordinate }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] coordinate in
                self?.setupMarker(at: coordinate)
            })
            .disposed(by: disposeBag)

        // searchResult로 currentCarouselStores 업데이트
        reactor.state
            .map { $0.searchResult }
            .distinctUntilChanged()
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] store in
                self?.currentCarouselStores = [store]
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
        view.backgroundColor = .white
        view.addSubview(dimmingView)
        dimmingView.snp.makeConstraints { $0.edges.equalToSuperview() }

        view.addSubview(modalCardView)
        modalCardView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(408)
            self.modalCardBottomConstraint = make.bottom.equalToSuperview().offset(408).constraint
        }

        let topContainer = UIView()
        modalCardView.addSubview(topContainer)
        topContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }

        topContainer.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }

        topContainer.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(24)
        }

        modalCardView.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.top.equalTo(topContainer.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(320)
        }

        mapView.addSubview(expandButton)
        expandButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(10)
            make.width.height.equalTo(32)
        }

        let bottomContainer = UIView()
        modalCardView.addSubview(bottomContainer) // 오타 수정 필요: bottomContainer로 변경
        bottomContainer.snp.makeConstraints { make in
            make.top.equalTo(mapView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
            make.bottom.equalTo(modalCardView.snp.bottom).inset(60)
        }

        bottomContainer.addSubview(promptLabel)
        promptLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        let appStack = UIStackView(arrangedSubviews: [naverButton, kakaoButton, tmapButton])
        appStack.axis = .horizontal
        appStack.alignment = .center
        appStack.spacing = 16
        appStack.distribution = .fillEqually

        bottomContainer.addSubview(appStack)
        appStack.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            [naverButton, kakaoButton, tmapButton].forEach { button in
                button.snp.makeConstraints { make in
                    make.size.equalTo(CGSize(width: 48, height: 48))
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
        // 기존 마커 제거
        mapView.subviews.forEach { if $0 is NMFMarker { $0.removeFromSuperview() } }

        // 새 마커 생성 및 설정
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
        marker.iconImage = NMFOverlayImage(name: "TapMarker") // MapViewController에서 사용하는 기본 마커
        marker.width = 32
        marker.height = 32
        marker.anchor = CGPoint(x: 0.5, y: 1.0)

        // 먼저 마커를 지도에 추가
        marker.mapView = mapView

        // 그 다음 카메라 위치 설정
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
