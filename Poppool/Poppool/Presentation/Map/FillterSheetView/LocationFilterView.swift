// import UIKit
// import SnapKit
//
// final class LocationFilterView: UIView {
//    private let scrollView = UIScrollView()
//    private let contentStack = UIStackView()
//
//    private let regions = ["서울", "경기", "인천", "부산", "제주"]
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupLayout()
//        setupRegions()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupLayout() {
//        addSubview(scrollView)
//        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
//
//        scrollView.addSubview(contentStack)
//        contentStack.axis = .horizontal
//        contentStack.spacing = 8
//        contentStack.snp.makeConstraints { make in
//            make.edges.equalToSuperview().inset(20)
//            make.height.equalTo(40)
//        }
//    }
//
//    private func setupRegions() {
//        for r in regions {
//            let chip = FilterChip()
//            chip.setTitle(r, style: .inactive)
//            contentStack.addArrangedSubview(chip)
//        }
//    }
// }
