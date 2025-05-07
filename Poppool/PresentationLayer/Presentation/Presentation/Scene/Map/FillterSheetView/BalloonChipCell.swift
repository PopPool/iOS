import UIKit

import Infrastructure

import SnapKit
import Then

final class BalloonChipCell: UICollectionViewCell {

    private enum Constant {
        static let verticalInset: CGFloat = 6
        static let selectedLeftInset: CGFloat = 10
        static let normalLeftInset: CGFloat = 12
        static let rightInset: CGFloat = 12
        static let checkIconSize: CGSize = .init(width: 16, height: 16)
        static let baselineOffset: CGFloat = -1
        static let fontSize: CGFloat = 11
    }

    private let button = PPButton(
        style: .secondary,
        text: "",
        font: .korFont(style: .medium, size: Constant.fontSize),
        cornerRadius: 15
    ).then {
        $0.titleLabel?.lineBreakMode = .byTruncatingTail
        $0.titleLabel?.adjustsFontSizeToFitWidth = false
    }

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
        let attributedTitle = NSMutableAttributedString(string: title).then {
            $0.addAttribute(
                .baselineOffset,
                value: Constant.baselineOffset,
                range: NSRange(location: .zero, length: $0.length)
            )
        }

        if isSelected {
            let checkImage = UIImage(named: "icon_check_white")?.withRenderingMode(.alwaysOriginal).resize(to: Constant.checkIconSize)

            button.then {
                $0.setImage(checkImage, for: .normal)
                $0.semanticContentAttribute = .forceRightToLeft
                $0.imageEdgeInsets = .init(top: .zero, left: 1, bottom: .zero, right: .zero)
                $0.contentEdgeInsets = .init(
                    top: Constant.verticalInset,
                    left: Constant.selectedLeftInset,
                    bottom: Constant.verticalInset,
                    right: Constant.rightInset
                )
                $0.setBackgroundColor(.blu500, for: .normal)
                $0.setTitleColor(.white, for: .normal)
                $0.layer.borderWidth = .zero
            }

            attributedTitle.addAttribute(
                .font,
                value: UIFont.korFont(style: .bold, size: Constant.fontSize)!,
                range: NSRange(location: .zero, length: attributedTitle.length)
            )
        } else {
            button.then {
                $0.setImage(nil, for: .normal)
                $0.semanticContentAttribute = .unspecified
                $0.imageEdgeInsets = .zero
                $0.contentEdgeInsets = .init(
                    top: Constant.verticalInset,
                    left: Constant.normalLeftInset,
                    bottom: Constant.verticalInset,
                    right: Constant.rightInset
                )
                $0.setBackgroundColor(.white, for: .normal)
                $0.setTitleColor(.g400, for: .normal)
                $0.layer.borderWidth = 1
                $0.layer.borderColor = UIColor.g200.cgColor
            }

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
