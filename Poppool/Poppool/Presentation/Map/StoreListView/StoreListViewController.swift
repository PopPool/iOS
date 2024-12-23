import UIKit
import SnapKit
import RxCocoa
import RxSwift
import ReactorKit
import FloatingPanel

final class StoreListViewController: UIViewController, View {
    typealias Reactor = StoreListReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()
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
    }

    private func setupLayout() {
        view.backgroundColor = .clear
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func bind(reactor: Reactor) {
        rx.viewWillAppear
            .map { _ in Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.stores }
            .bind(to: mainView.collectionView.rx.items(
                cellIdentifier: StoreListCell.identifier,
                cellType: StoreListCell.self
            )) { _, item, cell in
                cell.injection(with: .init(
                    thumbnailImage: nil,
                    category: item.category,
                    title: item.title,
                    location: item.location,
                    date: item.dateRange,
                    isBookmarked: item.isBookmarked
                ))

                cell.bookmarkButton.rx.tap
                    .map { Reactor.Action.toggleBookmark(item.id) }
                    .bind(to: reactor.action)
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)

        mainView.collectionView.rx.itemSelected
            .map { Reactor.Action.didSelectItem($0.item) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

// MARK: - FloatingPanelControllerDelegate
extension StoreListViewController: FloatingPanelControllerDelegate {
   func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
       switch fpc.state {
       case .full:
           fpc.surfaceView.grabberHandle.isHidden = true
           mainView.backgroundColor = .white
           mainView.collectionView.backgroundColor = .white

       case .half:
           fpc.surfaceView.grabberHandle.isHidden = false
           mainView.backgroundColor = .clear
           mainView.collectionView.backgroundColor = .white

       default:
           break
       }
   }

   func floatingPanelShouldBeginDragging(_ fpc: FloatingPanelController) -> Bool {
       return true
   }
}
