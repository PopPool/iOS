import FloatingPanel
import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift
import SnapKit
import UIKit

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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let currentStores = reactor?.currentState.stores {
            reactor?.action.onNext(.setStores(currentStores))
        }
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
        mainView.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func bind(reactor: Reactor) {
        let dataSource = RxCollectionViewSectionedReloadDataSource<StoreListSection>(
            configureCell: { [weak self] _, cv, indexPath, item in
                guard let self = self else { return UICollectionViewCell() }
                let cell = cv.dequeueReusableCell(
                    withReuseIdentifier: StoreListCell.identifier,
                    for: indexPath
                ) as! StoreListCell

                cell.injection(with: .init(
                    thumbnailURL: item.thumbnailURL,
                    category: item.category,
                    title: item.title,
                    location: item.location,
                    date: item.formattedDateRange,
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
                return [ StoreListSection(items: state.stores) ]
            }
            .bind(to: mainView.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        // 찜한 팝업 토스트 처리 체인
        reactor.state
            .map { $0.shouldShowBookmarkToast }
            .distinctUntilChanged()
            .filter { $0 == true }
            .observe(on: MainScheduler.instance)
            .bind { isBookmarking in
                let toastView = BookMarkToastView(isBookMark: isBookmarking)
                if isBookmarking {
                    toastView.moveButton.rx.tap
                        .subscribe(onNext: { [weak self] in
                            // 이동 처리 (예: 찜한 팝업 리스트 페이지로 이동)
                        })
                        .disposed(by: self.disposeBag)
                }
                ToastMaker.createBookMarkToast(isBookMark: isBookmarking)
            }
            .disposed(by: disposeBag)

        // 3) 아이템 선택
        mainView.collectionView.rx.itemSelected
            .withUnretained(self)
            .subscribe(onNext: { owner, indexPath in
                guard indexPath.item < owner.reactor?.currentState.stores.count ?? 0,
                      let store = owner.reactor?.currentState.stores[indexPath.item] else { return }

                let detailController = DetailController()
                detailController.reactor = DetailReactor(popUpID: Int64(store.id))

                owner.navigationController?.isNavigationBarHidden = false
                owner.navigationController?.tabBarController?.tabBar.isHidden = false

                owner.navigationController?.pushViewController(detailController, animated: true)
            })
            .disposed(by: disposeBag)

        // 4) viewWillAppear -> viewDidLoad
//        rx.viewWillAppear
//            .map { _ in Reactor.Action.viewDidLoad }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)

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
//        mainView.collectionView.rx.willDisplayCell
//            .map { cell, indexPath in
//                // 마지막 셀에 도달하면 다음 페이지 로드
//                if indexPath.item == reactor.currentState.stores.count - 1 {
//                    return Reactor.Action.loadNextPage
//                }
//                return nil
//            }
//            .compactMap { $0 }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)

    }

    private func presentFilterBottomSheet(for filterType: FilterType) {
        let sheetReactor = FilterBottomSheetReactor()
        let viewController = FilterBottomSheetViewController(reactor: sheetReactor)

        // 초기 세그먼트 인덱스
        let initialIndex = (filterType == .location) ? 0 : 1
        viewController.containerView.segmentedControl.selectedSegmentIndex = initialIndex
        sheetReactor.action.onNext(.segmentChanged(initialIndex))

        viewController.onSave = { [weak self] _ in
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
