import UIKit
import SnapKit
import FloatingPanel

final class MapPopupCarouselView: UIView {
    private let collectionView: UICollectionView = {
          let layout = UICollectionViewFlowLayout()
          layout.scrollDirection = .horizontal

          // 화면 너비 기준으로 여백 계산
          let screenWidth = UIScreen.main.bounds.width
          let itemWidth: CGFloat = 335
          let sideInset = (screenWidth - itemWidth) / 2

          layout.itemSize = CGSize(width: itemWidth, height: 137)
          layout.minimumLineSpacing = 12
          layout.sectionInset = UIEdgeInsets(
              top: 0,
              left: sideInset,  // 첫 번째 아이템이 중앙에 오도록
              bottom: 0,
              right: sideInset  // 마지막 아이템도 중앙 정렬 가능하도록
          )

          let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
          cv.showsHorizontalScrollIndicator = false
          cv.backgroundColor = .clear
          cv.decelerationRate = .fast
          cv.contentInsetAdjustmentBehavior = .always
          return cv
      }()


    // 스크롤 멈췄을 때의 콜백 (카드 인덱스 전달)
    var onCardScrolled: ((Int) -> Void)?

    // 예: private로 유지
    private var popupCards: [MapPopUpStore] = []

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupCollectionView()
//        self.layer.cornerRadius = 16
//        self.layer.masksToBounds = true

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupLayout() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(16)
        }
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PopupCardCell.self, forCellWithReuseIdentifier: PopupCardCell.identifier)
    }

    // MARK: - Public Methods
    func updateCards(_ cards: [MapPopUpStore]) {
        guard popupCards != cards else { return }
        self.popupCards = cards
        collectionView.reloadData()
    }

    func updateVisibility(for state: FloatingPanelState) {
        self.isHidden = (state == .full)
    }

    func scrollToCard(index: Int) {
        guard index >= 0, index < popupCards.count else { return }
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(
            at: indexPath,
            at: UICollectionView.ScrollPosition.centeredHorizontally,
            animated: true
        )
    }
    
}

extension MapPopupCarouselView: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                 withVelocity velocity: CGPoint,
                                 targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let itemWidth = layout.itemSize.width
        let spacing = layout.minimumLineSpacing

        // 페이징 처리를 위한 너비
        let pageWidth = itemWidth + spacing
        let offset = targetContentOffset.pointee.x

        // 가장 가까운 페이지 계산
        let index = round(offset / pageWidth)
        let roundedOffset = pageWidth * index

        targetContentOffset.pointee = CGPoint(x: roundedOffset, y: 0)
        onCardScrolled?(Int(index))
    }
}


// MARK: - UICollectionView DataSource & Delegate
extension MapPopupCarouselView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popupCards.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PopupCardCell.identifier,
            for: indexPath
        ) as! PopupCardCell
        cell.configure(with: popupCards[indexPath.item])
        return cell
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let cellWidth = layout.itemSize.width
        let spacing = layout.minimumLineSpacing
        let inset = layout.sectionInset.left
        let pageWidth = cellWidth + spacing
        let offsetWithInset = scrollView.contentOffset.x + inset
        let pageIndex = Int(round(offsetWithInset / pageWidth))
        onCardScrolled?(pageIndex)
    }
}
