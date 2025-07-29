import SnapKit
import UIKit

final class StoreListView: UIView {

    // MARK: - Properties
    private enum Constant {
        static let grabberWidth: CGFloat = 36
        static let grabberHeight: CGFloat = 5
        static let grabberTopOffset: CGFloat = 14
        static let grabberCornerRadius: CGFloat = 2.5
        static let collectionViewTopOffset: CGFloat = 8
        static let cornerRadius: CGFloat = 16
        static let itemHeight: CGFloat = 250 
        static let minimumLineSpacing: CGFloat = 20
        static let minimumInteritemSpacing: CGFloat = 16
        static let sectionInsetTop: CGFloat = 16
        static let sectionInsetHorizontal: CGFloat = 16
        static let sectionInsetBottom: CGFloat = 16
    }

    // MARK: - Components
    lazy var collectionView: UICollectionView = {
        let layout = self.createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.register(StoreListCell.self, forCellWithReuseIdentifier: StoreListCell.identifier)
        return cv
    }()

    let grabberHandle: UIView = {
        let view = UIView()
        view.backgroundColor = .g200
        view.layer.cornerRadius = Constant.grabberCornerRadius
        view.isUserInteractionEnabled = true
        return view
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.configureLayer()
        self.addViews()
        self.setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
private extension StoreListView {
    func addViews() {
        [collectionView, grabberHandle].forEach {
            self.addSubview($0)
        }
    }

    func setupConstraints() {
        grabberHandle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constant.grabberTopOffset).priority(.high)
            make.centerX.equalToSuperview()
            make.width.equalTo(Constant.grabberWidth)
            make.height.equalTo(Constant.grabberHeight)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(grabberHandle.snp.bottom).offset(Constant.collectionViewTopOffset).priority(.medium)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func createLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = Constant.minimumLineSpacing
        layout.minimumInteritemSpacing = Constant.minimumInteritemSpacing

        let totalWidth = UIScreen.main.bounds.width - (Constant.sectionInsetHorizontal * 2)
        let itemWidth = (totalWidth - layout.minimumInteritemSpacing) / 2

        layout.itemSize = CGSize(width: floor(itemWidth), height: Constant.itemHeight)
        layout.sectionInset = UIEdgeInsets(
            top: Constant.sectionInsetTop,
            left: Constant.sectionInsetHorizontal,
            bottom: Constant.sectionInsetBottom,
            right: Constant.sectionInsetHorizontal
        )

        return layout
    }

    func configureLayer() {
        self.backgroundColor = .white
        self.layer.cornerRadius = Constant.cornerRadius
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.layer.masksToBounds = true
    }
}
