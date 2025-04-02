// import UIKit
// import SnapKit
//
// final class CategoryFilterView: UIView {
//    private let stackView = UIStackView()
//    private let categories = ["게임", "라이프스타일", "엔터테인먼트", "패션", "음식/요리", "키즈"]
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupLayout()
//        setupCategories()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupLayout() {
//        addSubview(stackView)
//        stackView.axis = .vertical
//        stackView.spacing = 12
//        stackView.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(20)
//            make.leading.trailing.equalToSuperview().inset(20)
//        }
//    }
//
//    private func setupCategories() {
//        for c in categories {
//            let chip = FilterChip()
//            chip.setTitle(c, style: .inactive)
//            stackView.addArrangedSubview(chip)
//        }
//    }
// }
