import UIKit
import SnapKit
import GoogleMaps

final class MapMarker: UIView {

    // MARK: - Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .blu500
        view.layer.cornerRadius = 14
        return view
    }()

    private let markerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        return stack
    }()

    private let titleLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 12)
        label.textColor = .w100
        return label
    }()

    private let countLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 12)
        label.textColor = .w100
        return label
    }()

    // MARK: - init
    init() {
        super.init(frame: .zero)
        setUpConstraints()
        self.translatesAutoresizingMaskIntoConstraints = false // AutoLayout 사용
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SetUp
private extension MapMarker {
    func setUpConstraints() {
        addSubview(containerView)
        containerView.addSubview(markerStackView)
        markerStackView.addArrangedSubview(titleLabel)
        markerStackView.addArrangedSubview(countLabel)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(28)
            make.width.equalTo(80) 
        }

        markerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
            make.centerY.equalToSuperview()
        }
    }
}

// MARK: - Inputable
extension MapMarker: Inputable {
    struct Input {
        let title: String
//        let count: Int
    }

    func injection(with input: Input) {
        titleLabel.text = input.title
//        countLabel.text = "외 \(input.count)개"
    }
}
