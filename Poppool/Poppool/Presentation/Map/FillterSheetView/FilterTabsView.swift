// import UIKit
// import RxSwift
// import RxCocoa
//
// final class FilterTabsView: UIView {
//    private let tabs = ["지역", "카테고리"]
//    let segmentedControl = UISegmentedControl()
//
//    var rx: Reactive<FilterTabsView> {
//        return Reactive(self)
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupTabs()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupTabs() {
//        tabs.enumerated().forEach { index, title in
//            segmentedControl.insertSegment(withTitle: title, at: index, animated: false)
//        }
//        segmentedControl.selectedSegmentIndex = 0
//        addSubview(segmentedControl)
//
//        segmentedControl.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//    }
// }
//
// extension Reactive where Base: FilterTabsView {
//    var selectedIndex: ControlProperty<Int> {
//        return base.segmentedControl.rx.selectedSegmentIndex
//    }
// }
