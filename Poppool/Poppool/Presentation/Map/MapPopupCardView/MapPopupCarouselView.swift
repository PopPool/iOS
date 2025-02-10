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

        // 스크롤 관련 속성 추가
        collectionView.decelerationRate = .fast  // 빠른 감속
        collectionView.isPagingEnabled = true    // 페이징 활성화

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
        self.popupCards = cards
        collectionView.reloadData()
    }

    func updateVisibility(for state: FloatingPanelState) {
        // 예: FloatingPanel 상태에 따라 숨김
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
        let pageWidth = scrollView.bounds.width
        let pageIndex = Int(scrollView.contentOffset.x / pageWidth)
        onCardScrolled?(pageIndex)
    }
}
