import UIKit
import SnapKit
import FloatingPanel

final class MapPopupCarouselView: UIView {
    // MARK: - Components
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 335, height: 137)
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear


        collectionView.decelerationRate = .fast  // 빠른 감속
        collectionView.isPagingEnabled = false    // 페이징 활성화

        return collectionView
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
        // FlowLayout에서 셀 크기, 최소 간격, inset 값을 가져옵니다.
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        let cellWidth = layout.itemSize.width            // 예: 335
        let spacing = layout.minimumLineSpacing            // 예: 12
        let inset = layout.sectionInset.left               // 예: 20
        // 한 "페이지"의 폭은 셀 폭 + 간격 (단, 마지막 셀에는 간격이 없으므로 일반적으로 모든 셀에 적용된다고 가정)
        let pageWidth = cellWidth + spacing

        // 현재 오프셋에 inset을 더해 실제 콘텐츠 시작점부터의 오프셋으로 계산합니다.
        let offsetWithInset = scrollView.contentOffset.x + inset

        // 현재 오프셋을 페이지 폭으로 나눈 값을 반올림하면 목표 페이지 인덱스가 됩니다.
        let page = round(offsetWithInset / pageWidth)

        // 새 target offset은 목표 페이지 인덱스에 해당하는 오프셋에서 inset을 빼서 구합니다.
        let newOffsetX = page * pageWidth - inset
        targetContentOffset.pointee = CGPoint(x: newOffsetX, y: 0)
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
        // 여기서는 커스텀 스냅핑이 적용된 후이므로, targetContentOffset와 거의 일치한 값이 contentOffset에 반영됩니다.
        // effective pageWidth는 위에서 계산한 것과 동일합니다.
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
