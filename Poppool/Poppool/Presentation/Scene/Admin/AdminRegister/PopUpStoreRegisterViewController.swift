import CoreLocation
import PhotosUI
import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class PopUpStoreRegisterViewController: BaseViewController {

    // MARK: - Properties
    private var pickerViewController: PHPickerViewController?
    private let adminUseCase: AdminUseCase
    private let nickname: String
    var completionHandler: (() -> Void)?
    var disposeBag = DisposeBag()

    private var mainView: PopUpRegisterView

    // MARK: - Initializer
    init(nickname: String, adminUseCase: AdminUseCase, editingStore: GetAdminPopUpStoreListResponseDTO.PopUpStore? = nil) {
        self.nickname = nickname
        self.adminUseCase = adminUseCase
        self.mainView = PopUpRegisterView()

        super.init()

        let presignedService = PreSignedService()
        let reactor = PopUpStoreRegisterReactor(
            adminUseCase: adminUseCase,
            presignedService: presignedService,
            editingStore: editingStore
        )

        self.reactor = reactor
        self.mainView.accountIdLabel.text = nickname + "님"
        self.mainView.writerLabel.text = nickname

        if editingStore != nil {
            self.mainView.pageTitleLabel.text = "팝업스토어 수정"

            // 편집 모드일 경우 스토어 상세 정보 로드
            if let storeId = editingStore?.id {
                reactor.action.onNext(.loadStoreDetail(storeId))
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("\(#file), \(#function) Error")
    }
}

// MARK: - Life Cycle
extension PopUpStoreRegisterViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addViews()
        self.setupContstraints()
        self.configureUI()
        self.setupHandlers()

        if let reactor = self.reactor as? PopUpStoreRegisterReactor {
            self.bind(reactor: reactor)
        }
    }
}

// MARK: - Setup
private extension PopUpStoreRegisterViewController {
    func addViews() {
        self.view.addSubview(self.mainView)
    }

    func setupContstraints() {
        self.mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func configureUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }

    func setupHandlers() {
        // 뒤로가기 버튼
        self.mainView.backButton.addTarget(self, action: #selector(self.onBack), for: .touchUpInside)

        // 이미지 관련 버튼
        self.mainView.addImageButton.rx.tap
            .bind { [weak self] in
                self?.showImagePicker()
            }
            .disposed(by: self.disposeBag)
        self.mainView.removeAllButton.rx.tap
            .map { PopUpStoreRegisterReactor.Action.removeAllImages }
            .subscribe(onNext: { [weak self] action in
                (self?.reactor as? PopUpStoreRegisterReactor)?.action.onNext(action)
            })
            .disposed(by: self.disposeBag)

        self.mainView.categoryButton.rx.tap
            .bind { [weak self] in
                self?.showCategoryPicker()
            }
            .disposed(by: self.disposeBag)

        self.mainView.periodButton.rx.tap
            .bind { [weak self] in
                self?.showDateRangePicker()
            }
            .disposed(by: self.disposeBag)

        self.mainView.timeButton.rx.tap
            .bind { [weak self] in
                self?.showTimeRangePicker()
            }
            .disposed(by: self.disposeBag)

        // 이미지 컬렉션뷰 핸들러
        self.mainView.imagesCollectionView.onMainImageToggled = { [weak self] index in
            guard let reactor = self?.reactor as? PopUpStoreRegisterReactor else { return }
            reactor.action.onNext(.toggleMainImage(index))
        }

        self.mainView.imagesCollectionView.onImageDeleted = { [weak self] index in
            guard let reactor = self?.reactor as? PopUpStoreRegisterReactor else { return }
            reactor.action.onNext(.removeImage(index))
        }

        // 저장 버튼
        self.mainView.saveButton.rx.tap
            .map { PopUpStoreRegisterReactor.Action.save }
            .subscribe(onNext: { [weak self] action in
                (self?.reactor as? PopUpStoreRegisterReactor)?.action.onNext(action)
            })
            .disposed(by: self.disposeBag)

        self.setupKeyboardHandling()
    }

    func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        self.mainView.scrollView.keyboardDismissMode = .interactive
    }
}

// MARK: - UI Interaction Methods
extension PopUpStoreRegisterViewController {
    @objc private func handleTap() {
        self.view.endEditing(true)
    }

