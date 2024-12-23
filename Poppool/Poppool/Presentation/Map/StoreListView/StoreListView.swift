import UIKit
import SnapKit

final class StoreListView: UIView {
   // MARK: - Components
   lazy var collectionView: UICollectionView = {
       let layout = createLayout()
       let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
       cv.backgroundColor = .white
       cv.register(StoreListCell.self, forCellWithReuseIdentifier: StoreListCell.identifier)
       cv.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
       return cv
   }()

   // MARK: - Init
   init() {
       super.init(frame: .zero)
       setUpConstraints()
   }

   required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }
}

// MARK: - SetUp
private extension StoreListView {
    func createLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 14  

        let totalWidth = UIScreen.main.bounds.width - (20 * 2) - 14
        let itemWidth = totalWidth / 2

        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + 88)

        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        return layout
    }


   func setUpConstraints() {
       backgroundColor = .clear
       layer.cornerRadius = 20
       layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
       clipsToBounds = true

       addSubview(collectionView)
       collectionView.snp.makeConstraints { make in
           make.edges.equalToSuperview()
       }
   }
}
