//
// import UIKit
// import SnapKit
// import RxSwift
//
//
// class StoreListHeaderView: UICollectionReusableView {
//    static let identifier = "StoreListHeaderView"
//
//    let searchInput = MapSearchInput()
//    let filterChips = MapFilterChips()
//
//    var disposeBag = DisposeBag()
//    override init(frame: CGRect) {
//        super.init(frame: frame)
////        print("[DEBUG] StoreListHeaderView 초기화 - frame: \(frame)")
//        setupLayout()
//        searchInput.setBackgroundColorForList()
//
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupLayout() {
//
//        backgroundColor = .white
//        addSubview(searchInput)
//        addSubview(filterChips)
//
//
//        searchInput.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(16)
//            make.left.equalToSuperview().offset(20)
//            make.right.equalToSuperview().inset(16)
//            make.height.equalTo(37)
//
//
//        }
//
//        filterChips.snp.makeConstraints { make in
//            make.top.equalTo(searchInput.snp.bottom).offset(11)
//            make.left.right.equalToSuperview().inset(20)
//            make.height.equalTo(36)
//            make.bottom.equalToSuperview().offset(-20)
//        }
//
//        
//        layoutIfNeeded()
//
//
//    }
// }
