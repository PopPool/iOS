import UIKit
import SnapKit
import RxCocoa
import RxSwift
import ReactorKit
import FloatingPanel
import RxDataSources

final class StoreListViewController: UIViewController, View {
    typealias Reactor = StoreListReactor

    // MARK: - Properties

    var disposeBag = DisposeBag()
    private var isHeaderVisible: Bool = false
    private let mapPopupCarouselView = MapPopupCarouselView()
    let mainView = StoreListView()

    // MARK: - Init

    init(reactor: StoreListReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupCollectionView()
    }

    private func setupLayout() {
        view.backgroundColor = .clear
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupCollectionView() {
        mainView.collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        mainView.collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }

    func bind(reactor: Reactor) {
        let dataSource = RxCollectionViewSectionedReloadDataSource<StoreListSection>(
            configureCell: { [weak self] ds, cv, indexPath, item in
                guard let self = self else { return UICollectionViewCell() }
                let cell = cv.dequeueReusableCell(
                    withReuseIdentifier: StoreListCell.identifier,
                    for: indexPath
                ) as! StoreListCell

                cell.injection(with: .init(
                    thumbnailImage: nil,
                    category: item.category,
                    title: item.title,
                    location: item.location,
                    date: item.dateRange,
                    isBookmarked: item.isBookmarked
                ))
                // 북마크 버튼
                cell.bookmarkButton.rx.tap
                    .map { Reactor.Action.toggleBookmark(indexPath.item) }
                    .bind(to: reactor.action)
                    .disposed(by: cell.disposeBag)

                return cell
            }
        )

        reactor.state
            .map { state -> [StoreListSection] in
                // 단일 섹션 예시
                return [
                    StoreListSection(items: state.stores)
                ]
            }
            .bind(to: mainView.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        // 3) 아이템 선택
        mainView.collectionView.rx.itemSelected
            .map { Reactor.Action.didSelectItem($0.item) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 4) viewWillAppear -> viewDidLoad
        rx.viewWillAppear
            .map { _ in Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 5) **필터 상태** 관찰 → 바텀시트 열기/닫기
        reactor.state.map { $0.activeFilterType }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] filterType in
                guard let self = self else { return }
                if let filterType = filterType {
                    // 필터 유형이 생김 → 바텀시트 표시
                    self.presentFilterBottomSheet(for: filterType)
                } else {
                    // nil → 바텀시트 닫기
                    self.dismissFilterBottomSheet()
                }
            })
            .disposed(by: disposeBag)
    }

    private func presentFilterBottomSheet(for filterType: FilterType) {
        let sheetReactor = FilterBottomSheetReactor()
        let viewController = FilterBottomSheetViewController(reactor: sheetReactor)

        // 초기 세그먼트 인덱스
        let initialIndex = (filterType == .location) ? 0 : 1
        viewController.containerView.segmentedControl.selectedSegmentIndex = initialIndex
        sheetReactor.action.onNext(.segmentChanged(initialIndex))

        // onSave -> Reactor.Action.filterUpdated(filterType, ...)
        viewController.onSave = { [weak self] selectedOptions in
            guard let self = self else { return }
            // 닫기
            self.reactor?.action.onNext(.filterTapped(nil))
        }

        // onDismiss -> Reactor.Action.filterTapped(nil)
        viewController.onDismiss = { [weak self] in
            self?.reactor?.action.onNext(.filterTapped(nil))
        }

        viewController.modalPresentationStyle = .overFullScreen
        present(viewController, animated: false) {
            viewController.showBottomSheet()
        }
    }

    private func dismissFilterBottomSheet() {
        if let sheet = presentedViewController as? FilterBottomSheetViewController {
            sheet.hideBottomSheet()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension StoreListViewController: UICollectionViewDelegateFlowLayout {
    // 헤더 사이즈
    func collectionView(
        _ collectionView: UICollectionView,
        layout layout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return isHeaderVisible
            ? CGSize(width: collectionView.bounds.width, height: 120)
            : .zero
    }
}

extension StoreListViewController {
    func setGrabberHandleVisible(_ visible: Bool) {
        mainView.grabberHandle.isHidden = !visible
    }
}

// MARK: - UIGestureRecognizerDelegate (추가 권장)
extension StoreListViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
