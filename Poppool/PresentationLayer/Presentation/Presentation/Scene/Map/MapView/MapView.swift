import NMapsMap
import SnapKit
import UIKit

final class MapView: UIView {
    // MARK: - Components
    let mapView: NMFMapView = {
        let view = NMFMapView()
        view.positionMode = .disabled
        view.zoomLevel = 14

        view.extent = NMGLatLngBounds(
            southWest: NMGLatLng(lat: 33.0, lng: 124.0),
            northEast: NMGLatLng(lat: 39.0, lng: 132.0)
        )

        view.minZoomLevel = 7.5
        view.maxZoomLevel = 20

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

    var storeCard: MapPopupCarouselView = {
        return MapPopupCarouselView()
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

    // MARK: - Helper Method
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
            make.top.equalToSuperview().offset(56)
            make.leading.trailing.equalToSuperview()
        }

        searchFilterContainer.addSubview(searchInput)
        searchInput.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(37)
        }

        searchFilterContainer.addSubview(filterChips)
        filterChips.snp.makeConstraints { make in
            make.top.equalTo(searchInput.snp.bottom).offset(7)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(36)
            make.bottom.equalToSuperview()
        }

        addSubview(storeCard)
        storeCard.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(137)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-24)
        }

        addSubview(locationButton)
        addSubview(listButton)

    }

    func configureUI() {
        backgroundColor = .white
        storeCard.isHidden = true
        updateButtonLayout()
    }

    func updateButtonLayout() {
        locationButton.snp.remakeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.size.equalTo(44)

            if storeCard.isHidden {
                make.bottom.equalTo(safeAreaLayoutGuide).offset(-40)
            } else {
                make.bottom.equalTo(storeCard.snp.top).offset(-20)
            }
        }

        listButton.snp.remakeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(locationButton.snp.top).offset(-12)
            make.size.equalTo(44)
        }
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
