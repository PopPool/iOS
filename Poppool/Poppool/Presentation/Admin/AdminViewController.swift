import UIKit
import ReactorKit
import RxSwift
import RxCocoa

final class AdminViewController: BaseViewController, View {
    
    typealias Reactor = AdminReactor
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
      private let mainView: AdminView
      private var adminBottomSheetVC: AdminBottomSheetViewController?
      private var selectedFilterOption: String = "전체"
      private let nickname: String
    private let adminUseCase: AdminUseCase


    init(nickname: String, adminUseCase: AdminUseCase = DefaultAdminUseCase(repository: DefaultAdminRepository(provider: ProviderImpl()))) {
        self.nickname = nickname
        self.adminUseCase = adminUseCase
        self.mainView = AdminView(frame: .zero)
        super.init()
        mainView.usernameLabel.text = nickname + "님"
    }


      required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        
        // 로고 이미지에 탭 제스처 추가
        let logoTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLogo))
        mainView.logoImageView.isUserInteractionEnabled = true
        mainView.logoImageView.addGestureRecognizer(logoTapGesture)
        mainView.tableView.register(AdminStoreCell.self, forCellReuseIdentifier: AdminStoreCell.identifier)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Actions
    @objc private func didTapLogo() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapDropdownButton() {
        let reactor = AdminBottomSheetReactor()
        let bottomSheetVC = AdminBottomSheetViewController(reactor: reactor)

        bottomSheetVC.onSave = { [weak self] (selectedOptions: [String]) in
            guard let self = self else { return }
            self.selectedFilterOption = selectedOptions.joined(separator: ", ")
            self.mainView.dropdownButton.setTitle(self.selectedFilterOption, for: .normal)
        }

        bottomSheetVC.onDismiss = { [weak self] in
            guard let self = self else { return }
            self.adminBottomSheetVC = nil
        }

        bottomSheetVC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen

        present(bottomSheetVC, animated: false) {
            bottomSheetVC.showBottomSheet()
        }
        self.adminBottomSheetVC = bottomSheetVC
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
            .map { "총 \($0.count)건" }
            .bind(to: mainView.popupCountLabel.rx.text)
            .disposed(by: disposeBag)

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
                
                let registerVC = PopUpStoreRegisterViewController(nickname: self.nickname, adminUseCase: self.adminUseCase)
                self.navigationController?.pushViewController(registerVC, animated: true)

                // 이동 직후, 다시 false로
                reactor.action.onNext(.resetNavigation)
            })
            .disposed(by: disposeBag)
    }
}
