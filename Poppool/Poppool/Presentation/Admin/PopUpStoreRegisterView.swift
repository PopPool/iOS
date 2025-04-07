////
////  PopUpStoreRegisterView.swift
////  Poppool
////
////  Created by 김기현 on 1/14/25.
////
//
// import UIKit
// import SnapKit
// import Then
//
// final class PopUpStoreRegisterView: UIView {
//
//    // MARK: - Callbacks (Closure)
//    /// "이미지 추가" 버튼 탭
//    var onAddImageTapped: (() -> Void)?
//    /// "전체삭제" 버튼 탭
//    var onRemoveAllTapped: (() -> Void)?
//    /// 대표이미지 체크 토글 (콜렉션셀에서 index 전달)
//    var onToggleMainImage: ((Int) -> Void)?
//    /// 개별 이미지 삭제(index)
//    var onDeleteImage: ((Int) -> Void)?
//
//    /// "카테고리 선택" 버튼 탭
//    var onCategoryButtonTapped: (() -> Void)?
//    /// "기간 선택" 버튼 탭
//    var onPeriodButtonTapped: (() -> Void)?
//    /// "시간 선택" 버튼 탭
//    var onTimeButtonTapped: (() -> Void)?
//    /// "저장" 버튼 탭
//    var onSaveTapped: (() -> Void)?
//
//    // MARK: - Subviews
//    // (1) 상단 "이름" 입력 필드
//    private let nameTextField = UITextField().then {
//        $0.placeholder = "팝업스토어 이름을 입력해 주세요."
//        $0.font = .systemFont(ofSize: 14)
//        $0.textColor = .darkGray
//        $0.borderStyle = .roundedRect
//    }
//
//    // (2) 이미지 버튼들
//    private let addImageButton = UIButton(type: .system).then {
//        $0.setTitle("이미지 추가", for: .normal)
//        $0.setTitleColor(.systemBlue, for: .normal)
//    }
//    private let removeAllButton = UIButton(type: .system).then {
//        $0.setTitle("전체 삭제", for: .normal)
//        $0.setTitleColor(.red, for: .normal)
//    }
//
//    // (3) 이미지 콜렉션뷰
//    private let imagesCollectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.itemSize = CGSize(width: 80, height: 100)
//        layout.minimumLineSpacing = 8
//
//        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        cv.backgroundColor = .clear
//        cv.register(PopUpImageCell.self, forCellWithReuseIdentifier: PopUpImageCell.identifier)
//        return cv
//    }()
//
//    // (4) 카테고리/기간/시간 버튼
//    private let categoryButton = UIButton(type: .system).then {
//        $0.setTitle("카테고리 선택 ▾", for: .normal)
//        $0.setTitleColor(.darkGray, for: .normal)
//        $0.titleLabel?.font = .systemFont(ofSize:14)
//        $0.layer.cornerRadius = 8
//        $0.layer.borderWidth = 1
//        $0.layer.borderColor = UIColor.lightGray.cgColor
//        $0.contentHorizontalAlignment = .left
//        $0.contentEdgeInsets = UIEdgeInsets(top:7, left:8, bottom:7, right:8)
//    }
//    private let periodButton = UIButton(type: .system).then {
//        $0.setTitle("기간 선택 ▾", for: .normal)
//        $0.setTitleColor(.darkGray, for: .normal)
//        $0.titleLabel?.font = UIFont.systemFont(ofSize:14)
//        $0.layer.cornerRadius = 8
//        $0.layer.borderWidth = 1
//        $0.layer.borderColor = UIColor.lightGray.cgColor
//        $0.contentHorizontalAlignment = .left
//        $0.contentEdgeInsets = UIEdgeInsets(top:7, left:8, bottom:7, right:8)
//    }
//    private let timeButton = UIButton(type: .system).then {
//        $0.setTitle("시간 선택 ▾", for: .normal)
//        $0.setTitleColor(.darkGray, for: .normal)
//        $0.titleLabel?.font = UIFont.systemFont(ofSize:14)
//        $0.layer.cornerRadius = 8
//        $0.layer.borderWidth = 1
//        $0.layer.borderColor = UIColor.lightGray.cgColor
//        $0.contentHorizontalAlignment = .left
//        $0.contentEdgeInsets = UIEdgeInsets(top:7, left:8, bottom:7, right:8)
//    }
//
//    // (5) "저장" 버튼
//    private let saveButton = UIButton(type: .system).then {
//        $0.setTitle("저장", for: .normal)
//        $0.setTitleColor(.white, for: .normal)
//        $0.backgroundColor = .lightGray
//        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
//        $0.layer.cornerRadius = 8
//        $0.isEnabled = false
//    }
//
//    // (6) 스크롤/스택
//    private let scrollView = UIScrollView()
//    private let contentView = UIView()
//    private let verticalStack = UIStackView().then {
//        $0.axis = .vertical
//        $0.spacing = 8
//        $0.distribution = .fill
//    }
//
//    // MARK: - Internal Data
//    /// 외부(뷰컨)에서 주입할 "이미지 목록"
//    private var images: [ExtendedImage] = []
//
//    // MARK: - Public computed properties
//    /// 입력한 이름 get/set
//    var storeName: String {
//        get { nameTextField.text ?? "" }
//        set { nameTextField.text = newValue }
//    }
//
//    /// 현재 카테고리 버튼 타이틀
//    var categoryText: String {
//        get { categoryButton.title(for: .normal) ?? "" }
//        set { categoryButton.setTitle(newValue, for: .normal) }
//    }
//
//    // MARK: - Init
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupLayout()
//        setupActions()
//        setupCollectionView()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // MARK: - Setup
//    private func setupLayout() {
//        backgroundColor = UIColor(white:0.95, alpha:1)
//
//        // 1) 스크롤+컨텐츠
//        addSubview(scrollView)
//        scrollView.snp.makeConstraints { make in
//            make.top.left.right.equalToSuperview()
//            make.bottom.equalToSuperview().offset(-64) // 아래 "저장"버튼을 띄우기 위해 예시
//        }
//        scrollView.addSubview(contentView)
//        contentView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//            make.width.equalTo(scrollView.snp.width)
//        }
//
//        // 2) 수직스택
//        contentView.addSubview(verticalStack)
//        verticalStack.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(16)
//            make.left.right.equalToSuperview().inset(16)
//            make.bottom.equalToSuperview()
//        }
//
//        // (A) 이름 필드
//        let nameRow = makeRow(title: "이름", rightView: nameTextField)
//        verticalStack.addArrangedSubview(nameRow)
//
//        // (B) 이미지 버튼 (add/remove)
//        let buttonStack = UIStackView(arrangedSubviews: [addImageButton, removeAllButton])
//        buttonStack.axis = .horizontal
//        buttonStack.distribution = .fillEqually
//        buttonStack.spacing = 8
//        verticalStack.addArrangedSubview(buttonStack)
//        buttonStack.snp.makeConstraints { make in
//            make.height.equalTo(40)
//        }
//
//        // (C) 콜렉션뷰
//        verticalStack.addArrangedSubview(imagesCollectionView)
//        imagesCollectionView.snp.makeConstraints { make in
//            make.height.equalTo(100)
//        }
//
//        // (D) 카테고리 버튼
//        let catRow = makeRow(title: "카테고리", rightView: categoryButton)
//        verticalStack.addArrangedSubview(catRow)
//
//        // (E) 기간 버튼
//        let periodRow = makeRow(title: "기간", rightView: periodButton)
//        verticalStack.addArrangedSubview(periodRow)
//
//        // (F) 시간 버튼
//        let timeRow = makeRow(title: "시간", rightView: timeButton)
//        verticalStack.addArrangedSubview(timeRow)
//
//        // (여기에 위치/마커/설명 등 다른 항목도 같은 방식으로)
//
//        // 3) 저장 버튼 (화면 하단 고정)
//        addSubview(saveButton)
//        saveButton.snp.makeConstraints { make in
//            make.left.right.equalToSuperview().inset(16)
//            make.bottom.equalTo(safeAreaLayoutGuide).offset(-8)
//            make.height.equalTo(44)
//        }
//    }
//
//    private func setupActions() {
//        // (1) 이미지추가 -> onAddImageTapped
//        addImageButton.addTarget(self, action: #selector(tapAddImage), for: .touchUpInside)
//        // (2) 전체삭제 -> onRemoveAllTapped
//        removeAllButton.addTarget(self, action: #selector(tapRemoveAll), for: .touchUpInside)
//        // (3) 카테고리 -> onCategoryButtonTapped
//        categoryButton.addTarget(self, action: #selector(tapCategory), for: .touchUpInside)
//        // (4) 기간 -> onPeriodButtonTapped
//        periodButton.addTarget(self, action: #selector(tapPeriod), for: .touchUpInside)
//        // (5) 시간 -> onTimeButtonTapped
//        timeButton.addTarget(self, action: #selector(tapTime), for: .touchUpInside)
//        // (6) 저장 -> onSaveTapped
//        saveButton.addTarget(self, action: #selector(tapSave), for: .touchUpInside)
//    }
//
//    private func setupCollectionView() {
//        imagesCollectionView.dataSource = self
//        imagesCollectionView.delegate = self
//    }
//
//    // MARK: - Public Methods
//    /// 외부에서 "이미지 목록"을 세팅할 때 사용
//    func updateImages(_ newImages: [ExtendedImage]) {
//        self.images = newImages
//        imagesCollectionView.reloadData()
//        updateSaveButtonState()
//    }
//
//    /// 저장버튼 활성화 업데이트
//    private func updateSaveButtonState() {
//        // 예: 이미지가 1장 이상 있을 때만 활성화
//        let hasImages = !images.isEmpty
//        saveButton.isEnabled = hasImages
//        saveButton.backgroundColor = hasImages ? .systemBlue : .lightGray
//    }
//
//    // MARK: - Actions
//    @objc private func tapAddImage() {
//        onAddImageTapped?()
//    }
//    @objc private func tapRemoveAll() {
//        onRemoveAllTapped?()
//    }
//    @objc private func tapCategory() {
//        onCategoryButtonTapped?()
//    }
//    @objc private func tapPeriod() {
//        onPeriodButtonTapped?()
//    }
//    @objc private func tapTime() {
//        onTimeButtonTapped?()
//    }
//    @objc private func tapSave() {
//        onSaveTapped?()
//    }
//
//    // MARK: - Helpers
//    private func makeRow(title: String, rightView: UIView) -> UIView {
//        let row = UIView()
//
//        // 왼쪽 BG
//        let leftBG = UIView()
//        leftBG.backgroundColor = UIColor(white:0.94, alpha:1)
//        row.addSubview(leftBG)
//        leftBG.snp.makeConstraints { make in
//            make.top.left.bottom.equalToSuperview()
//            make.width.equalTo(80)
//        }
//
//        // 왼쪽 라벨
//        let label = UILabel()
//        label.text = title
//        label.font = .systemFont(ofSize:15, weight:.bold)
//        label.textColor = .black
//        label.textAlignment = .center
//        leftBG.addSubview(label)
//        label.snp.makeConstraints { make in
//            make.centerY.equalToSuperview()
//            make.left.right.equalToSuperview().inset(8)
//        }
//
//        // 오른쪽 BG
//        let rightBG = UIView()
//        rightBG.backgroundColor = .white
//        row.addSubview(rightBG)
//        rightBG.snp.makeConstraints { make in
//            make.top.bottom.right.equalToSuperview()
//            make.left.equalTo(leftBG.snp.right)
//        }
//
//        // 오른쪽 컨텐츠 (파라미터)
//        rightBG.addSubview(rightView)
//        rightView.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(8)
//            make.bottom.equalToSuperview().offset(-8)
//            make.left.equalToSuperview().offset(8)
//            make.right.equalToSuperview().offset(-8)
//            make.height.equalTo(36).priority(.medium)
//        }
//
//        // 구분선
//        let sep = UIView()
//        sep.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
//        row.addSubview(sep)
//        sep.snp.makeConstraints { make in
//            make.left.right.bottom.equalToSuperview()
//            make.height.equalTo(1)
//        }
//
//        return row
//    }
// }
//
//// MARK: - UICollectionViewDataSource
// extension PopUpStoreRegisterView: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return images.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(
//            withReuseIdentifier: PopUpImageCell.identifier,
//            for: indexPath
//        ) as? PopUpImageCell else {
//            return UICollectionViewCell()
//        }
//        let item = images[indexPath.item]
//        cell.configure(with: item)
//
//        cell.onMainCheckToggled = { [weak self] in
//            self?.onToggleMainImage?(indexPath.item)
//        }
//        cell.onDeleteTapped = { [weak self] in
//            self?.onDeleteImage?(indexPath.item)
//        }
//        return cell
//    }
// }
//
//// MARK: - UICollectionViewDelegateFlowLayout
// extension PopUpStoreRegisterView: UICollectionViewDelegateFlowLayout {
//    // 혹시 셀 사이즈/간격을 동적으로 조정하고 싶다면 여기서
// }
//
//// MARK: - PopUpImageCell (같은 파일)
// final class PopUpImageCell: UICollectionViewCell {
//    static let identifier = "PopUpImageCell"
//
//    // 콜백
//    var onMainCheckToggled: (() -> Void)?
//    var onDeleteTapped: (() -> Void)?
//
//    private let thumbImageView = UIImageView().then {
//        $0.contentMode = .scaleAspectFill
//        $0.layer.cornerRadius = 6
//        $0.clipsToBounds = true
//    }
//    private let mainCheckButton = UIButton(type: .system).then {
//        $0.setTitle("대표", for: .normal)
//        $0.setTitleColor(.white, for: .normal)
//        $0.backgroundColor = .gray
//        $0.titleLabel?.font = .systemFont(ofSize:12, weight:.medium)
//        $0.layer.cornerRadius = 4
//    }
//    private let deleteButton = UIButton(type: .system).then {
//        $0.setTitle("삭제", for: .normal)
//        $0.setTitleColor(.red, for: .normal)
//        $0.titleLabel?.font = .systemFont(ofSize:12, weight:.medium)
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        contentView.addSubview(thumbImageView)
//        contentView.addSubview(mainCheckButton)
//        contentView.addSubview(deleteButton)
//
//        thumbImageView.snp.makeConstraints { make in
//            make.top.left.right.equalToSuperview()
//            make.height.equalTo(thumbImageView.snp.width)
//        }
//        mainCheckButton.snp.makeConstraints { make in
//            make.top.equalTo(thumbImageView.snp.bottom).offset(4)
//            make.left.equalToSuperview()
//            make.width.equalTo(40)
//            make.height.equalTo(24)
//        }
//        deleteButton.snp.makeConstraints { make in
//            make.top.equalTo(thumbImageView.snp.bottom).offset(4)
//            make.right.equalToSuperview()
//            make.width.equalTo(40)
//            make.height.equalTo(24)
//        }
//
//        mainCheckButton.addTarget(self, action: #selector(didTapMainCheck), for: .touchUpInside)
//        deleteButton.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
//    }
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    @objc private func didTapMainCheck() {
//        onMainCheckToggled?()
//    }
//    @objc private func didTapDelete() {
//        onDeleteTapped?()
//    }
//
//    func configure(with item: ExtendedImage) {
//        thumbImageView.image = item.image
//        mainCheckButton.backgroundColor = item.isMain ? .systemRed : .gray
//    }
// }
