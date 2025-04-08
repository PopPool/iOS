import CoreLocation
import PhotosUI
import UIKit

import Alamofire
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class PopUpStoreRegisterViewController: BaseViewController, View {
    typealias Reactor = PopUpStoreRegisterReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()
    private var pickerViewController: PHPickerViewController?
    private let adminUseCase: AdminUseCase
    private var nameField: UITextField?
    private var addressField: UITextField?
    private var latField: UITextField?
    private var lonField: UITextField?
    private var descTV: UITextView?
    var completionHandler: (() -> Void)?
    private let nickname: String

    // MARK: - UI Components
    private let navContainer = UIView()

    private lazy var imagesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 120)
        layout.minimumLineSpacing = 8

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "image_login_logo")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let accountIdLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lbl.textColor = .black
        return lbl
    }()

    private let menuButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "adminlist"), for: .normal)
        btn.tintColor = .black
        return btn
    }()

    private let titleContainer = UIView()
    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        btn.tintColor = .black
        return btn
    }()

    private let pageTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "팝업스토어 등록"
        lbl.font = UIFont.boldSystemFont(ofSize: 18)
        lbl.textColor = .black
        return lbl
    }()

    private let addImageButton = UIButton(type: .system).then {
        $0.setTitle("이미지 추가", for: .normal)
        $0.setTitleColor(.systemBlue, for: .normal)
    }

    private let removeAllButton = UIButton(type: .system).then {
        $0.setTitle("전체 삭제", for: .normal)
        $0.setTitleColor(.red, for: .normal)
    }

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let formBackgroundView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.cornerRadius = 8
    }

    private let verticalStack = UIStackView()

    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("저장", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .lightGray
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn.layer.cornerRadius = 8
        btn.isEnabled = false
        return btn
    }()

    private let categoryButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("카테고리 선택 ▾", for: .normal)
        btn.setTitleColor(.darkGray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.layer.cornerRadius = 8
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.contentHorizontalAlignment = .left
        btn.contentEdgeInsets = UIEdgeInsets(top: 7, left: 8, bottom: 7, right: 8)
        return btn
    }()

    private let periodButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("기간 선택 ▾", for: .normal)
        btn.setTitleColor(.darkGray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.layer.cornerRadius = 8
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.contentHorizontalAlignment = .left
        btn.contentEdgeInsets = UIEdgeInsets(top: 7, left: 8, bottom: 7, right: 8)
        return btn
    }()

    private let timeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("시간 선택 ▾", for: .normal)
        btn.setTitleColor(.darkGray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.layer.cornerRadius = 8
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.contentHorizontalAlignment = .left
        btn.contentEdgeInsets = UIEdgeInsets(top: 7, left: 8, bottom: 7, right: 8)
        return btn
    }()
    private func extractDateRange(from state: Reactor.State) -> (Date, Date)? {
        guard let start = state.selectedStartDate,
              let end = state.selectedEndDate else {
            return nil
        }
        return (start, end)
    }

    private func extractTimeRange(from state: Reactor.State) -> (Date, Date)? {
        guard let start = state.selectedStartTime,
              let end = state.selectedEndTime else {
            return nil
        }
        return (start, end)
    }

    private func areDateRangesEqual(_ prev: (Date, Date), _ current: (Date, Date)) -> Bool {
        return prev.0 == current.0 && prev.1 == current.1
    }
    // MARK: - Initializer
    init(nickname: String, adminUseCase: AdminUseCase, editingStore: GetAdminPopUpStoreListResponseDTO.PopUpStore? = nil) {
        self.nickname = nickname
        self.adminUseCase = adminUseCase

        super.init()

        let presignedService = PreSignedService()
        let reactor = PopUpStoreRegisterReactor(
            adminUseCase: adminUseCase,
            presignedService: presignedService,
            editingStore: editingStore
        )

        self.reactor = reactor
        self.accountIdLabel.text = nickname + "님"

        if editingStore != nil {
            pageTitleLabel.text = "팝업스토어 수정"

            // 편집 모드일 경우 스토어 상세 정보 로드
            if let storeId = editingStore?.id {
                reactor.action.onNext(.loadStoreDetail(storeId))
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        view.backgroundColor = UIColor(white: 0.95, alpha: 1)

        setupNavigation()
        setupLayout()
        setupRows()
        setupImageCollectionUI()
        setupKeyboardHandling()
    }

    // MARK: - ReactorKit Binding
    func bind(reactor: Reactor) {

        // 텍스트 필드 바인딩
        nameField?.rx.text.orEmpty
            .distinctUntilChanged()
            .skip(1)
            .map { Reactor.Action.updateName($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        addressField?.rx.text.orEmpty
            .distinctUntilChanged()
            .skip(1)
            .map { Reactor.Action.updateAddress($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        latField?.rx.text.orEmpty
            .distinctUntilChanged()
            .skip(1)
            .map { Reactor.Action.updateLat($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        lonField?.rx.text.orEmpty
            .distinctUntilChanged()
            .skip(1)
            .map { Reactor.Action.updateLon($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        descTV?.rx.text.orEmpty
            .distinctUntilChanged()
            .skip(1)
            .map { Reactor.Action.updateDescription($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 주소 변경 시 지오코딩 요청
        addressField?.rx.text.orEmpty
            .distinctUntilChanged()
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .filter { !$0.isEmpty }
            .map { Reactor.Action.geocodeAddress($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 이미지 버튼 바인딩
        addImageButton.rx.tap
            .bind { [weak self] in
                self?.showImagePicker()
            }
            .disposed(by: disposeBag)

        removeAllButton.rx.tap
            .map { Reactor.Action.removeAllImages }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 다양한 버튼 바인딩
        categoryButton.rx.tap
            .bind { [weak self] in
                self?.showCategoryPicker()
            }
            .disposed(by: disposeBag)

        periodButton.rx.tap
            .bind { [weak self] in
                self?.showDateRangePicker()
            }
            .disposed(by: disposeBag)

        timeButton.rx.tap
            .bind { [weak self] in
                self?.showTimeRangePicker()
            }
            .disposed(by: disposeBag)

        // 저장 버튼
        saveButton.rx.tap
            .map { Reactor.Action.save }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Outputs (Reactor -> View)

        // 저장 버튼 활성화 상태
        reactor.state.map { $0.isSaveEnabled }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] isEnabled in
                self?.saveButton.isEnabled = isEnabled
                self?.saveButton.backgroundColor = isEnabled ? .systemBlue : .lightGray
            })
            .disposed(by: disposeBag)

        // 로딩 상태
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] isLoading in
                if isLoading {
                    // 로딩 인디케이터 표시
                    self?.showLoadingIndicator()
                } else {
                    // 로딩 인디케이터 숨김
                    self?.hideLoadingIndicator()
                }
            })
            .disposed(by: disposeBag)

        // 에러 메시지
        reactor.state.map { $0.errorMessage }
            .distinctUntilChanged()
            .compactMap { $0 }
            .bind(onNext: { [weak self] message in
                self?.showErrorAlert(message: message)
                reactor.action.onNext(.clearError)
            })
            .disposed(by: disposeBag)

        // 성공 상태
        reactor.state.map { $0.isSuccess }
            .distinctUntilChanged()
            .filter { $0 }
            .bind(onNext: { [weak self] _ in
                self?.showSuccessAlert(isUpdate: reactor.currentState.isEditMode)
                reactor.action.onNext(.dismissSuccess)
            })
            .disposed(by: disposeBag)

        // 이미지 목록 업데이트
        reactor.state.map { $0.images }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] _ in
                self?.imagesCollectionView.reloadData()
            })
            .disposed(by: disposeBag)

        // 필드 값 업데이트
        reactor.state.map { $0.name }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] name in
                if self?.nameField?.text != name {
                    self?.nameField?.text = name
                }
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.address }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] address in
                if self?.addressField?.text != address {
                    self?.addressField?.text = address
                }
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.lat }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] lat in
                if self?.latField?.text != lat {
                    self?.latField?.text = lat
                }
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.lon }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] lon in
                if self?.lonField?.text != lon {
                    self?.lonField?.text = lon
                }
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.description }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] description in
                if self?.descTV?.text != description {
                    self?.descTV?.text = description
                }
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.category }
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .bind(onNext: { [weak self] category in
                self?.updateCategoryButtonTitle(with: category)
            })
            .disposed(by: disposeBag)

        // 날짜 범위 업데이트
        reactor.state
               .compactMap { [weak self] state in
                   self?.extractDateRange(from: state)
               }
               .distinctUntilChanged(areDateRangesEqual)
               .bind(onNext: { [weak self] dateRange in
                   self?.updatePeriodButtonTitle(start: dateRange.0, end: dateRange.1)
               })
               .disposed(by: disposeBag)

           // 시간 범위 업데이트
           reactor.state
               .compactMap { [weak self] state in
                   self?.extractTimeRange(from: state)
               }
               .distinctUntilChanged(areDateRangesEqual)
               .bind(onNext: { [weak self] timeRange in
                   self?.updateTimeButtonTitle(start: timeRange.0, end: timeRange.1)
               })
               .disposed(by: disposeBag)
       }
    // MARK: - UI Setup
    private func setupNavigation() {
        backButton.addTarget(self, action: #selector(onBack), for: .touchUpInside)
    }

    private func setupLayout() {
        // 상단 컨테이너
        view.addSubview(navContainer)
        navContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }

        navContainer.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.equalTo(22)
            make.height.equalTo(35)
        }

        navContainer.addSubview(accountIdLabel)
        accountIdLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(logoImageView.snp.right).offset(8)
        }

        navContainer.addSubview(menuButton)
        menuButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(16)
            make.width.height.equalTo(32)
        }

        // 타이틀 컨테이너
        view.addSubview(titleContainer)
        titleContainer.snp.makeConstraints { make in
            make.top.equalTo(navContainer.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }

        titleContainer.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(8)
            make.width.height.equalTo(32)
        }

        titleContainer.addSubview(pageTitleLabel)
        pageTitleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(backButton.snp.right).offset(4)
        }

        // 스크롤뷰
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleContainer.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-74)
        }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }

        // 저장 버튼
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(44)
        }
    }

    private func setupImageCollectionUI() {
        // 버튼 스택
        let buttonStack = UIStackView(arrangedSubviews: [addImageButton, removeAllButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 16

        contentView.addSubview(buttonStack)
        buttonStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }

        // 이미지 컬렉션 뷰
        contentView.addSubview(imagesCollectionView)
        imagesCollectionView.snp.makeConstraints { make in
            make.top.equalTo(buttonStack.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(130)
        }

        // 폼 배경
        contentView.addSubview(formBackgroundView)
        formBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(imagesCollectionView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }

        // 수직 스택
        formBackgroundView.addSubview(verticalStack)
        verticalStack.axis = .vertical
        verticalStack.spacing = 0
        verticalStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupRows() {
        // 이름 필드 추가
        addRowTextField(leftTitle: "이름", placeholder: "팝업스토어 이름을 입력해 주세요.")

        // 카테고리 버튼 추가
        addRowCustom(leftTitle: "카테고리", rightView: categoryButton)

        // 위치 필드 추가 (주소, 위도, 경도)
        let addressField = makeRoundedTextField("팝업스토어 주소를 입력해 주세요.")
        self.addressField = addressField

        let latLabel = makePlainLabel("위도")
        let latField = makeRoundedTextField("")
        latField.textAlignment = .center
        self.latField = latField

        let lonLabel = makePlainLabel("경도")
        let lonField = makeRoundedTextField("")
        lonField.textAlignment = .center
        self.lonField = lonField

        let latStack = UIStackView(arrangedSubviews: [latLabel, latField])
        latStack.axis = .horizontal
        latStack.spacing = 8
        latStack.distribution = .fillProportionally

        let lonStack = UIStackView(arrangedSubviews: [lonLabel, lonField])
        lonStack.axis = .horizontal
        lonStack.spacing = 8
        lonStack.distribution = .fillProportionally

        let latLonRow = UIStackView(arrangedSubviews: [latStack, lonStack])
        latLonRow.axis = .horizontal
        latLonRow.spacing = 16
        latLonRow.distribution = .fillEqually

        let locationVStack = UIStackView(arrangedSubviews: [addressField, latLonRow])
        locationVStack.axis = .vertical
        locationVStack.spacing = 8
        locationVStack.distribution = .fillEqually

        addRowCustom(leftTitle: "위치", rightView: locationVStack, rowHeight: nil, totalHeight: 80)

        // 마커 필드 추가
        let markerLabel = makePlainLabel("마커명")
        let markerField = makeRoundedTextField("")
        let markerStackH = UIStackView(arrangedSubviews: [markerLabel, markerField])
        markerStackH.axis = .horizontal
        markerStackH.spacing = 8
        markerStackH.distribution = .fillProportionally

        let snippetLabel = makePlainLabel("스니펫")
        let snippetField = makeRoundedTextField("")
        let snippetStackH = UIStackView(arrangedSubviews: [snippetLabel, snippetField])
        snippetStackH.axis = .horizontal
        snippetStackH.spacing = 8
        snippetStackH.distribution = .fillProportionally

        let markerVStack = UIStackView(arrangedSubviews: [markerStackH, snippetStackH])
        markerVStack.axis = .vertical
        markerVStack.spacing = 8
        markerVStack.distribution = .fillEqually

        addRowCustom(leftTitle: "마커", rightView: markerVStack, rowHeight: nil, totalHeight: 80)

        // 기간 및 시간
        addRowCustom(leftTitle: "기간", rightView: periodButton)
        addRowCustom(leftTitle: "시간", rightView: timeButton)

        // 작성자 및 작성시간
        let writerLbl = makeSimpleLabel(nickname)
        addRowCustom(leftTitle: "작성자", rightView: writerLbl)

        let timeLbl = setupCreationTimeLabel()
        addRowCustom(leftTitle: "작성시간", rightView: timeLbl)

        // 상태값
        let statusLbl = makeSimpleLabel("진행")
        addRowCustom(leftTitle: "상태값", rightView: statusLbl)

        // 설명
        let descTV = makeRoundedTextView()
        self.descTV = descTV
        addRowCustom(leftTitle: "설명", rightView: descTV, rowHeight: nil, totalHeight: 120)
    }

    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        scrollView.keyboardDismissMode = .interactive
    }

    // MARK: - Helper Methods
    private func addRowTextField(leftTitle: String, placeholder: String) {
        let tf = makeRoundedTextField(placeholder)
        if leftTitle == "이름" {
            nameField = tf
        } else if leftTitle == "주소" {
            addressField = tf
        }
        addRowCustom(leftTitle: leftTitle, rightView: tf)
    }

    private func addRowCustom(leftTitle: String,
                              rightView: UIView,
                              rowHeight: CGFloat? = 36,
                              totalHeight: CGFloat? = nil) {
        let row = UIView()
        row.backgroundColor = .white

        let leftBG = UIView()
        leftBG.backgroundColor = UIColor(white: 0.94, alpha: 1)
        row.addSubview(leftBG)
        leftBG.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
            make.width.equalTo(80)
        }

        let leftLabel = UILabel()
        leftLabel.text = leftTitle
        leftLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        leftLabel.textColor = .black
        leftLabel.textAlignment = .center
        leftBG.addSubview(leftLabel)
        leftLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview().inset(8)
        }

        let rightBG = UIView()
        rightBG.backgroundColor = .white
        row.addSubview(rightBG)
        rightBG.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.left.equalTo(leftBG.snp.right)
        }

        rightBG.addSubview(rightView)
        rightView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(7)
            make.bottom.equalToSuperview().offset(-7)
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            if let fixH = rowHeight {
                make.height.equalTo(fixH).priority(.medium)
            }
        }

        if let totalH = totalHeight {
            row.snp.makeConstraints { make in
                make.height.equalTo(totalH).priority(.high)
            }
        } else {
            row.snp.makeConstraints { make in
                make.height.greaterThanOrEqualTo(41)
            }
        }

        let separator = UIView()
        separator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        row.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }

        verticalStack.addArrangedSubview(row)
    }

    private func getCurrentFormattedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.string(from: Date())
    }

    private func setupCreationTimeLabel() -> UILabel {
        let currentTime = getCurrentFormattedTime()
        return makeSimpleLabel(currentTime)
    }

    private func makeRoundedTextField(_ placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = .darkGray
        tf.borderStyle = .none
        tf.layer.cornerRadius = 8
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.setLeftPaddingPoints(8)
        return tf
    }

    private func makeRoundedTextView() -> UITextView {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.textColor = .darkGray
        tv.layer.cornerRadius = 8
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.textContainerInset = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        tv.isScrollEnabled = true
        return tv
    }

    private func makePlainLabel(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = .darkGray
        lbl.textAlignment = .right
        lbl.setContentHuggingPriority(.required, for: .horizontal)
        return lbl
    }

    private func makeSimpleLabel(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = .darkGray
        return lbl
    }

    // MARK: - UI Interaction Methods
    @objc private func handleTap() {
        view.endEditing(true)
    }

    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
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

        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset

        // 현재 활성화된 필드가 키보드에 가려지는지 확인
        if let activeField = view.findFirstResponder() {
            let activeRect = activeField.convert(activeField.bounds, to: scrollView)
            let bottomOffset = activeRect.maxY + 20 // 여유 공간

            if bottomOffset > (scrollView.frame.height - keyboardHeight) {
                let scrollPoint = CGPoint(
                    x: 0,
                    y: bottomOffset - (scrollView.frame.height - keyboardHeight)
                )
                scrollView.setContentOffset(scrollPoint, animated: true)
            }
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.scrollView.contentInset = .zero
            self.scrollView.scrollIndicatorInsets = .zero
        }
    }

    private func showImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 0 // 무제한

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.pickerViewController = picker

        present(picker, animated: true, completion: nil)
    }

    private func showCategoryPicker() {
        let categories = ["게임", "라이프스타일", "반려동물", "뷰티", "스포츠", "애니메이션", "엔터테인먼트", "여행", "예술", "음식/요리", "키즈", "패션"]

        let alertController = UIAlertController(title: "카테고리 선택", message: nil, preferredStyle: .actionSheet)

        for category in categories {
            let action = UIAlertAction(title: category, style: .default) { [weak self] _ in
                self?.reactor?.action.onNext(.selectCategory(category))
            }
            alertController.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = categoryButton
            popoverController.sourceRect = categoryButton.bounds
        }

        present(alertController, animated: true, completion: nil)
    }

    private func showDateRangePicker() {
        DateTimePickerManager.shared.showDateRange(on: self) { [weak self] start, end in
            self?.reactor?.action.onNext(.selectDateRange(start: start, end: end))
        }
    }

    private func showTimeRangePicker() {
        DateTimePickerManager.shared.showTimeRange(on: self) { [weak self] start, end in
            self?.reactor?.action.onNext(.selectTimeRange(start: start, end: end))
        }
    }

    private func updateCategoryButtonTitle(with category: String) {
        categoryButton.setTitle("\(category) ▾", for: .normal)
    }

    private func updatePeriodButtonTitle(start: Date, end: Date) {
        let df = DateFormatter()
        df.dateFormat = "yyyy.MM.dd"
        let sStr = df.string(from: start)
        let eStr = df.string(from: end)

        periodButton.setTitle("\(sStr) ~ \(eStr)", for: .normal)
    }

    private func updateTimeButtonTitle(start: Date, end: Date) {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        let stStr = df.string(from: start)
        let etStr = df.string(from: end)

        timeButton.setTitle("\(stStr) ~ \(etStr)", for: .normal)
    }

    private func showLoadingIndicator() {
        // 로딩 인디케이터 표시 로직 구현
        // 예: Activity Indicator 또는 커스텀 로딩 뷰 표시
    }

    private func hideLoadingIndicator() {
        // 로딩 인디케이터 숨김 로직 구현
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
        present(alert, animated: true)
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
}
// MARK: - UICollectionView DataSource & Delegate
extension PopUpStoreRegisterViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reactor?.currentState.images.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageCell.identifier,
            for: indexPath
        ) as? ImageCell,
        let images = reactor?.currentState.images,
        indexPath.item < images.count else {
            return UICollectionViewCell()
        }

        let item = images[indexPath.item]
        cell.configure(with: item)

        // 대표이미지 변경
        cell.onMainCheckToggled = { [weak self] in
            self?.reactor?.action.onNext(.toggleMainImage(indexPath.item))
        }

        // 개별 삭제
        cell.onDeleteTapped = { [weak self] in
            self?.reactor?.action.onNext(.removeImage(indexPath.item))
        }

        return cell
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
        let existingPaths = Set(reactor?.currentState.images.map { $0.filePath } ?? [])

        for (index, provider) in itemProviders.enumerated() {
            if provider.canLoadObject(ofClass: UIImage.self) {
                dispatchGroup.enter()
                provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
                    defer { dispatchGroup.leave() }
                    guard let image = object as? UIImage else { return }

                    let name = self?.reactor?.currentState.name ?? "unnamed"
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
                self?.reactor?.action.onNext(.addImages(newImages))
            }
        }
    }
}

// MARK: - UITextView Delegate
extension PopUpStoreRegisterViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView == descTV {
            reactor?.action.onNext(.updateDescription(textView.text))
        }
    }
}

// MARK: - Helper Extensions
extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.size.height))
        leftView = paddingView
        leftViewMode = .always
    }
}

extension UIView {
    func findFirstResponder() -> UIView? {
        if isFirstResponder {
            return self
        }

        for subview in subviews {
            if let firstResponder = subview.findFirstResponder() {
                return firstResponder
            }
        }

        return nil
    }
}
