import ReactorKit
import RxCocoa
import RxSwift
import UIKit

final class AdminViewController: BaseViewController, View {

    typealias Reactor = AdminReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()
    private let mainView: AdminView
    private var adminBottomSheetVC: AdminBottomSheetViewController?
    private var selectedFilterOption: String = "전체"
    private let nickname: String
    private let adminUseCase: AdminUseCase

    // MARK: - Init
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
        setupMenuButton()

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

    // MARK: - Setup
    private func setUp() {
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        navigationItem.title = "팝업스토어 관리"
        mainView.dropdownButton.addTarget(self, action: #selector(didTapDropdownButton), for: .touchUpInside)
    }

    private func setupMenuButton() {
        let editAction = UIAction(
            title: "수정",
            image: UIImage(systemName: "pencil"),
            handler: { [weak self] _ in
                self?.showEditOptions()
            }
        )

        let deleteAction = UIAction(
            title: "삭제",
            image: UIImage(systemName: "trash"),
            attributes: .destructive,
            handler: { [weak self] _ in
                self?.showDeleteOptions()
            }
        )

        let menu = UIMenu(title: "", children: [editAction, deleteAction])
        mainView.menuButton.menu = menu
        mainView.menuButton.showsMenuAsPrimaryAction = true
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

    private func showEditOptions() {
        let alert = UIAlertController(title: "수정할 팝업스토어 선택", message: nil, preferredStyle: .actionSheet)

        reactor?.currentState.storeList.forEach { store in
            alert.addAction(UIAlertAction(title: store.name, style: .default) { [weak self] _ in
                self?.editStore(store)
            })
        }

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))

        // iPad support
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = mainView.menuButton
            popoverController.sourceRect = mainView.menuButton.bounds
        }

        present(alert, animated: true)
    }

    private func showDeleteOptions() {
        let alert = UIAlertController(title: "삭제할 팝업스토어 선택", message: nil, preferredStyle: .actionSheet)

        reactor?.currentState.storeList.forEach { store in
            alert.addAction(UIAlertAction(title: store.name, style: .destructive) { [weak self] _ in
                self?.showDeleteConfirmation(for: store)
            })
        }

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))

        // iPad support
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = mainView.menuButton
            popoverController.sourceRect = mainView.menuButton.bounds
        }

        present(alert, animated: true)
    }

    private func showDeleteConfirmation(for store: GetAdminPopUpStoreListResponseDTO.PopUpStore) {
        let alert = UIAlertController(
            title: "삭제 확인",
            message: "\(store.name)을(를) 삭제하시겠습니까?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.deleteStore(store)
        })

        present(alert, animated: true)
    }

    private func editStore(_ store: GetAdminPopUpStoreListResponseDTO.PopUpStore) {
        let registerVC = PopUpStoreRegisterViewController(
            nickname: nickname,
            adminUseCase: adminUseCase,
            editingStore: store
        )

        // 수정할 때도 completionHandler 추가
        registerVC.completionHandler = { [weak self] in
            self?.reactor?.action.onNext(.reloadData)
        }

        navigationController?.pushViewController(registerVC, animated: true)
    }

    private func deleteStore(_ store: GetAdminPopUpStoreListResponseDTO.PopUpStore) {
        let imageService = PreSignedService()

        imageService.tryDelete(targetPaths: .init(objectKeyList: [store.mainImageUrl]))
            .andThen(adminUseCase.deleteStore(id: store.id))
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] _ in
                    self?.reactor?.action.onNext(.reloadData)
                    ToastMaker.createToast(message: "삭제되었습니다")
                },
                onError: { [weak self] error in
                    self?.showErrorAlert(message: "삭제 실패: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)
    }
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Reactor Binding
    func bind(reactor: Reactor) {
        mainView.searchInput.rx.text.orEmpty
            .distinctUntilChanged()
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.updateSearchQuery($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.registerButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let registerVC = PopUpStoreRegisterViewController(
                    nickname: self.nickname,
                    adminUseCase: self.adminUseCase
                )

                registerVC.completionHandler = { [weak self] in
                    self?.reactor?.action.onNext(.reloadData)
                }

                self.navigationController?.pushViewController(registerVC, animated: true)
            })
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.selectedStoreForEdit }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] store in
                guard let self = self else { return }
                self.editStore(store)
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.storeList }
            .map { "총 \($0.count)개" }
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
    }
}
