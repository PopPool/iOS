import UIKit
import SnapKit

final class BalloonChipCell: UICollectionViewCell {
   static let identifier = "BalloonChipCell"

   private let button: PPButton = {
       let button = PPButton(
           style: .secondary,
           text: "",
           font: .KorFont(style: .medium, size: 12),
           cornerRadius: 16
       )
       button.titleLabel?.lineBreakMode = .byClipping
       button.titleLabel?.adjustsFontSizeToFitWidth = false
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
       button.setTitle(title, for: .normal)
       if isSelected {
           let checkImage = UIImage(named: "icon_check_white")?.withRenderingMode(.alwaysOriginal)
           let resizedImage = checkImage?.resize(to: CGSize(width: 16, height: 16))
           button.setImage(resizedImage, for: .normal)
           button.semanticContentAttribute = .forceRightToLeft
           button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 0)
           button.contentEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 12)
           button.setBackgroundColor(.blu500, for: .normal)
           button.setTitleColor(.white, for: .normal)
           button.layer.borderWidth = 0
           button.titleLabel?.font = .KorFont(style: .bold, size: 12)


       } else {
           button.setImage(nil, for: .normal)
           button.semanticContentAttribute = .unspecified
           button.imageEdgeInsets = .zero
           button.contentEdgeInsets = UIEdgeInsets(top: 7, left: 12, bottom: 7, right: 12)
           button.setBackgroundColor(.white, for: .normal)
           button.setTitleColor(.g400, for: .normal)
           button.layer.borderWidth = 1
           button.layer.borderColor = UIColor.g200.cgColor
           button.titleLabel?.font = .KorFont(style: .medium, size: 12)

       }
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

// UIImage extension for resizing
extension UIImage {
   func resize(to size: CGSize) -> UIImage? {
       UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
       defer { UIGraphicsEndImageContext() }
       draw(in: CGRect(origin: .zero, size: size))
       return UIGraphicsGetImageFromCurrentImageContext()
   }
}
