import DesignSystem
import Infrastructure
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class AdminBottomSheetViewController: BaseViewController, View {

   typealias Reactor = AdminBottomSheetReactor

   // MARK: - Properties
   private let mainView = AdminBottomSheetView()
   private lazy var dimmedView: UIView = {
       let view = UIView()
       view.backgroundColor = .black.withAlphaComponent(0.4)
       view.alpha = 0
       return view
   }()
   var disposeBag = DisposeBag()
   private var containerViewBottomConstraint: Constraint?
   private var containerHeightConstraint: Constraint?
   private var tagSection: TagSection?

   var onSave: (([String]) -> Void)?
   var onDismiss: (() -> Void)?

   // MARK: - Initialization
    init(reactor: AdminBottomSheetReactor) {
        super.init()
        self.reactor = reactor
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

   // MARK: - Life Cycle
   override func viewDidLoad() {
       super.viewDidLoad()
       view.backgroundColor = .clear
       setupViews()
       setupCollectionView()
   }

   // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .clear

        view.addSubview(dimmedView)
        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            containerHeightConstraint = make.height.greaterThanOrEqualTo(400).constraint
            containerViewBottomConstraint = make.bottom.equalTo(view.snp.bottom).constraint
        }

        setupGestures()
    }

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapDimmedView))
        tapGesture.delegate = self
        dimmedView.addGestureRecognizer(tapGesture)
        dimmedView.isUserInteractionEnabled = true
    }

    @objc private func handleTapDimmedView() {
        hideBottomSheet()
    }

   private func setupCollectionView() {
       mainView.contentCollectionView.register(
           TagSectionCell.self,
           forCellWithReuseIdentifier: TagSectionCell.identifiers
       )
   }

   // MARK: - Binding
   func bind(reactor: Reactor) {
       mainView.segmentedControl.rx.selectedSegmentIndex
           .map { Reactor.Action.segmentChanged($0) }
           .bind(to: reactor.action)
           .disposed(by: disposeBag)

       mainView.resetButton.rx.tap
           .map { Reactor.Action.resetFilters }
           .bind(to: reactor.action)
           .disposed(by: disposeBag)

       mainView.contentCollectionView.rx.itemSelected
           .withLatestFrom(reactor.state) { indexPath, state -> Reactor.Action in
               let title = state.activeSegment == 0 ?
                   state.statusOptions[indexPath.item] :
                   state.categoryOptions[indexPath.item]

               return state.activeSegment == 0 ?
                   .toggleStatusOption(title) :
                   .toggleCategoryOption(title)
           }
           .bind(to: reactor.action)
           .disposed(by: disposeBag)

       reactor.state
           .map { state in
               let items = state.activeSegment == 0 ?
                   state.statusOptions :
                   state.categoryOptions
               let selectedItems = state.activeSegment == 0 ?
                   state.selectedStatusOptions :
                   state.selectedCategoryOptions

               return items.map {
                   TagSectionCell.Input(
                       title: $0,
                       isSelected: selectedItems.contains($0),
                       id: nil
                   )
               }
           }
           .bind(to: mainView.contentCollectionView.rx.items(
               cellIdentifier: TagSectionCell.identifiers,
               cellType: TagSectionCell.self
           )) { _, item, cell in
               cell.injection(with: item)
           }
           .disposed(by: disposeBag)

       // 세그먼트 변경 시 전체 시트 높이 업데이트
       reactor.state.map { $0.activeSegment }
           .distinctUntilChanged()
           .bind { [weak self] _ in
               self?.updateContainerHeight()
           }
           .disposed(by: disposeBag)

       reactor.state.map { state -> [String] in
           state.activeSegment == 0 ?
               Array(state.selectedStatusOptions) :
               Array(state.selectedCategoryOptions)
       }
       .distinctUntilChanged()
       .bind { [weak self] selectedOptions in
           self?.mainView.filterChipsView.updateChips(with: selectedOptions)
       }
       .disposed(by: disposeBag)

       reactor.state.map { $0.isSaveEnabled }
           .distinctUntilChanged()
           .bind { [weak self] isEnabled in
               guard let self = self else { return }

               self.mainView.saveButton.isEnabled = isEnabled
               self.mainView.saveButton.backgroundColor = isEnabled ? .blu500 : .g100
               self.mainView.saveButton.setTitleColor(
                   isEnabled ? .white : .g400,
                   for: isEnabled ? .normal : .disabled
               )
               self.mainView.resetButton.isEnabled = isEnabled
           }
           .disposed(by: disposeBag)

       mainView.closeButton.rx.tap
           .bind { [weak self] in
               self?.hideBottomSheet()
           }
           .disposed(by: disposeBag)

       mainView.saveButton.rx.tap
           .withLatestFrom(reactor.state)
           .bind { [weak self] state in
               guard let self = self else { return }

               let selectedOptions = state.activeSegment == 0 ?
                   Array(state.selectedStatusOptions) :
                   Array(state.selectedCategoryOptions)

               self.onSave?(selectedOptions)
               self.hideBottomSheet()
           }
           .disposed(by: disposeBag)
   }

   // MARK: - Height Management
   private func updateContainerHeight() {
       guard let reactor = reactor else { return }

       let items = reactor.currentState.activeSegment == 0 ?
                   reactor.currentState.statusOptions :
                   reactor.currentState.categoryOptions

       let collectionViewHeight = mainView.calculateCollectionViewHeight(for: items)

       let totalHeight = 60 + 50 + collectionViewHeight + 80 + 52 + 100

       let finalHeight = min(max(totalHeight, 400), UIScreen.main.bounds.height * 0.8)

       containerHeightConstraint?.update(offset: finalHeight)

       self.view.layoutIfNeeded()
   }

   // MARK: - Show/Hide
   func showBottomSheet() {
       // 초기 높이 설정
       updateContainerHeight()

       UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
           self.dimmedView.alpha = 1
           self.containerViewBottomConstraint?.update(offset: 0)
           self.view.layoutIfNeeded()
       }
   }

   func hideBottomSheet() {
       UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
           self.dimmedView.alpha = 0
           self.containerViewBottomConstraint?.update(offset: self.view.bounds.height)
           self.view.layoutIfNeeded()
       } completion: { _ in
           self.dismiss(animated: false)
           self.onDismiss?()
       }
   }

   deinit {
       Logger.log("BottomSheet deinit", category: .debug)
   }
}

extension AdminBottomSheetViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer.view == dimmedView {
            let touchPoint = touch.location(in: view)
            return !mainView.containerView.frame.contains(touchPoint)
        }
        return true
    }
}
