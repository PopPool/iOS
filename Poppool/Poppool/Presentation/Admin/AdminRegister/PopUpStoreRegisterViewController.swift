import UIKit
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa
import PhotosUI
import Alamofire
import GoogleMaps
import CoreLocation

final class PopUpStoreRegisterViewController: BaseViewController {

    // MARK: - Navigation/Header
    var completionHandler: (() -> Void)?
    private var selectedImages: [UIImage] = []
    private var selectedMainImageIndex: Int?
    private var imageFileNames: [String] = []
    private var images: [ExtendedImage] = []
    private var pickerViewController: PHPickerViewController?
    private let adminUseCase: AdminUseCase
    private var nameField: UITextField?
    private var addressField: UITextField?
    private var latField: UITextField?
    private var lonField: UITextField?
    private var descTV: UITextView?


    private let popupName: String = ""
    private let editingStore: GetAdminPopUpStoreListResponseDTO.PopUpStore?
    let presignedService = PreSignedService()

    var disposeBag = DisposeBag()
    private let nickname: String
    private let navContainer = UIView()

    init(nickname: String, adminUseCase: AdminUseCase, editingStore: GetAdminPopUpStoreListResponseDTO.PopUpStore? = nil) {
        self.nickname = nickname
        self.adminUseCase = adminUseCase
        self.editingStore = editingStore
        super.init()
        self.accountIdLabel.text = nickname + "님"
        if editingStore != nil {
            pageTitleLabel.text = "팝업스토어 수정"
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

    // MARK: - Title (Back button + label)
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

    // MARK: - Scroll
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: - Form Background
    private let formBackgroundView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.lightGray.cgColor
        v.layer.cornerRadius = 8
        return v
    }()
    private let verticalStack = UIStackView()

    // MARK: - Bottom Save Button
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

    // MARK: - DateTimePicker
    private var selectedStartDate: Date?
    private var selectedEndDate: Date?
    private var selectedStartTime: Date?
    private var selectedEndTime: Date?

    // MARK: - Categories
    private var categories: [String] = ["게임", "라이프스타일", "반려동물", "뷰티", "스포츠", "애니메이션", "엔터테인먼트", "여행", "예술", "음식/요리", "키즈", "패션"]

    // MARK: - UI Elements
    private let categoryButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("카테고리 선택 ▾", for: .normal)
        btn.setTitleColor(.darkGray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize:14)
        btn.layer.cornerRadius = 8
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.contentHorizontalAlignment = .left
        btn.contentEdgeInsets = UIEdgeInsets(top:7, left:8, bottom:7, right:8)
        return btn
    }()

