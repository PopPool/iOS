import SnapKit
import UIKit

final class StoreListView: UIView {
    // MARK: - Components
    lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.register(StoreListCell.self, forCellWithReuseIdentifier: StoreListCell.identifier)
        return cv
    }()

    let grabberHandle: UIView = {
        let view = UIView()
        view.backgroundColor = .g200
        view.layer.cornerRadius = 2.5
        view.isUserInteractionEnabled = true
        return view
    }()

    private let paddingView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear // 간격만 추가하므로 투명
        return view
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayer() // 최상단 레이어 설정
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
private extension StoreListView {
    func createLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 16

        let totalWidth = UIScreen.main.bounds.width - 32
        let itemWidth = (totalWidth - layout.minimumInteritemSpacing) / 2

        layout.itemSize = CGSize(width: floor(itemWidth), height: itemWidth + 100)
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        return layout
    }

    func setUpConstraints() {
        backgroundColor = .white
        addSubview(collectionView)
        addSubview(grabberHandle)
        grabberHandle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14).priority(.high)
                 make.centerX.equalToSuperview()
                 make.width.equalTo(36)
                 make.height.equalTo(5)
             }
//        paddingView.snp.makeConstraints { make in
//            make.top.equalTo(grabberHandle.snp.bottom)
//            make.leading.trailing.equalToSuperview()
//            
//        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(grabberHandle.snp.bottom).offset(8).priority(.medium)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()  // bottom 제약 다시 추가
        }
    }

    func configureLayer() {
        layer.cornerRadius = 16
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // 상단 좌우 코너만 적용
        layer.masksToBounds = true
    }
}
