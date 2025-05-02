import Infrastructure
import SnapKit
import UIKit

final class BalloonChipCell: UICollectionViewCell {
    static let identifier = "BalloonChipCell"

    private enum Constant {
        static let verticalInset: CGFloat = 6
        static let selectedLeftInset: CGFloat = 10
        static let normalLeftInset: CGFloat = 12
        static let rightInset: CGFloat = 12
        static let checkIconSize: CGSize = .init(width: 16, height: 16)
        static let baselineOffset: CGFloat = -1
        static let fontSize: CGFloat = 11
    }

    private let button: PPButton = {
        let button = PPButton(
            style: .secondary,
            text: "",
            font: .korFont(style: .medium, size: Constant.fontSize),
            cornerRadius: 15
        )
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        button.titleLabel?.adjustsFontSizeToFitWidth = false
        return button
    }()

    private var currentAction: UIAction?

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
        let attributedTitle = NSMutableAttributedString(string: title)
        attributedTitle.addAttribute(
            .baselineOffset,
            value: Constant.baselineOffset,
            range: NSRange(location: .zero, length: attributedTitle.length)
        )

        if isSelected {
            let checkImage = UIImage(named: "icon_check_white")?
                .withRenderingMode(.alwaysOriginal)
                .resize(to: Constant.checkIconSize)
            self.button.setImage(checkImage, for: .normal)
            self.button.semanticContentAttribute = .forceRightToLeft
            self.button.imageEdgeInsets = .init(
                top: .zero,
                left: 1,
                bottom: .zero,
                right: .zero
            )
            self.button.contentEdgeInsets = .init(
                top: Constant.verticalInset,
                left: Constant.selectedLeftInset,
                bottom: Constant.verticalInset,
                right: Constant.rightInset
            )
            self.button.setBackgroundColor(.blu500, for: .normal)
            self.button.setTitleColor(.white, for: .normal)
            self.button.layer.borderWidth = .zero

            attributedTitle.addAttribute(
                .font,
                value: UIFont.korFont(style: .bold, size: Constant.fontSize)!,
                range: NSRange(location: .zero, length: attributedTitle.length)
            )
        } else {
            self.button.setImage(nil, for: .normal)
            self.button.semanticContentAttribute = .unspecified
            self.button.imageEdgeInsets = .zero
            self.button.contentEdgeInsets = .init(
                top: Constant.verticalInset,
                left: Constant.normalLeftInset,
                bottom: Constant.verticalInset,
                right: Constant.rightInset
            )
            self.button.setBackgroundColor(.white, for: .normal)
            self.button.setTitleColor(.g400, for: .normal)
            self.button.layer.borderWidth = 1
            self.button.layer.borderColor = UIColor.g200.cgColor

            attributedTitle.addAttribute(
                .font,
                value: UIFont.korFont(style: .medium, size: Constant.fontSize)!,
                range: NSRange(location: .zero, length: attributedTitle.length)
            )
        }

        self.button.setAttributedTitle(attributedTitle, for: .normal)
    }

    var buttonAction: (() -> Void)? {
        didSet {
            if let oldAction = currentAction {
                self.button.removeAction(oldAction, for: .touchUpInside)
            }
            let action = UIAction { [weak self] _ in
                guard let self = self else { return }
                self.buttonAction?()
            }
            self.button.addAction(action, for: .touchUpInside)
            self.currentAction = action
        }
    }
}
extension UIImage {
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        self.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