    @objc private func onBack() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        let keyboardHeight = keyboardFrame.height
        let contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: keyboardHeight,
            right: 0
        )

        self.mainView.scrollView.contentInset = contentInset
        self.mainView.scrollView.scrollIndicatorInsets = contentInset

        // 현재 활성화된 필드가 키보드에 가려지는지 확인
        if let activeField = self.view.findFirstResponder() {
            let activeRect = activeField.convert(activeField.bounds, to: self.mainView.scrollView)
            let bottomOffset = activeRect.maxY + 20 // 여유 공간

            if bottomOffset > (self.mainView.scrollView.frame.height - keyboardHeight) {
                let scrollPoint = CGPoint(
                    x: 0,
                    y: bottomOffset - (self.mainView.scrollView.frame.height - keyboardHeight)
                )
                self.mainView.scrollView.setContentOffset(scrollPoint, animated: true)
            }
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.mainView.scrollView.contentInset = .zero
            self.mainView.scrollView.scrollIndicatorInsets = .zero
        }
    }

    private func showImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 0 // 무제한

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.pickerViewController = picker

        self.present(picker, animated: true, completion: nil)
    }

    private func showCategoryPicker() {
        let categories = ["게임", "라이프스타일", "반려동물", "뷰티", "스포츠", "애니메이션", "엔터테인먼트", "여행", "예술", "음식/요리", "키즈", "패션"]

        let alertController = UIAlertController(title: "카테고리 선택", message: nil, preferredStyle: .actionSheet)

        for category in categories {
            let action = UIAlertAction(title: category, style: .default) { [weak self] _ in
                guard let reactor = self?.reactor as? PopUpStoreRegisterReactor else { return }
                reactor.action.onNext(.selectCategory(category))
            }
            alertController.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.mainView.categoryButton
            popoverController.sourceRect = self.mainView.categoryButton.bounds
        }

        self.present(alertController, animated: true, completion: nil)
    }

    private func showDateRangePicker() {
        DateTimePickerManager.shared.showDateRange(on: self) { [weak self] start, end in
            guard let reactor = self?.reactor as? PopUpStoreRegisterReactor else { return }
            reactor.action.onNext(.selectDateRange(start: start, end: end))
        }
    }

    private func showTimeRangePicker() {
        DateTimePickerManager.shared.showTimeRange(on: self) { [weak self] start, end in
            guard let reactor = self?.reactor as? PopUpStoreRegisterReactor else { return }
            reactor.action.onNext(.selectTimeRange(start: start, end: end))
        }
    }

    private func updateCategoryButtonTitle(with category: String) {
        self.mainView.categoryButton.setTitle("\(category) ▾", for: .normal)
    }

    private func updatePeriodButtonTitle(start: Date, end: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let startString = dateFormatter.string(from: start)
        let endString = dateFormatter.string(from: end)

        self.mainView.periodButton.setTitle("\(startString) ~ \(endString)", for: .normal)
    }

    private func updateTimeButtonTitle(start: Date, end: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let startString = dateFormatter.string(from: start)
        let endString = dateFormatter.string(from: end)

        self.mainView.timeButton.setTitle("\(startString) ~ \(endString)", for: .normal)
    }

    private func showSuccessAlert(isUpdate: Bool) {
        let message = isUpdate ? "팝업스토어가 성공적으로 수정되었습니다." : "팝업스토어가 성공적으로 등록되었습니다."
        let alert = UIAlertController(
            title: isUpdate ? "수정 성공" : "등록 성공",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.completionHandler?()  // 목록 새로고침
            self?.navigationController?.popViewController(animated: true)
        })
        self.present(alert, animated: true)
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
    }
}

// MARK: - ReactorKit Binding
extension PopUpStoreRegisterViewController: View {
    typealias Reactor = PopUpStoreRegisterReactor

