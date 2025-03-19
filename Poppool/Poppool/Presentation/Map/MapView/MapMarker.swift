import UIKit
import SnapKit
import NMapsMap

final class MapMarker: UIView {
    // MARK: - Components
    private(set) var isSelected: Bool = false
    var currentInput: Input?

    private let markerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Marker")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let clusterContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .blu500
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 0
        return view
    }()

    private let countBadgeView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.borderColor = UIColor.blu500.cgColor
        view.layer.borderWidth = 2
        view.layer.masksToBounds = true
        view.isHidden = true
        return view
    }()

    private let badgeCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .blu500
        label.textAlignment = .center
        return label
    }()

    private let labelStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }()

    private let regionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .white
        return label
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .white
        return label
    }()

    // MARK: - Init
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 80, height: 32))
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SetUp
private extension MapMarker {
    func setUpConstraints() {
        addSubview(markerImageView)
        addSubview(clusterContainer)
        addSubview(countBadgeView)

        clusterContainer.addSubview(labelStackView)
        labelStackView.addArrangedSubview(regionLabel)
        labelStackView.addArrangedSubview(countLabel)
        countBadgeView.addSubview(badgeCountLabel)

        self.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(70)
        }

        markerImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.height.equalTo(32)
        }

        clusterContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(24)
            make.width.equalTo(80)
        }

        labelStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
        }

        countBadgeView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.top.equalTo(markerImageView.snp.top).offset(-4)
            make.right.equalTo(markerImageView.snp.right).offset(4)
        }

        badgeCountLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        clusterContainer.isHidden = true
        countBadgeView.isHidden = true
    }

    func updateMarkerImage(isSelected: Bool) {
        guard self.isSelected != isSelected else { return }

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        self.isSelected = isSelected
        let imageName = isSelected ? "TapMarker" : "Marker"
        let size = isSelected ? 44 : 32

        markerImageView.image = UIImage(named: imageName)
        markerImageView.snp.remakeConstraints { make in
            make.width.height.equalTo(size)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        countBadgeView.snp.remakeConstraints { make in
            make.width.height.equalTo(20)
            make.top.equalTo(markerImageView.snp.top).offset(isSelected ? 0 : -4)
            make.right.equalTo(markerImageView.snp.right).offset(isSelected ? 0 : 4)
        }

        self.layoutIfNeeded()
        CATransaction.commit()
    }
}

// MARK: - Inputable
extension MapMarker: Inputable {
    struct Input {
        var isSelected: Bool = false
        var isCluster: Bool = false
        var regionName: String = ""
        var count: Int = 0
        var isMultiMarker: Bool = false
    }

    func injection(with input: Input) {
        if let current = currentInput, current == input {
            return
        }

        // 새로운 입력값 저장
        currentInput = input

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        if input.isCluster {
            setupClusterMarker(input)
        } else {
            setupSingleMarker(input)
        }

        self.layoutIfNeeded()
        CATransaction.commit()
    }

    private func setupClusterMarker(_ input: Input) {
        markerImageView.isHidden = true
        clusterContainer.isHidden = false
        countBadgeView.isHidden = true

        regionLabel.text = input.regionName
        countLabel.text = " \(input.count)"

        let stackSize = labelStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let requiredWidth = stackSize.width + 24

        clusterContainer.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(requiredWidth)
            make.height.equalTo(32)
        }

        labelStackView.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
        }
    }

    private func setupSingleMarker(_ input: Input) {
        markerImageView.isHidden = false
        clusterContainer.isHidden = true
        updateMarkerImage(isSelected: input.isSelected)

        if input.count > 1 {
            countBadgeView.isHidden = false
            badgeCountLabel.text = "\(input.count)"
        } else {
            countBadgeView.isHidden = true
        }
    }
}

extension MapMarker {
    var imageView: UIImageView {
        return markerImageView
    }

    /// 네이버맵용으로 뷰를 UIImage로 렌더링하는 함수
    func asImage() -> UIImage? {
        // 필요한 경우 프레임을 강제로 업데이트합니다.
        self.layoutIfNeeded()
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        return nil
    }
}

extension MapMarker.Input: Equatable {
    static func == (lhs: MapMarker.Input, rhs: MapMarker.Input) -> Bool {
        return lhs.isSelected == rhs.isSelected &&
               lhs.isCluster == rhs.isCluster &&
               lhs.regionName == rhs.regionName &&
               lhs.count == rhs.count &&
               lhs.isMultiMarker == rhs.isMultiMarker
    }
}
