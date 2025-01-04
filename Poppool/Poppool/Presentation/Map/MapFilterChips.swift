import UIKit
import SnapKit


class MapFilterChips: UIView {
   // MARK: - Components
   private let stackView: UIStackView = {
       let stack = UIStackView()
       stack.axis = .horizontal
       stack.spacing = 8
       stack.alignment = .fill
       stack.distribution = .fill
       return stack
   }()

   lazy var locationChip = createChipButton(title: "지역선택")
   lazy var categoryChip = createChipButton(title: "카테고리")

   var onRemoveLocation: (() -> Void)?
   var onRemoveCategory: (() -> Void)?

   // MARK: - Init
   init() {
       super.init(frame: .zero)
       setupLayout()
   }

   required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }

   // MARK: - Setup
    private func setupLayout() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
        }

       stackView.addArrangedSubview(locationChip)
       stackView.addArrangedSubview(categoryChip)
   }

   private func createChipButton(title: String, isSelected: Bool = false) -> UIButton {
       let button = UIButton(type: .system)
       button.setTitle(title, for: .normal)
       button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
       button.setTitleColor(isSelected ? .white : .g400, for: .normal)
       button.backgroundColor = isSelected ? .blu500 : .white
       button.layer.cornerRadius = 18
       button.layer.borderWidth = isSelected ? 0 : 1
       button.layer.borderColor = isSelected ? UIColor.blu500.cgColor : UIColor.g200.cgColor
       button.contentEdgeInsets = UIEdgeInsets(top: 9, left: 16, bottom: 9, right: 16)
       return button
   }

   // MARK: - Update State
   func update(locationText: String?, categoryText: String?) {
       print("Updating chips - locationText: \(String(describing: locationText)), categoryText: \(String(describing: categoryText))")

       updateChip(button: locationChip, text: locationText, placeholder: "지역선택", onClear: onRemoveLocation)
       updateChip(button: categoryChip, text: categoryText, placeholder: "카테고리", onClear: onRemoveCategory)
   }

   private func updateChip(button: UIButton, text: String?, placeholder: String, onClear: (() -> Void)?) {
       button.subviews.forEach { if $0 is UIButton { $0.removeFromSuperview() } }

       if let text = text, !text.isEmpty, text != placeholder {
           button.setTitle(text, for: .normal)

           button.setTitleColor(.white, for: .normal)
           button.backgroundColor = .blu500
           button.layer.borderWidth = 0
           button.layer.cornerRadius = 18

           let xButton = UIButton(type: .custom)
           xButton.setImage(UIImage(named: "icon_xmark")?.withRenderingMode(.alwaysTemplate), for: .normal)
           xButton.tintColor = .white
           button.addSubview(xButton)

           xButton.snp.makeConstraints { make in
               make.centerY.equalToSuperview()
               make.trailing.equalToSuperview().inset(12)
               make.size.equalTo(16)
           }

           xButton.addTarget(self, action: #selector(handleClearButtonTapped(_:)), for: .touchUpInside)
           xButton.accessibilityLabel = button === locationChip ? "location" : "category"

           button.contentEdgeInsets = UIEdgeInsets(top: 9, left: 16, bottom: 9, right: 36)
       } else {
           button.setTitle(placeholder, for: .normal)
           button.setTitleColor(.g400, for: .normal)
           button.backgroundColor = .white
           button.layer.borderWidth = 1
           button.layer.borderColor = UIColor.g200.cgColor
           button.layer.cornerRadius = 16
           button.contentEdgeInsets = UIEdgeInsets(top: 9, left: 16, bottom: 9, right: 16)
       }
   }

   @objc private func handleClearButtonTapped(_ sender: UIButton) {
       if sender.accessibilityLabel == "location" {
           onRemoveLocation?()
       } else {
           onRemoveCategory?()
       }
   }
}