    func bind(reactor: Reactor) {
        // MARK: - Input (View -> Reactor)
        self.mainView.nameField.rx.text.orEmpty
            .distinctUntilChanged()
            .map { Reactor.Action.updateName($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        self.mainView.addressField.rx.text.orEmpty
            .distinctUntilChanged()
            .map { Reactor.Action.updateAddress($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        self.mainView.latField.rx.text.orEmpty
            .distinctUntilChanged()
            .map { Reactor.Action.updateLat($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        self.mainView.lonField.rx.text.orEmpty
            .distinctUntilChanged()
            .map { Reactor.Action.updateLon($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        self.mainView.descriptionTextView.rx.text.orEmpty
            .distinctUntilChanged()
            .map { Reactor.Action.updateDescription($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        // 주소 변경 시 지오코딩 요청
        self.mainView.addressField.rx.text.orEmpty
            .distinctUntilChanged()
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .filter { !$0.isEmpty }
            .map { Reactor.Action.geocodeAddress($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        // MARK: - Output (Reactor -> View)
        // 저장 버튼 활성화 상태
        reactor.state.map { $0.isSaveEnabled }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] isEnabled in
                self?.mainView.saveButton.isEnabled = isEnabled
                self?.mainView.saveButton.backgroundColor = isEnabled ? .systemBlue : .lightGray
            })
            .disposed(by: self.disposeBag)

        // 로딩 상태
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.showLoadingIndicator()
                } else {
                    self?.hideLoadingIndicator()
                }
            })
            .disposed(by: self.disposeBag)

        // 에러 메시지
        reactor.state.map { $0.errorMessage }
            .distinctUntilChanged()
            .compactMap { $0 }
            .bind(onNext: { [weak self] message in
                self?.showErrorAlert(message: message)
                reactor.action.onNext(.clearError)
            })
            .disposed(by: self.disposeBag)

        // 성공 상태
        reactor.state.map { $0.isSuccess }
            .distinctUntilChanged()
            .filter { $0 }
            .bind(onNext: { [weak self] _ in
                self?.showSuccessAlert(isUpdate: reactor.currentState.isEditMode)
                reactor.action.onNext(.dismissSuccess)
            })
            .disposed(by: self.disposeBag)

        // 이미지 목록 업데이트
        reactor.state.map { $0.images }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] images in
                self?.mainView.imagesCollectionView.updateImages(images)
            })
            .disposed(by: self.disposeBag)

        // 필드 값 업데이트
        reactor.state.map { $0.name }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] name in
                if self?.mainView.nameField.text != name {
                    self?.mainView.nameField.text = name
                }
            })
            .disposed(by: self.disposeBag)

        reactor.state.map { $0.address }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] address in
                if self?.mainView.addressField.text != address {
                    self?.mainView.addressField.text = address
                }
            })
            .disposed(by: self.disposeBag)

        reactor.state.map { $0.lat }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] lat in
                if self?.mainView.latField.text != lat {
                    self?.mainView.latField.text = lat
                }
            })
            .disposed(by: self.disposeBag)

        reactor.state.map { $0.lon }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] lon in
                if self?.mainView.lonField.text != lon {
                    self?.mainView.lonField.text = lon
                }
            })
            .disposed(by: self.disposeBag)

        reactor.state.map { $0.description }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] description in
                if self?.mainView.descriptionTextView.text != description {
                    self?.mainView.descriptionTextView.text = description
                }
            })
            .disposed(by: self.disposeBag)

        reactor.state.map { $0.category }
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .bind(onNext: { [weak self] category in
                self?.updateCategoryButtonTitle(with: category)
            })
            .disposed(by: self.disposeBag)

        // 날짜 범위 업데이트
        let dateRangeObservable = reactor.state
            .compactMap { state -> (Date, Date)? in
                guard let start = state.selectedStartDate,
                      let end = state.selectedEndDate else {
                    return nil
                }
                return (start, end)
            }

        dateRangeObservable
            .distinctUntilChanged { prev, current in
                return prev.0 == current.0 && prev.1 == current.1
            }
            .bind(onNext: { [weak self] dateRange in
                self?.updatePeriodButtonTitle(start: dateRange.0, end: dateRange.1)
            })
            .disposed(by: self.disposeBag)

        // 시간 범위 업데이트
        let timeRangeObservable = reactor.state
            .compactMap { state -> (Date, Date)? in
                guard let start = state.selectedStartTime,
                      let end = state.selectedEndTime else {
                    return nil
                }
                return (start, end)
            }

        timeRangeObservable
            .distinctUntilChanged { prev, current in
                return prev.0 == current.0 && prev.1 == current.1
            }
            .bind(onNext: { [weak self] timeRange in
                self?.updateTimeButtonTitle(start: timeRange.0, end: timeRange.1)
            })
            .disposed(by: self.disposeBag)

    }
}

// MARK: - PHPickerViewController Delegate
extension PopUpStoreRegisterViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard !results.isEmpty else { return }

        let itemProviders = results.map(\.itemProvider)
        let dispatchGroup = DispatchGroup()
        var newImages = [ExtendedImage]()

        // 이미 로드된 이미지 경로 목록 (중복 방지)
        let existingPaths = Set((self.reactor as? PopUpStoreRegisterReactor)?.currentState.images.map { $0.filePath } ?? [])

        for (index, provider) in itemProviders.enumerated() {
            if provider.canLoadObject(ofClass: UIImage.self) {
                dispatchGroup.enter()
                provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
                    defer { dispatchGroup.leave() }
                    guard let image = object as? UIImage else { return }

                    let name = (self?.reactor as? PopUpStoreRegisterReactor)?.currentState.name ?? "unnamed"
                    let uuid = UUID().uuidString
                    let filePath = "PopUpImage/\(name)/\(uuid)/\(index).jpg"

                    // 이미 같은 경로가 있는지 확인
                    if !existingPaths.contains(filePath) {
                        let extended = ExtendedImage(
                            filePath: filePath,
                            image: image,
                            isMain: false
                        )
                        newImages.append(extended)
                    }
                }
            }
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            if !newImages.isEmpty {
                guard let reactor = self?.reactor as? PopUpStoreRegisterReactor else { return }
                reactor.action.onNext(.addImages(newImages))
            }
        }
    }
}
extension UIView {
    func findFirstResponder() -> UIView? {
        if self.isFirstResponder {
            return self
        }

        for subview in self.subviews {
            if let firstResponder = subview.findFirstResponder() {
                return firstResponder
            }
        }

        return nil
    }
}
