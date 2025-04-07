import SnapKit
import UIKit

final class FilterChip: UIButton {
    enum Style {
        case inactive
        case active
        case selected
        case option
    }

    // MARK: - Properties
    var onTap: (() -> Void)?
    var onClose: (() -> Void)?
    private var isChipSelected: Bool = false

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "icon_xmark_blu"), for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        return button
    }()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 16
        setupLayout()
//        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupLayout() {
        addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(14)
            make.size.equalTo(11)
        }
    }

    // MARK: - Configuration
    func setTitle(_ title: String, style: Style) {
        setTitle(title, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)

        switch style {
        case .inactive:
            backgroundColor = .white
            layer.borderWidth = 1
            layer.borderColor = UIColor.g200.cgColor
            setTitleColor(.g700, for: .normal)
            closeButton.isHidden = true

        case .active, .selected:
            backgroundColor = .blu500
            layer.borderWidth = 0
            setTitleColor(.white, for: .normal)
            closeButton.isHidden = true

        case .option:
            backgroundColor = .white
            layer.borderWidth = 1
            layer.borderColor = UIColor.blu500.cgColor
            setTitleColor(.blu500, for: .normal)
            closeButton.isHidden = false
        }

        let rightPadding: CGFloat = closeButton.isHidden ? 12 : 34
        contentEdgeInsets = UIEdgeInsets(top: 7, left: 12, bottom: 7, right: rightPadding)
    }

    // MARK: - Actions
//    @objc private func handleTap() {
//        isChipSelected.toggle()
//        setTitle(currentTitle ?? "", style: isChipSelected ? .active : .inactive)
//        onTap?()
//    }

    @objc private func handleClose() {
        onClose?()
    }
}
