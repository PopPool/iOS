import UIKit

import DesignSystem

import SnapKit

final class PopUpImagesCollectionView: UICollectionView {
    // MARK: - Properties
    enum Constant {
        static let imageWidth: CGFloat = 80
        static let imageHeight: CGFloat = 120
        static let imageSpacing: CGFloat = 8
    }

    var onImageSelected: ((Int) -> Void)?
    var onMainImageToggled: ((Int) -> Void)?
    var onImageDeleted: ((Int) -> Void)?

    private var images: [ExtendedImage] = []

    // MARK: - init
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: Constant.imageWidth, height: Constant.imageHeight)
        layout.minimumLineSpacing = Constant.imageSpacing

        super.init(frame: .zero, collectionViewLayout: layout)

        self.addViews()
        self.setupContstraints()
        self.configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("\(#file), \(#function) Error")
    }
}

// MARK: - Setup
private extension PopUpImagesCollectionView {
    func addViews() { }

    func setupContstraints() { }

    func configureUI() {
        self.backgroundColor = .clear
        self.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifiers)
        self.dataSource = self
        self.delegate = self
        self.showsHorizontalScrollIndicator = false
    }
}

// MARK: - Public Methods
extension PopUpImagesCollectionView {
    func updateImages(_ images: [ExtendedImage]) {
        self.images = images
        self.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension PopUpImagesCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageCell.identifiers,
            for: indexPath
        ) as? ImageCell else {
            return UICollectionViewCell()
        }

        let item = self.images[indexPath.item]
        cell.configure(with: item)

        // 대표이미지 변경
        cell.onMainCheckToggled = { [weak self] in
            self?.onMainImageToggled?(indexPath.item)
        }

        // 개별 삭제
        cell.onDeleteTapped = { [weak self] in
            self?.onImageDeleted?(indexPath.item)
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension PopUpImagesCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.onImageSelected?(indexPath.item)
    }
}
