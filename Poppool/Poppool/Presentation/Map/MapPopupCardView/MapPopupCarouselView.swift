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

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.decelerationRate = .fast
        cv.contentInsetAdjustmentBehavior = .always

        // 좌우 여백을 화면 중앙 정렬에 맞게 설정
        let screenWidth = UIScreen.main.bounds.width
        let inset = (screenWidth - 335) / 2  // (화면폭 - 카드폭) / 2
        cv.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)

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
        let cellWidth = layout.itemSize.width
        let spacing = layout.minimumLineSpacing

        // 현재 컬렉션뷰의 bounds를 기준으로 중앙 위치 계산
        let collectionViewWidth = collectionView.bounds.width
        let inset = (collectionViewWidth - cellWidth) / 2

        // 스크롤 위치 계산 (중앙 정렬 기준)
        let estimatedIndex = (targetContentOffset.pointee.x + inset) / (cellWidth + spacing)
        let index = round(estimatedIndex)

        // 최종 offset 계산 (중앙 정렬되도록)
        let finalOffset = (cellWidth + spacing) * index - inset
        targetContentOffset.pointee.x = max(0, finalOffset)

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