    private let periodButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("기간 선택 ▾", for: .normal)
        btn.setTitleColor(.darkGray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize:14)
        btn.layer.cornerRadius = 8
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.contentHorizontalAlignment = .left
        btn.contentEdgeInsets = UIEdgeInsets(top:7, left:8, bottom:7, right:8)
        return btn
    }()

    private let timeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("시간 선택 ▾", for: .normal)
        btn.setTitleColor(.darkGray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize:14)
        btn.layer.cornerRadius = 8
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.contentHorizontalAlignment = .left
        btn.contentEdgeInsets = UIEdgeInsets(top:7, left:8, bottom:7, right:8)
        return btn
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white:0.95, alpha:1)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        if let store = editingStore {
            loadStoreDetail(for: store.id)
        }

        setupNavigation()
        setupLayout()
        setupRows()
        setupImageCollectionUI()
        setupImageCollectionActions()
        setupKeyboardHandling()
        setupAddressField()


    }


    // MARK: - Navigation
    private func setupNavigation() {
        backButton.addTarget(self, action: #selector(onBack), for: .touchUpInside)
    }

    @objc private func handleTap() {
        view.endEditing(true)
    }
    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
    }
    @objc private func fieldDidChange(_ textField: UITextField) {
        if textField == addressField {
            Logger.log(message: "주소 값 변경: \(textField.text ?? "nil")", category: .debug)
        } else if textField == latField {
            Logger.log(message: "위도 값 변경: \(textField.text ?? "nil")", category: .debug)
        } else if textField == lonField {
            Logger.log(message: "경도 값 변경: \(textField.text ?? "nil")", category: .debug)
            updateSaveButtonState()

        }
    }
    private func fillFormWithExistingData(_ storeDetail: GetAdminPopUpStoreDetailResponseDTO) {
        nameField?.text = storeDetail.name
        categoryButton.setTitle("\(storeDetail.categoryName) ▾", for: .normal)
        addressField?.text = storeDetail.address
        latField?.text = String(storeDetail.latitude)
        lonField?.text = String(storeDetail.longitude)
        descTV?.text = storeDetail.desc

        let isoFormatter = ISO8601DateFormatter()
        
        if let startDate = isoFormatter.date(from: storeDetail.startDate),
           let endDate = isoFormatter.date(from: storeDetail.endDate) {
            self.selectedStartDate = startDate
            self.selectedEndDate = endDate
            self.updatePeriodButtonTitle()  // 버튼에 날짜 텍스트 업데이트
        }

        // 대표 이미지 로드 (생략된 부분은 기존 코드 참고)
        if let mainImageURL = presignedService.fullImageURL(from: storeDetail.mainImageUrl) {
            URLSession.shared.dataTask(with: mainImageURL) { [weak self] data, response, error in
                guard let self = self,
                      let data = data,
                      let image = UIImage(data: data) else { return }
                let extendedImage = ExtendedImage(filePath: storeDetail.mainImageUrl, image: image, isMain: true)
                DispatchQueue.main.async {
                    self.images.append(extendedImage)
                    self.imagesCollectionView.reloadData()
                    self.updateSaveButtonState()
                }
            }.resume()
        }
    }
    func loadStoreDetail(for storeId: Int64) {
        Logger.log(message: "상세 정보 요청 시작 - Store ID: \(storeId)", category: .debug)

        adminUseCase.fetchStoreDetail(id: storeId)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] storeDetail in
                Logger.log(message: "상세 정보 요청 성공", category: .info)
                self?.fillFormWithExistingData(storeDetail)
            }, onError: { error in
                Logger.log(message: "상세 정보 요청 실패: \(error.localizedDescription)", category: .error)
            })
            .disposed(by: disposeBag)
    }

    private func setupKeyboardHandling() {
        // 키보드 Notification 등록
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

        // 스크롤뷰 키보드 처리 설정
        scrollView.keyboardDismissMode = .interactive
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



    // MARK: - Layout
    private func setupLayout() {
        // (1) 상단 컨테이너
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

        // (2) 타이틀 컨테이너
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

        // (3) 스크롤뷰
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

        // (4) 이미지 영역 추가
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

        contentView.addSubview(imagesCollectionView)
        imagesCollectionView.snp.makeConstraints { make in
            make.top.equalTo(buttonStack.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(130)
        }

        // (5) 폼 배경
        contentView.addSubview(formBackgroundView)
        formBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(imagesCollectionView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }

        formBackgroundView.addSubview(verticalStack)
        verticalStack.axis = .vertical
        verticalStack.spacing = 0
        verticalStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // (6) 저장 버튼
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(44)
        }
    }
    // MARK: - Setup Rows
    private func setupRows() {
        addRowTextField(leftTitle: "이름", placeholder: "팝업스토어 이름을 입력해 주세요.")
        addRowTextField(leftTitle: "이미지", placeholder: "팝업스토어 대표 이미지를 업로드 해주세요.")

        categoryButton.addTarget(self, action: #selector(didTapCategoryButton), for: .touchUpInside)
        addRowCustom(leftTitle: "카테고리", rightView: categoryButton)

        // (위치) => 2줄
        // 1) 주소 (TextField)
        let addressField = makeRoundedTextField("팝업스토어 주소를 입력해 주세요.")
        self.addressField = addressField
        addressField.snp.makeConstraints { make in
            addressField.addTarget(self, action: #selector(fieldDidChange(_:)), for: .editingChanged)

        }

        // 2) (위도 Label + TF) + (경도 Label + TF)
        let latLabel = makePlainLabel("위도")
        let latField = makeRoundedTextField("")
        latField.textAlignment = .center
        self.latField = latField // latField와 연결
        latField.addTarget(self, action: #selector(fieldDidChange(_:)), for: .editingChanged)


        let lonLabel = makePlainLabel("경도")
        let lonField = makeRoundedTextField("")
        self.lonField = lonField // lonField와 연결
        lonField.textAlignment = .center
        lonField.addTarget(self, action: #selector(fieldDidChange(_:)), for: .editingChanged)


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

        // 수직 스택(주소, latLonRow)
        let locationVStack = UIStackView(arrangedSubviews: [addressField, latLonRow])
        locationVStack.axis = .vertical
        locationVStack.spacing = 8
        locationVStack.distribution = .fillEqually


        // 한 행에 왼쪽 "위치", 오른쪽 2줄(주소 / 위도경도)
        addRowCustom(leftTitle: "위치", rightView: locationVStack, rowHeight: nil, totalHeight: 80)

        // (마커) => 2줄
        // 1) (마커명 Label + TF)
        let markerLabel = makePlainLabel("마커명")
        
        let markerField = makeRoundedTextField("")
        
        let markerStackH = UIStackView(arrangedSubviews: [markerLabel, markerField])
        markerStackH.axis = .horizontal
        markerStackH.spacing = 8
        markerStackH.distribution = .fillProportionally

        // 2) (스니펫 Label + TF)
        let snippetLabel = makePlainLabel("스니펫")
        let snippetField = makeRoundedTextField("")
        let snippetStackH = UIStackView(arrangedSubviews: [snippetLabel, snippetField])
        snippetStackH.axis = .horizontal
        snippetStackH.spacing = 8
        snippetStackH.distribution = .fillProportionally

        // 수직
        let markerVStack = UIStackView(arrangedSubviews: [markerStackH, snippetStackH])
        markerVStack.axis = .vertical
        markerVStack.spacing = 8
        markerVStack.distribution = .fillEqually


        // 한 행 => "마커" 라벨, 오른쪽 2줄 (마커명, 스니펫)
        addRowCustom(leftTitle: "마커", rightView: markerVStack, rowHeight: nil, totalHeight: 80)

        // (10) 기간
        periodButton.addTarget(self, action: #selector(didTapPeriodButton), for: .touchUpInside)
        addRowCustom(leftTitle: "기간", rightView: periodButton)

        // (11) 시간
        timeButton.addTarget(self, action: #selector(didTapTimeButton), for: .touchUpInside)
        addRowCustom(leftTitle: "시간", rightView: timeButton)

        // (12) 작성자
        let writerLbl = makeSimpleLabel(nickname)
        addRowCustom(leftTitle: "작성자", rightView: writerLbl)

        // (13) 작성시간
        let timeLbl = makeSimpleLabel("2025.01.06 10:30")
        addRowCustom(leftTitle: "작성시간", rightView: timeLbl)

        // (14) 상태값
        let statusLbl = makeSimpleLabel("진행")
        addRowCustom(leftTitle: "상태값", rightView: statusLbl)

        // (15) 설명
        let descTV = makeRoundedTextView()
        self.descTV = descTV // 설명 필드 연결
        addRowCustom(leftTitle: "설명", rightView: descTV, rowHeight: nil, totalHeight: 120)

    }


    // MARK: - Row

    private func addRowTextField(leftTitle: String, placeholder: String) {
        let tf = makeRoundedTextField(placeholder)
        if leftTitle == "이름" {
            nameField = tf // 이름 필드 연결
        } else if leftTitle == "주소" {
            addressField = tf // 주소 필드 연결
        }
        addRowCustom(leftTitle: leftTitle, rightView: tf)
    }

    private func setupImageCollectionUI() {
        // 1) 상단 버튼들 (Add / RemoveAll)
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

        // 2) CollectionView
        contentView.addSubview(imagesCollectionView)
        imagesCollectionView.snp.makeConstraints { make in
            make.top.equalTo(buttonStack.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(130)  // 셀 높이(120) + 패딩
        }

        // formBackgroundView를 아래로 조금 내려야 한다면?
        formBackgroundView.snp.remakeConstraints { make in
            make.top.equalTo(imagesCollectionView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
    }
    private func setupImageCollectionActions() {
        // (1) 이미지 추가 버튼 -> 앨범 열기
        addImageButton.rx.tap
            .bind { [weak self] in
                self?.showImagePicker()
            }
            .disposed(by: disposeBag)

        // (2) 전체 삭제 버튼
        removeAllButton.rx.tap
            .bind { [weak self] in
                self?.images.removeAll()
                self?.imagesCollectionView.reloadData()
                self?.updateSaveButtonState()
            }
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                // 1) 유효성 검사
                if self.validateForm() {
                    // 2) OK -> 등록 로직
                    self.doRegister()
                } else {
                    // 3) 실패 -> Alert/toast
                    let alert = UIAlertController(
                        title: "필수값 미입력",
                        message: "필수 항목을 모두 입력해 주세요.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)
    }
    // 저장 버튼 활성화 여부 갱신
    private func updateSaveButtonState() {
        let isFormValid = validateForm() // 폼 유효성 검사 결과
        saveButton.isEnabled = isFormValid
        saveButton.backgroundColor = isFormValid ? .systemBlue : .lightGray
    }

    /**
     rowHeight: 기본(41)
     totalHeight: 2줄 필요한 경우(90~100), 3줄 등 필요 시 더 크게
     */
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

    @objc private func didTapPeriodButton() {
        DateTimePickerManager.shared.showDateRange(on: self) { [weak self] start, end in
            guard let self = self else { return }
            self.selectedStartDate = start
            self.selectedEndDate = end
            self.updatePeriodButtonTitle()
            self.updateSaveButtonState() // 날짜 선택 후 저장 버튼 상태 업데이트
        }
    }

    @objc private func didTapTimeButton() {
        DateTimePickerManager.shared.showTimeRange(on: self) { [weak self] st, et in
            guard let self = self else { return }
            self.selectedStartTime = st
            self.selectedEndTime = et
            self.updateTimeButtonTitle()
            self.updateSaveButtonState() // 시간 선택 후 저장 버튼 상태 업데이트
        }
    }

    private func updatePeriodButtonTitle() {
        guard let s = selectedStartDate, let e = selectedEndDate else { return }
        let df = DateFormatter()
        df.dateFormat = "yyyy.MM.dd"
        let sStr = df.string(from: s)
        let eStr = df.string(from: e)

        periodButton.setTitle("\(sStr) ~ \(eStr)", for: .normal)
    }

    private func updateTimeButtonTitle() {
        guard let st = selectedStartTime, let et = selectedEndTime else { return }
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        let stStr = df.string(from: st)
        let etStr = df.string(from: et)
        timeButton.setTitle("\(stStr) ~ \(etStr)", for: .normal)
    }

    // MARK: - Category Selection

    @objc private func didTapCategoryButton() {
        let alertController = UIAlertController(title: "카테고리 선택", message: nil, preferredStyle: .actionSheet)

        // 기존 카테고리 목록 추가
        for category in categories {
            let action = UIAlertAction(title: category, style: .default) { [weak self] _ in
                self?.updateCategoryButtonTitle(with: category)
            }
            alertController.addAction(action)
        }

        // '카테고리 추가' 옵션 추가
        let addAction = UIAlertAction(title: "카테고리 추가", style: .default) { [weak self] _ in
            self?.presentAddCategoryAlert()
        }
        alertController.addAction(addAction)

        // 취소 버튼 추가
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        // iPad에서 액션 시트가 크래시되지 않도록 설정
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = categoryButton
            popoverController.sourceRect = categoryButton.bounds
        }

        present(alertController, animated: true, completion: nil)
    }

    private func presentAddCategoryAlert() {
        let alert = UIAlertController(title: "새 카테고리 추가", message: "추가할 카테고리 이름을 입력하세요.", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "카테고리 이름"
        }

        let addAction = UIAlertAction(title: "추가", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if let newCategory = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !newCategory.isEmpty {
                // 중복 체크
                if self.categories.contains(newCategory) {
                    self.presentDuplicateCategoryAlert()
                } else {
                    self.categories.append(newCategory)
                    self.updateCategoryButtonTitle(with: newCategory)
                }
            }
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)

        alert.addAction(addAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
    private func showImagePicker() {
        // 1) PHPicker 설정
        var configuration = PHPickerConfiguration()
        configuration.filter = .images   // 이미지만
        configuration.selectionLimit = 0 // 0이면 무제한, 혹은 10, 5 등 제한 가능

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.pickerViewController = picker

        // 2) 모달 표시
        present(picker, animated: true, completion: nil)
    }

    private func presentDuplicateCategoryAlert() {
        let alert = UIAlertController(title: "중복", message: "이미 존재하는 카테고리입니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func updateCategoryButtonTitle(with category: String) {
        categoryButton.setTitle("\(category) ▾", for: .normal)
    }

    // MARK: - UI Helpers
    private func makeRoundedTextField(_ placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.font = UIFont.systemFont(ofSize:14)
        tf.textColor = .darkGray
        tf.borderStyle = .none
        tf.layer.cornerRadius = 8
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.setLeftPaddingPoints(8)
        return tf
    }

    private func makeRoundedButton(_ title: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.darkGray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize:14)
        btn.layer.cornerRadius = 8
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.contentHorizontalAlignment = .left
        btn.contentEdgeInsets = UIEdgeInsets(top:7, left:8, bottom:7, right:8)
        return btn
    }

    private func makeIconButton(_ title: String, iconName: String) -> UIButton {
        let btn = makeRoundedButton(title)
        if let icon = UIImage(named: iconName) {
            btn.setImage(icon, for: .normal)
            btn.imageView?.contentMode = .scaleAspectFit
            btn.titleEdgeInsets = UIEdgeInsets(top:0, left:6, bottom:0, right:0)
        }
        return btn
    }

    private func makeSimpleLabel(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = UIFont.systemFont(ofSize:14)
        lbl.textColor = .darkGray
        return lbl
    }

    private func makePlainLabel(_ text: String) -> UILabel {
        // 작은 라벨(위도/경도/마커명/스니펫 등)
        let lbl = UILabel()
        lbl.text = text
        lbl.font = UIFont.systemFont(ofSize:14)
        lbl.textColor = .darkGray
        lbl.textAlignment = .right
        lbl.setContentHuggingPriority(.required, for: .horizontal)
        return lbl
    }

    private func makeRoundedTextView() -> UITextView {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize:14)
        tv.textColor = .darkGray
        tv.layer.cornerRadius = 8
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.textContainerInset = UIEdgeInsets(top:7, left:7, bottom:7, right:7)
        tv.isScrollEnabled = true
        return tv
    }
}

// MARK: - Padding
private extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat){
        let paddingView = UIView(frame: CGRect(x:0, y:0, width:amount, height: frame.size.height))
        leftView = paddingView
        leftViewMode = .always
    }
}
extension PopUpStoreRegisterViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageCell.identifier,
            for: indexPath
        ) as? ImageCell else {
            return UICollectionViewCell()
        }

        let item = images[indexPath.item]
        cell.configure(with: item)

        // 대표이미지 변경
        cell.onMainCheckToggled = { [weak self] in
            self?.toggleMainImage(index: indexPath.item)
        }
        // 개별 삭제
        cell.onDeleteTapped = { [weak self] in
            self?.deleteImage(index: indexPath.item)
        }

        return cell
    }
}

// 헬퍼 메서드들
private extension PopUpStoreRegisterViewController {
    /// 대표이미지를 단 하나만 허용 -> 누른 index만 isMain = true
    func toggleMainImage(index: Int) {
        for i in 0..<images.count {
            images[i].isMain = (i == index)
        }
        imagesCollectionView.reloadData()
    }

    /// 특정 index 이미지 삭제
    func deleteImage(index: Int) {
        images.remove(at: index)
        imagesCollectionView.reloadData()
        updateSaveButtonState()
    }
}
extension PopUpStoreRegisterViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard !results.isEmpty else { return }

        // nameField로부터 이름을 가져옴
        let name = self.nameField?.text ?? "unnamed"
        let uuid = UUID().uuidString

        var newImages = [ExtendedImage]()
        let itemProviders = results.map(\.itemProvider)
        let dispatchGroup = DispatchGroup()

        for (i, provider) in itemProviders.enumerated() {
            if provider.canLoadObject(ofClass: UIImage.self) {
                dispatchGroup.enter()
                provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                    defer { dispatchGroup.leave() }
                    guard let self = self,
                          let image = object as? UIImage else { return }

                    let filePath = "PopUpImage/\(name)/\(uuid)/\(i).jpg"
                    let extended = ExtendedImage(
                        filePath: filePath,
                        image: image,
                        isMain: false
                    )
                    newImages.append(extended)
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.images.append(contentsOf: newImages)
            if !self.images.isEmpty && !self.images.contains(where: { $0.isMain }) {
                self.images[0].isMain = true  // 첫 번째 이미지를 대표 이미지로
            }
            self.imagesCollectionView.reloadData()
            self.updateSaveButtonState()
        }
    }

}
private extension PopUpStoreRegisterViewController {
    private func validateForm() -> Bool {
        // (1) 팝업스토어 이름
        Logger.log(message: "nameField.text = \(nameField?.text ?? "nil")", category: .debug)
        guard let nameField = nameField, !(nameField.text ?? "").isEmpty else {
            Logger.log(
                message: "이름 필드가 비어 있습니다.",
                category: .debug,
                fileName: #file,
                line: #line
            )
            return false
        }

        // (2) 카테고리 선택
        if categoryButton.title(for: .normal) == "카테고리 선택 ▾" {
            Logger.log(
                message: "카테고리가 선택되지 않았습니다.",
                category: .debug,
                fileName: #file,
                line: #line
            )
            return false
        }

        // (3) 주소
        Logger.log(message: "addressField = \(addressField != nil ? "초기화됨" : "nil")", category: .debug)
        Logger.log(message: "addressField.text = \(addressField?.text ?? "nil")", category: .debug)
        guard let addressField = addressField, !(addressField.text ?? "").isEmpty else {
            Logger.log(message: "주소 필드가 비어 있습니다.", category: .debug)
            return false
        }


        // (4) 위도/경도
        Logger.log(message: "latField.text = \(latField?.text ?? "nil")", category: .debug)
        Logger.log(message: "lonField.text = \(lonField?.text ?? "nil")", category: .debug)
        guard let latField = latField,
              let lonField = lonField,
              let latText = latField.text, !latText.isEmpty,
              let lonText = lonField.text, !lonText.isEmpty,
              let latVal = Double(latText), let lonVal = Double(lonText),
              latVal != 0 || lonVal != 0 else {
            Logger.log(
                message: "위도/경도 값이 잘못되었습니다.",
                category: .debug,
                fileName: #file,
                line: #line
            )
            return false
        }

        // (5) 설명
        guard let descTV = descTV, !(descTV.text ?? "").isEmpty else {
            Logger.log(
                message: "설명 필드가 비어 있습니다.",
                category: .debug,
                fileName: #file,
                line: #line
            )
            return false
        }

        // (6) 이미지 ≥ 1장
        if images.isEmpty {
            Logger.log(
                message: "이미지가 추가되지 않았습니다.",
                category: .debug,
                fileName: #file,
                line: #line
            )
            return false
        }

        // (7) 대표 이미지 설정 여부
        if !images.contains(where: { $0.isMain }) {
            Logger.log(
                message: "대표 이미지가 설정되지 않았습니다.",
                category: .debug,
                fileName: #file,
                line: #line
            )
            return false
        }

        Logger.log(
            message: "모든 조건이 충족되었습니다.",
            category: .info,
            fileName: #file,
            line: #line
        )
        return true
    }
    private func doRegister() {
        Logger.log(message: "doRegister() 호출됨", category: .debug)

        // 1. 폼 데이터 검증
        guard validateFormData() else { return }

        if let editingStore = editingStore {
            // 수정 모드
            updateStore(editingStore)
        } else {
            // 새로 등록 모드
            // 2. 이미지 업로드 실행
            uploadImages()
        }
    }


    // 폼 데이터 검증
    private func validateFormData() -> Bool {
        guard let name = nameField?.text,
              let address = addressField?.text,
              let latitude = latField?.text, Double(latitude) != nil,
              let longitude = lonField?.text, Double(longitude) != nil,
              let description = descTV?.text,
              !images.isEmpty else {
            Logger.log(message: "폼 데이터 검증 실패", category: .error)
            return false
        }
        Logger.log(message: "폼 데이터 검증 성공", category: .debug)
        return true
    }
    private func updateStore(_ store: GetAdminPopUpStoreListResponseDTO.PopUpStore) {
        // 이미지가 수정되었다면 먼저 이미지 업로드
        if !images.isEmpty {
            uploadImagesForUpdate(store)
        } else {
            // 이미지 수정이 없다면 바로 스토어 정보 업데이트
            updateStoreInfo(store, updatedImagePaths: nil)
        }
    }
    private func uploadImagesForUpdate(_ store: GetAdminPopUpStoreListResponseDTO.PopUpStore) {
        let uuid = UUID().uuidString
        let updatedImages = images.enumerated().map { index, image in
            let filePath = "PopUpImage/\(nameField?.text ?? "")/\(uuid)/\(index).jpg"
            return ExtendedImage(
                filePath: filePath,
                image: image.image,
                isMain: image.isMain)
        }

        presignedService.tryUpload(datas: updatedImages.map {
            PreSignedService.PresignedURLRequest(filePath: $0.filePath, image: $0.image)
        })
        .subscribe(
            onSuccess: { [weak self] _ in
                guard let self = self else { return }
                Logger.log(message: "이미지 업로드 성공", category: .info)
                let imagePaths = updatedImages.map { $0.filePath }
                self.updateStoreInfo(store, updatedImagePaths: imagePaths)
            },
            onError: { [weak self] error in
                Logger.log(message: "이미지 업로드 실패: \(error.localizedDescription)", category: .error)
                self?.showErrorAlert(message: "이미지 업로드 실패: \(error.localizedDescription)")
            }
        )
        .disposed(by: disposeBag)
    }

    private func updateStoreInfo(_ store: GetAdminPopUpStoreListResponseDTO.PopUpStore, updatedImagePaths: [String]?) {
        guard let name = nameField?.text,
              let address = addressField?.text,
              let latitude = Double(latField?.text ?? ""),
              let longitude = Double(lonField?.text ?? ""),
              let description = descTV?.text,
              let categoryTitle = categoryButton.title(for: .normal)?.replacingOccurrences(of: " ▾", with: "") else {
            return
        }

        // 업데이트할 이미지가 있다면 첫 번째 값을 대표 이미지로, 없으면 기존 스토어의 mainImageUrl 사용
        let mainImage = updatedImagePaths?.first ?? store.mainImageUrl

        let request = UpdatePopUpStoreRequestDTO(
            popUpStore: .init(
                id: store.id,
                name: name,
                categoryId: Int64(getCategoryId(from: categoryTitle)),
                desc: description,
                address: address,
                startDate: getFormattedDate(from: selectedStartDate),
                endDate: getFormattedDate(from: selectedEndDate),
                mainImageUrl: mainImage,
                bannerYn: !mainImage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                imageUrl: updatedImagePaths ?? [store.mainImageUrl],
                startDateBeforeEndDate: true
            ),
            location: .init(
                latitude: latitude,
                longitude: longitude,
                markerTitle: "마커 제목",
                markerSnippet: "마커 설명"
            ),
            imagesToAdd: updatedImagePaths ?? [],
            imagesToDelete: []  // 필요한 경우 기존 이미지 삭제 로직 추가
            )



        adminUseCase.updateStore(request: request)
            .subscribe(
                onNext: { [weak self] _ in
                    Logger.log(message: "updateStore API 호출 성공", category: .info)
                    self?.showSuccessAlert(isUpdate: true)
                },
                onError: { [weak self] error in
                    Logger.log(message: "updateStore API 호출 실패: \(error.localizedDescription)", category: .error)
                    self?.showErrorAlert(message: error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }

    private func showSuccessAlert(isUpdate: Bool = false) {
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

    // 이미지 업로드
    private func uploadImages() {
        let uuid = UUID().uuidString
        //        let baseS3URL = Secrets.popPoolS3BaseURL.rawValue
        let updatedImages = images.enumerated().map { index, image in
            let filePath = "PopUpImage/\(nameField?.text ?? "")/\(uuid)/\(index).jpg"
            return ExtendedImage(
                filePath: filePath,
                image: image.image,
                isMain: image.isMain)
        }

        //        let presignedService = PreSignedService()
        presignedService.tryUpload(datas: updatedImages.map {
            PreSignedService.PresignedURLRequest(filePath: $0.filePath, image: $0.image)
        })
        //        .observe(on: MainScheduler.instance)
        .subscribe(
            onSuccess: { [weak self] _ in
                guard let self = self else { return }
                Logger.log(message: "이미지 업로드 성공", category: .info)

                let imagePaths = updatedImages.map { $0.filePath }
                let mainImage = updatedImages.first { $0.isMain }?.filePath ?? ""
                self.callCreateStoreAPI(mainImage: mainImage, imagePaths: imagePaths)  // baseURL 제거
            },
            onError: { error in
                Logger.log(message: "이미지 업로드 실패: \(error.localizedDescription)", category: .error)
                self.showErrorAlert(message: "이미지 업로드 실패: \(error.localizedDescription)")
            }
        )
        .disposed(by: disposeBag)
    }

    // createStore API 호출
    private func callCreateStoreAPI(mainImage: String, imagePaths: [String]) {
        guard let name = nameField?.text,
              let address = addressField?.text,
              let latitude = Double(latField?.text ?? ""),
              let longitude = Double(lonField?.text ?? ""),
              let description = descTV?.text,
              let categoryTitle = categoryButton.title(for: .normal)?.replacingOccurrences(of: " ▾", with: "") else {
            Logger.log(message: "필수 입력값이 비어 있음", category: .error)
            return
        }

        let categoryId = getCategoryId(from: categoryTitle)

        Logger.log(
            message: """
            팝업스토어 등록 요청:
            - 이름: \(name)
            - 카테고리: \(categoryTitle) (ID: \(categoryId))
            - 주소: \(address)
            - 위도/경도: (\(latitude), \(longitude))
            - 설명: \(description)
            - 시작일: \(getFormattedDate(from: selectedStartDate))
            - 종료일: \(getFormattedDate(from: selectedEndDate))
            - 메인이미지: \(mainImage)
            - 전체이미지: \(imagePaths)
            """,
            category: .network
        )

        let bannerYn = !mainImage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let dates = prepareDateTime()
        let isValidDateOrder = validateDates(start: selectedStartDate, end: selectedEndDate)

        let request = CreatePopUpStoreRequestDTO(
            name: name,
            categoryId: Int64(categoryId),
            desc: description,
            address: address,
            startDate: dates.startDate,
            endDate: dates.endDate,
            mainImageUrl: mainImage,
            imageUrlList: imagePaths,
            latitude: latitude,
            longitude: longitude,
            markerTitle: "마커 제목",
            markerSnippet: "마커 설명",
            startDateBeforeEndDate: isValidDateOrder
        )


        adminUseCase.createStore(request: request)
            .subscribe(
                onNext: { [weak self] _ in
                    Logger.log(message: "createStore API 호출 성공", category: .info)
                    self?.showSuccessAlert()
                },
                onError: { [weak self] error in
                    Logger.log(message: "createStore API 호출 실패: \(error.localizedDescription)", category: .error)
                    self?.showErrorAlert(message: error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }
    private func getCategoryId(from title: String) -> Int {
        Logger.log(message: "카테고리 매핑 시작 - 타이틀: \(title)", category: .debug)

        let categoryMap: [String: Int64] = [
            "패션": 1,
            "라이프스타일": 2,
            "뷰티": 3,
            "음식/요리": 4,
            "예술": 5,
            "반려동물": 6,
            "여행": 7,
            "엔터테인먼트": 8,
            "애니메이션": 9,
            "키즈": 10,
            "스포츠": 11,
            "게임": 12
        ]

        if let id = categoryMap[title] {
            Logger.log(message: "카테고리 매핑 성공: \(title) -> \(id)", category: .debug)
            return Int(id)
        } else {
            Logger.log(message: "카테고리 매핑 실패: \(title)에 해당하는 ID를 찾을 수 없음", category: .error)
            return 1 // 기본값
        }
    }


    private func createDateTime(date: Date?, time: Date?) -> Date? {
        guard let date = date else { return nil }

        if let time = time {
            let calendar = Calendar.current
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
            // 현지 시간을 명확하게 지정
            let newDate = calendar.date(bySettingHour: timeComponents.hour ?? 0,
                                        minute: timeComponents.minute ?? 0,
                                        second: 0,
                                        of: date)
            return newDate
        }

        return date
    }


    private func getFormattedDate(from date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        // 한국 시간대 명시 (GMT+9)
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.string(from: date)
    }
    private func prepareDateTime() -> (startDate: String, endDate: String) {
        let startDateTime = createDateTime(date: selectedStartDate, time: selectedStartTime)
        let endDateTime = createDateTime(date: selectedEndDate, time: selectedEndTime)

        return (
            startDate: getFormattedDate(from: startDateTime),
            endDate: getFormattedDate(from: endDateTime)
        )
    }

    // 새로운 검증 함수 추가 (prepareDateTime 함수 아래에 추가)
    private func validateDates(start: Date?, end: Date?) -> Bool {
        guard let start = start, let end = end else { return false }
        return start < end
    }





    private func showSuccessAlert() {
        let alert = UIAlertController(
            title: "등록 성공",
            message: "팝업스토어가 성공적으로 등록되었습니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
            // 성공 후 닫기와 핸들러 호출
            self?.completionHandler?()
            self?.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true)
    }
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "등록 실패",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
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
extension PopUpStoreRegisterViewController: UITextFieldDelegate {
    private func setupAddressField() {
        // RxCocoa를 사용한 텍스트 필드 바인딩
        addressField?.rx.text.orEmpty
            .distinctUntilChanged()
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .filter { !$0.isEmpty }
            .flatMapLatest { [weak self] address -> Observable<CLLocation?> in
                return Observable.create { observer in
                    let geocoder = CLGeocoder()
                    let fullAddress = "\(address), Korea"
                    
                    geocoder.geocodeAddressString(
                        fullAddress,
                        in: nil,
                        preferredLocale: Locale(identifier: "ko_KR")
                    ) { placemarks, error in
                        if let error = error {
                            print("Geocoding error: \(error.localizedDescription)")
                            observer.onNext(nil)
                            observer.onCompleted()
                            return
                        }
                        
                        if let location = placemarks?.first?.location {
                            observer.onNext(location)
                        } else {
                            observer.onNext(nil)
                        }
                        observer.onCompleted()
                    }
                    
                    return Disposables.create()
                }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] location in
                guard let location = location else { return }
                self?.latField?.text = String(format: "%.6f", location.coordinate.latitude)
                self?.lonField?.text = String(format: "%.6f", location.coordinate.longitude)
                self?.updateSaveButtonState()
            })
            .disposed(by: disposeBag)
    }
    
    
    @objc private func addressFieldDidChange(_ textField: UITextField) {
        guard let address = textField.text, !address.isEmpty else { return }
        
        // 한국 주소임을 명시
        let geocoder = CLGeocoder()
        let addressWithCountry = address + ", South Korea"
        
        geocoder.geocodeAddressString(addressWithCountry) { [weak self] placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            guard let location = placemarks?.first?.location else { return }
            
            DispatchQueue.main.async {
                self?.latField?.text = String(format: "%.6f", location.coordinate.latitude)
                self?.lonField?.text = String(format: "%.6f", location.coordinate.longitude)
                self?.updateSaveButtonState()
            }
        }
    }
    
}
