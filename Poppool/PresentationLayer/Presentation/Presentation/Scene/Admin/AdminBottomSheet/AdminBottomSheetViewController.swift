import UIKit

import Infrastructure
import DesignSystem

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class AdminBottomSheetViewController: BaseViewController, View {

   typealias Reactor = AdminBottomSheetReactor

   // MARK: - Properties
   private let mainView = AdminBottomSheetView()
   private let dimmedView = UIView()
   var disposeBag = DisposeBag()
   private var containerViewBottomConstraint: Constraint?
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

        Logger.log("초기 뷰 계층:", category: .debug)

        view.addSubview(mainView)
        mainView.isUserInteractionEnabled = true
        mainView.containerView.isUserInteractionEnabled = true
        mainView.closeButton.isUserInteractionEnabled = true
        mainView.segmentedControl.isUserInteractionEnabled = true
        mainView.headerView.isUserInteractionEnabled = true

        mainView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(view.bounds.height * 0.45)
            containerViewBottomConstraint = make.bottom.equalTo(view.snp.bottom).constraint
        }

        Logger.log("mainView 추가 후 계층:", category: .debug)

        dimmedView.backgroundColor = .black.withAlphaComponent(0.4)
        dimmedView.alpha = 0
        dimmedView.isUserInteractionEnabled = false

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped))
        dimmedView.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = true // 터치 이벤트가 다른 뷰로 전달되도록 설정
        view.insertSubview(dimmedView, belowSubview: mainView)

        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        Logger.log("최종 뷰 계층:", category: .debug)
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
                 .do(onNext: { _ in
                 })
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

       reactor.state.map { state in
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

       reactor.state.map { $0.activeSegment }
           .distinctUntilChanged()
           .bind { [weak self] index in
               self?.mainView.updateContentVisibility(isCategorySelected: index == 1)
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

       // View Events
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

   // MARK: - Actions
   @objc private func dimmedViewTapped() {
       hideBottomSheet()
   }

   // MARK: - Show/Hide
   func showBottomSheet() {
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
