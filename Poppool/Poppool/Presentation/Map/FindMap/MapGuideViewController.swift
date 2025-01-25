import UIKit
import SnapKit
import GoogleMaps
import ReactorKit
import RxSwift
import CoreLocation

final class MapGuideViewController: UIViewController, View {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private let popUpStoreId: Int64


    init(popUpStoreId: Int64) {
        self.popUpStoreId = popUpStoreId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let dimmingView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
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
    private let mapView: GMSMapView = {
        let map = GMSMapView()
        map.isMyLocationEnabled = false
        // map.settings.setAllGesturesEnabled(false) // 제스처 비활성화시
        map.layer.borderWidth = 1
        map.layer.borderColor = UIColor.g100.cgColor
        map.layer.cornerRadius = 12

        return map
    }()

    /// 지도 우상단 "Expandable" 버튼
    private let expandButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "Expandable"), for: .normal)
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.7)
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
        btn.setImage(UIImage(named: "Tmap"), for: .normal)
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

        reactor.action.onNext(.viewDidLoad)

        // 닫기 버튼
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.dismiss(animated: true, completion: nil)
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
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                Logger.log(message: "📍   버튼 탭: popUpStoreId = \(self.popUpStoreId)", category: .debug)
                let provider = ProviderImpl()
                let useCase = DefaultMapUseCase(repository: DefaultMapRepository(provider: provider))
                let directionRepository = DefaultMapDirectionRepository(provider: provider)
                let reactor = MapReactor(useCase: useCase, directionRepository: directionRepository)

                let fullScreenMapVC = FullScreenMapViewController()
                fullScreenMapVC.reactor = reactor
                Logger.log(message: "🚀 viewDidLoad Action 발생: popUpStoreId = \(self.popUpStoreId)", category: .debug)
                reactor.action.onNext(.viewDidLoad(self.popUpStoreId))
                

                let nav = UINavigationController(rootViewController: fullScreenMapVC)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.destinationCoordinate }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] coordinate in
                self?.setupMarker(at: coordinate)
            })
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.shouldDismiss }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.dismissModalCard()
            })
            .disposed(by: disposeBag)

    }

    // MARK: - UI
    private func setupUI() {
        view.backgroundColor = .clear

        // 딤뷰
        view.addSubview(dimmingView)
        dimmingView.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 모달 카드
        view.addSubview(modalCardView)
        modalCardView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(408)  
            self.modalCardBottomConstraint = make.bottom.equalToSuperview().offset(408).constraint
        }

        // 상단 헤더
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
            make.height.equalTo(240)

        }

        // Expandable 버튼
        mapView.addSubview(expandButton)
        expandButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(10)
            make.width.height.equalTo(32)
        }

        // 하단 컨테이너 (프롬프트 + 버튼)
        let bottomContainer = UIView()
        modalCardView.addSubview(bottomContainer)
        bottomContainer.snp.makeConstraints { make in
            make.top.equalTo(mapView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
            make.bottom.equalTo(modalCardView.snp.bottom).inset(20)
        }

        // 프롬프트 라벨
        bottomContainer.addSubview(promptLabel)
        promptLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        // 지도 앱 버튼 스택
        let appStack = UIStackView(arrangedSubviews: [naverButton, kakaoButton, tmapButton])
        appStack.axis = .horizontal
        appStack.alignment = .center
        appStack.spacing = 16
        appStack.distribution = .fillEqually

        bottomContainer.addSubview(appStack)
        appStack.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
//            make.height.equalTo(40)
            [naverButton, kakaoButton, tmapButton].forEach { button in
                button.snp.makeConstraints { make in
                    make.size.equalTo(CGSize(width: 48, height: 48))
                }
            }
        }
    }

    private func presentModalCard() {
        UIView.animate(withDuration: 0.3) {
            self.dimmingView.alpha = 1
            self.modalCardBottomConstraint?.update(offset: 0)
            self.view.layoutIfNeeded()
        }
    }

    private func setupMarker(at coordinate: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: coordinate)
        marker.title = ""
        marker.map = mapView
        let camera = GMSCameraPosition(target: coordinate, zoom: 16)
        mapView.animate(to: camera)
    }

    private func dismissModalCard() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.dimmingView.alpha = 0
            self.modalCardBottomConstraint?.update(offset: 408)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.navigationController?.popViewController(animated: false)
        }
    }

}
