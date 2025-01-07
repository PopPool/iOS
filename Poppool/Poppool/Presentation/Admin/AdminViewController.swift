import UIKit
import ReactorKit
import RxSwift
import RxCocoa

final class AdminViewController: BaseViewController, View {

    typealias Reactor = AdminReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()
    private var mainView = AdminView()
    private var adminBottomSheetVC: AdminBottomSheetViewController?
    private var selectedFilterOption: String = "전체"

}

// MARK: - Life Cycle
extension AdminViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// MARK: - SetUp
private extension AdminViewController {
    func setUp() {
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        navigationItem.title = "팝업스토어 관리"
        
        mainView.dropdownButton.addTarget(self, action: #selector(didTapDropdownButton), for: .touchUpInside)
    }
    
    @objc private func didTapDropdownButton() {
        let bottomSheetVC = AdminBottomSheetViewController()

        bottomSheetVC.onSave = { [weak self] selectedOptions in
            guard let self = self else { return }
            self.selectedFilterOption = selectedOptions.joined(separator: ", ")
            self.mainView.dropdownButton.setTitle(self.selectedFilterOption, for: .normal)
        }

        // BottomSheet 스타일 적용
        bottomSheetVC.modalPresentationStyle = .custom

        present(bottomSheetVC, animated: true)
        self.adminBottomSheetVC = bottomSheetVC
    }
}
// MARK: - ReactorKit Bindings
extension AdminViewController {
    func bind(reactor: Reactor) {

        // 1) 검색어 입력 -> updateSearchQuery
        mainView.searchInput.rx.text.orEmpty
            .distinctUntilChanged()
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.updateSearchQuery($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 2) 등록 버튼 탭 -> tapRegisterButton
        mainView.registerButton.rx.tap
            .map { Reactor.Action.tapRegisterButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 3) 테이블 바인딩
        reactor.state.map { $0.storeList }
            .bind(to: mainView.tableView.rx.items(
                cellIdentifier: AdminStoreCell.identifier,
                cellType: AdminStoreCell.self
            )) { _, item, cell in
                cell.configure(with: item)
            }
            .disposed(by: disposeBag)

        // 4) shouldNavigateToRegister == true -> 등록화면 이동
        reactor.state.map { $0.shouldNavigateToRegister }
            .distinctUntilChanged()
            .filter { $0 == true }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let registerVC = PopUpStoreRegisterViewController()
                self.navigationController?.pushViewController(registerVC, animated: true)

                // 이동 직후, 다시 false로
                reactor.action.onNext(.resetNavigation)
            })
            .disposed(by: disposeBag)
    }
}
