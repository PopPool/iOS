import UIKit
import SnapKit
import GoogleMaps

final class MapView: UIView {
    // MARK: - Components
    
    let mapView: GMSMapView = {
        let camera = GMSCameraPosition(latitude: 37.5666, longitude: 126.9784, zoom: 15)
        let view = GMSMapView(frame: .zero, camera: camera)
        view.settings.myLocationButton = false
        
        return view
    }()

    let topStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
//        stack.backgroundColor = .white
        return stack
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

    let storeCard = MapPopupCarouselView()

    // MARK: - Init
    init() {
        super.init(frame: .zero)
        setUpConstraints()
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SetUp
private extension MapView {
    func setUpConstraints() {
        addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(topStackView)
        topStackView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(10)
            make.leading.trailing.equalToSuperview()
        }

        searchInput.snp.makeConstraints { make in
            make.height.equalTo(40)
        }

        filterChips.snp.makeConstraints { make in
            make.height.equalTo(32)
        }

        let searchContainer = UIView()
        let filterContainer = UIView()

        searchContainer.addSubview(searchInput)
        filterContainer.addSubview(filterChips)

        searchInput.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }

        filterChips.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }

        topStackView.addArrangedSubview(searchContainer)
        topStackView.addArrangedSubview(filterContainer)

        addSubview(locationButton)
        addSubview(listButton)
        addSubview(storeCard)

        listButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(locationButton.snp.top).offset(-12)
            make.size.equalTo(44)
        }

        locationButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(storeCard.snp.top).offset(-30)
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
    }
}
private extension CALayer {
    func applyMapButtonShadow() {
        shadowColor = UIColor.black.cgColor
        shadowOffset = CGSize(width: 0, height: 2)
        shadowRadius = 4
        shadowOpacity = 0.1
    }
}
