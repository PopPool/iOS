import UIKit
import SnapKit

final class StoreListView: UIView {
   // MARK: - Components
   lazy var collectionView: UICollectionView = {
       let layout = createLayout()
       let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
       cv.backgroundColor = .white
       cv.register(StoreListCell.self, forCellWithReuseIdentifier: StoreListCell.identifier)
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
        layout.scrollDirection = .vertical // 세로 스크롤
        layout.minimumLineSpacing = 20 // 행 간격
        layout.minimumInteritemSpacing = 16 // 열 간격

        // 화면의 너비에 맞춰 2열 셀 크기 계산
        let totalWidth = UIScreen.main.bounds.width - 32 // 좌우 여백 16 * 2 제거
        let itemWidth = (totalWidth - layout.minimumInteritemSpacing) / 2 // 두 열로 나눔

        layout.itemSize = CGSize(width: floor(itemWidth), height: itemWidth + 100) // 셀 크기 설정
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16) // 섹션 여백
        return layout
    }

    func setUpConstraints() {
        backgroundColor = .clear
        addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
