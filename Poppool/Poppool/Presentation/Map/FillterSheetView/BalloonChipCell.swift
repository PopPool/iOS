import UIKit
import SnapKit

final class BalloonChipCell: UICollectionViewCell {
    static let identifier = "BalloonChipCell"

    private let button: PPButton = {
        let button = PPButton(style: .secondary, text: "", font: .KorFont(style: .medium, size: 12), cornerRadius: 16)
        button.titleLabel?.lineBreakMode = .byClipping
        button.titleLabel?.adjustsFontSizeToFitWidth = false
        button.imageView?.contentMode = .scaleAspectFit
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 0)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(button)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func configure(with title: String, isSelected: Bool) {
        if isSelected {
            button.setImage(UIImage(named: "icon_check_fill"), for: .normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 7, left: 12, bottom: 7, right: 16)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -8)
            button.setBackgroundColor(.blu500, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.layer.borderWidth = 0
        } else {
            button.setImage(nil, for: .normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 7, left: 12, bottom: 7, right: 10)
            button.setBackgroundColor(.white, for: .normal)
            button.setTitleColor(.g200, for: .normal)
            button.layer.borderColor = UIColor.g200.cgColor
            button.layer.borderWidth = 1
        }

        button.setTitle(title, for: .normal)
    }

    private var currentAction: UIAction?

    var buttonAction: (() -> Void)? {
        didSet {
            if let oldAction = currentAction {
                button.removeAction(oldAction, for: .touchUpInside)
            }

            let action = UIAction { [weak self] _ in
                self?.buttonAction?()
            }
            button.addAction(action, for: .touchUpInside)
            currentAction = action
        }
    }
}
