import UIKit
import SnapKit
import GoogleMaps

final class MapView: UIView {
    // MARK: - Components
    let mapView: GMSMapView = {
        let camera = GMSCameraPosition(latitude: 37.5666, longitude: 126.9784, zoom: 14)
        let view = GMSMapView(frame: .zero, camera: camera)
        view.settings.myLocationButton = false
        view.setMinZoom(7.5, maxZoom: 20)

        let southWest = CLLocationCoordinate2D(latitude: 33.0, longitude: 124.0)
        let northEast = CLLocationCoordinate2D(latitude: 39.0, longitude: 132.0)
        let koreaBounds = GMSCoordinateBounds(coordinate: southWest, coordinate: northEast)
        view.cameraTargetBounds = koreaBounds

        return view
    }()

    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    let searchFilterContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    let searchInput = MapSearchInput()
    let filterChips = MapFilterChips()

    let locationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "currentlocation"), for: .normal)
        button.backgroundColor = .w100
        button.layer.cornerRadius = 22
        button.layer.applyMapButtonShadow()
        return button
    }()

    let listButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "list"), for: .normal)
        button.backgroundColor = .w100
        button.layer.cornerRadius = 22
        button.layer.applyMapButtonShadow()
        return button
    }()

    // storeCard를 var로 선언하여 visibility 변경 시 setStoreCardHidden()을 통해 업데이트
    var storeCard: MapPopupCarouselView = {
        let view = MapPopupCarouselView()
        return view
    }()

    // MARK: - Init
    init() {
        super.init(frame: .zero)
        setUpConstraints()
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helper Method: 스토어카드 보임/숨김에 따른 레이아웃 업데이트
    /// 스토어카드의 표시 상태를 변경하면서 버튼 레이아웃을 업데이트합니다.
    func setStoreCardHidden(_ hidden: Bool, animated: Bool = true) {
        guard storeCard.isHidden != hidden else { return }
        storeCard.isHidden = hidden
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.updateButtonLayout()
                self.layoutIfNeeded()
            }
        } else {
            updateButtonLayout()
            layoutIfNeeded()
        }
    }
}

// MARK: - SetUp
private extension MapView {
    func setUpConstraints() {
        addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(searchFilterContainer)
        searchFilterContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(80)
            make.leading.trailing.equalToSuperview()
        }

        searchFilterContainer.addSubview(searchInput)
        searchInput.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(37)
        }

        searchFilterContainer.addSubview(filterChips)
        filterChips.snp.makeConstraints { make in
            make.top.equalTo(searchInput.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(36)
            make.bottom.equalToSuperview()
        }

        addSubview(locationButton)
        addSubview(listButton)
        addSubview(storeCard)

        locationButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(storeCard.snp.top).offset(-30)
            make.size.equalTo(44)
        }

        listButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(locationButton.snp.top).offset(-12)
            make.size.equalTo(44)
        }

        storeCard.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(137)
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
    }

    func configureUI() {
        backgroundColor = .white
        storeCard.isHidden = true
        updateButtonLayout()
    }

    func updateButtonLayout() {
        if storeCard.isHidden {
            locationButton.snp.remakeConstraints { make in
                make.trailing.equalToSuperview().inset(16)
                make.bottom.equalTo(safeAreaLayoutGuide).inset(40) 
                make.size.equalTo(44)
            }
            listButton.snp.remakeConstraints { make in
                make.trailing.equalToSuperview().inset(16)
                make.bottom.equalTo(locationButton.snp.top).offset(-8) // 예시로 8pt 간격
                make.size.equalTo(44)
            }
        } else {
            locationButton.snp.remakeConstraints { make in
                make.trailing.equalToSuperview().inset(16)
                make.bottom.equalTo(storeCard.snp.top).offset(-30)
                make.size.equalTo(44)
            }
            listButton.snp.remakeConstraints { make in
                make.trailing.equalToSuperview().inset(16)
                make.bottom.equalTo(locationButton.snp.top).offset(-12)
                make.size.equalTo(44)
            }
        }
        layoutIfNeeded()
    }
}

// MARK: - CALayer Extension
private extension CALayer {
    func applyMapButtonShadow() {
        shadowColor = UIColor.black.cgColor
        shadowOffset = CGSize(width: 0, height: 2)
        shadowRadius = 4
        shadowOpacity = 0.1
    }
}
