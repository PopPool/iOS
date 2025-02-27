import UIKit
import SnapKit
import FloatingPanel

final class MapPopupCarouselView: UICollectionView {
    // 스크롤 멈췄을 때의 콜백
    var onCardScrolled: ((Int) -> Void)?
    var onCardTapped: ((MapPopUpStore) -> Void)?

    private var popupCards: [MapPopUpStore] = []
    private var currentIndex: Int = 0
    var currentVisibleIndex: Int {

        let centerX = self.contentOffset.x + self.bounds.width / 2

        for i in 0..<self.numberOfItems(inSection: 0) {
            guard let cell = self.cellForItem(at: IndexPath(item: i, section: 0)) else { continue }

            if cell.frame.minX <= centerX && centerX <= cell.frame.maxX {
                return i
            }
        }

        // 없으면 첫 번째 인덱스 반환
        return 0
    }

    // MARK: - Initialization
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal

        let screenWidth = UIScreen.main.bounds.width
        let itemWidth: CGFloat = 335
        let sideInset = (screenWidth - itemWidth) / 2

        layout.itemSize = CGSize(width: itemWidth, height: 137)
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(
            top: 0,
            left: sideInset,
            bottom: 0,
            right: sideInset
        )
        super.init(frame: frame, collectionViewLayout: layout)


        showsHorizontalScrollIndicator = false
        backgroundColor = .clear
        decelerationRate = .fast
        contentInsetAdjustmentBehavior = .always
        layer.cornerRadius = 12
        clipsToBounds = true

        setupCollectionView()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupCollectionView() {
        dataSource = self
        delegate = self
        register(PopupCardCell.self, forCellWithReuseIdentifier: PopupCardCell.identifier)
    }

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        if let indexPath = indexPathForItem(at: point),
           indexPath.item < popupCards.count {
            let store = popupCards[indexPath.item]
            onCardTapped?(store)
        }
    }

    // MARK: - Public Methods
    func updateCards(_ cards: [MapPopUpStore]) {
        guard popupCards != cards else { return }
        self.popupCards = cards
        reloadData()
    }

    func updateVisibility(for state: FloatingPanelState) {
        self.isHidden = (state == .full)
    }

    func scrollToCard(index: Int) {
        guard index >= 0, index < popupCards.count else { return }
        let indexPath = IndexPath(item: index, section: 0)
        scrollToItem(
            at: indexPath,
            at: .centeredHorizontally,
            animated: true
        )
    }
}

// MARK: - UIScrollViewDelegate
extension MapPopupCarouselView {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                 withVelocity velocity: CGPoint,
                                 targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = self.collectionViewLayout as! UICollectionViewFlowLayout
        let itemWidth = layout.itemSize.width
        let spacing = layout.minimumLineSpacing

        let pageWidth = itemWidth + spacing
        let offset = targetContentOffset.pointee.x

        let index = round(offset / pageWidth)
        let roundedOffset = pageWidth * index

        targetContentOffset.pointee = CGPoint(x: roundedOffset, y: 0)
        onCardScrolled?(Int(index))
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let cellWidth = layout.itemSize.width
        let spacing = layout.minimumLineSpacing
        let inset = layout.sectionInset.left
        let pageWidth = cellWidth + spacing
        let offsetWithInset = contentOffset.x + inset
        let pageIndex = Int(round(offsetWithInset / pageWidth))

        currentIndex = pageIndex
        onCardScrolled?(pageIndex)
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout
extension MapPopupCarouselView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popupCards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(
            withReuseIdentifier: PopupCardCell.identifier,
            for: indexPath
        ) as! PopupCardCell
        cell.configure(with: popupCards[indexPath.item])
        return cell
    }
}
