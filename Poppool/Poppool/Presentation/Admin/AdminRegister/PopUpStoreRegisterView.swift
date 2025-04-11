import UIKit

import SnapKit

final class PopUpRegisterView: UIView {
    // MARK: - Properties

    enum Constant {
        static let navigationHeight: CGFloat = 44
        static let logoWidth: CGFloat = 22
        static let logoHeight: CGFloat = 35
        static let edgeInset: CGFloat = 16
        static let buttonSize: CGFloat = 32
        static let cornerRadius: CGFloat = 8
        static let verticalSpacing: CGFloat = 8
        static let formLabelWidth: CGFloat = 80
    }

    // 네비게이션 영역
    let navigationContainer = UIView()

    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "image_login_logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let accountIdLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lbl.textColor = .black
        return lbl
    }()

    let menuButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "adminlist"), for: .normal)
        btn.tintColor = .black
        return btn
    }()

    // 타이틀 영역
    let titleContainer = UIView()

    let backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        btn.tintColor = .black
        return btn
    }()

    let pageTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "팝업스토어 등록"
        lbl.font = UIFont.boldSystemFont(ofSize: 18)
        lbl.textColor = .black
        return lbl
    }()

    // 스크롤 영역
    let scrollView = UIScrollView()
    let contentView = UIView()

    // 이미지 영역
    let addImageButton = UIButton(type: .system).then {
        $0.setTitle("이미지 추가", for: .normal)
        $0.setTitleColor(.systemBlue, for: .normal)
    }

    let removeAllButton = UIButton(type: .system).then {
        $0.setTitle("전체 삭제", for: .normal)
        $0.setTitleColor(.red, for: .normal)
    }

    let imagesCollectionView: PopUpImagesCollectionView = PopUpImagesCollectionView()

    // 폼 영역
    let formBackgroundView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.cornerRadius = 8
    }

    let verticalStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
    }

    // 폼 필드들
    let nameField = UITextField().then {
        $0.placeholder = "팝업스토어 이름을 입력해 주세요."
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .darkGray
        $0.borderStyle = .none
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.setLeftPaddingPoints(8)
    }

    let categoryButton: UIButton = {
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

    let addressField = UITextField().then {
        $0.placeholder = "팝업스토어 주소를 입력해 주세요."
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .darkGray
        $0.borderStyle = .none
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.setLeftPaddingPoints(8)
    }

    let latField = UITextField().then {
        $0.placeholder = ""
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .darkGray
        $0.borderStyle = .none
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.textAlignment = .center
        $0.setLeftPaddingPoints(8)
    }

    let lonField = UITextField().then {
        $0.placeholder = ""
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .darkGray
        $0.borderStyle = .none
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.textAlignment = .center
        $0.setLeftPaddingPoints(8)
    }

    let periodButton: UIButton = {
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

    let timeButton: UIButton = {
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

    let descriptionTextView = UITextView().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .darkGray
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.textContainerInset = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        $0.isScrollEnabled = true
    }

    // 저장 버튼
    let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("저장", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .lightGray
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn.layer.cornerRadius = 8
        btn.isEnabled = false
        return btn
    }()

    // MARK: - init
    init() {
        super.init(frame: .zero)

        self.addViews()
        self.setupContstraints()
        self.configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("\(#file), \(#function) Error")
    }
}

// MARK: - SetUp
private extension PopUpRegisterView {
    func addViews() {
        // 네비게이션 영역
        self.addSubview(self.navigationContainer)
        self.navigationContainer.addSubview(self.logoImageView)
        self.navigationContainer.addSubview(self.accountIdLabel)
        self.navigationContainer.addSubview(self.menuButton)

        // 타이틀 영역
        self.addSubview(self.titleContainer)
        self.titleContainer.addSubview(self.backButton)
        self.titleContainer.addSubview(self.pageTitleLabel)

        // 스크롤 영역
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.contentView)

        // 이미지 영역
        let buttonStack = UIStackView(arrangedSubviews: [self.addImageButton, self.removeAllButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 16

        self.contentView.addSubview(buttonStack)
        self.contentView.addSubview(self.imagesCollectionView)

        // 폼 영역
        self.contentView.addSubview(self.formBackgroundView)
        self.formBackgroundView.addSubview(self.verticalStack)

        // 저장 버튼
        self.addSubview(self.saveButton)
    }

    func setupContstraints() {
        // 네비게이션 영역
        self.navigationContainer.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(Constant.navigationHeight)
        }

        self.logoImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.equalTo(Constant.logoWidth)
            make.height.equalTo(Constant.logoHeight)
        }

        self.accountIdLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(self.logoImageView.snp.right).offset(8)
        }

        self.menuButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(Constant.edgeInset)
            make.width.height.equalTo(Constant.buttonSize)
        }

        // 타이틀 영역
        self.titleContainer.snp.makeConstraints { make in
            make.top.equalTo(self.navigationContainer.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(Constant.navigationHeight)
        }

        self.backButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(8)
            make.width.height.equalTo(32)
        }

        self.pageTitleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(self.backButton.snp.right).offset(4)
        }

        // 스크롤 영역
        self.scrollView.snp.makeConstraints { make in
            make.top.equalTo(self.titleContainer.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-74)
        }

        self.contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(self.scrollView.snp.width)
        }

        // 이미지 영역
        let buttonStack = self.contentView.subviews.first as! UIStackView
        buttonStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }

        self.imagesCollectionView.snp.makeConstraints { make in
            make.top.equalTo(buttonStack.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(130)
        }

        // 폼 영역
        self.formBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(self.imagesCollectionView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }

        self.verticalStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 저장 버튼
        self.saveButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(44)
        }
    }

    func configureUI() {
        self.backgroundColor = UIColor(white: 0.95, alpha: 1)

        // 폼 요소 추가
        self.setupFormRows()
    }

    func setupFormRows() {
        // 이름 필드 추가
        self.addFormRow(leftTitle: "이름", rightView: self.nameField)

        // 카테고리 버튼 추가
        self.addFormRow(leftTitle: "카테고리", rightView: self.categoryButton)

        // 위치 필드 추가 (주소, 위도, 경도)
        let latLabel = self.makePlainLabel("위도")
        let lonLabel = self.makePlainLabel("경도")

        let latStack = UIStackView(arrangedSubviews: [latLabel, self.latField])
        latStack.axis = .horizontal
        latStack.spacing = 8
        latStack.distribution = .fillProportionally

        let lonStack = UIStackView(arrangedSubviews: [lonLabel, self.lonField])
        lonStack.axis = .horizontal
        lonStack.spacing = 8
        lonStack.distribution = .fillProportionally

        let latLonRow = UIStackView(arrangedSubviews: [latStack, lonStack])
        latLonRow.axis = .horizontal
        latLonRow.spacing = 16
        latLonRow.distribution = .fillEqually

        let locationVStack = UIStackView(arrangedSubviews: [self.addressField, latLonRow])
        locationVStack.axis = .vertical
        locationVStack.spacing = 8
        locationVStack.distribution = .fillEqually

        self.addFormRow(leftTitle: "위치", rightView: locationVStack, rowHeight: nil, totalHeight: 80)

        // 마커 필드 추가
        let markerLabel = self.makePlainLabel("마커명")
        let markerField = self.makeRoundedTextField("")
        let markerStackH = UIStackView(arrangedSubviews: [markerLabel, markerField])
        markerStackH.axis = .horizontal
        markerStackH.spacing = 8
        markerStackH.distribution = .fillProportionally

        let snippetLabel = self.makePlainLabel("스니펫")
        let snippetField = self.makeRoundedTextField("")
        let snippetStackH = UIStackView(arrangedSubviews: [snippetLabel, snippetField])
        snippetStackH.axis = .horizontal
        snippetStackH.spacing = 8
        snippetStackH.distribution = .fillProportionally

        let markerVStack = UIStackView(arrangedSubviews: [markerStackH, snippetStackH])
        markerVStack.axis = .vertical
        markerVStack.spacing = 8
        markerVStack.distribution = .fillEqually

        self.addFormRow(leftTitle: "마커", rightView: markerVStack, rowHeight: nil, totalHeight: 80)

        // 기간 및 시간
        self.addFormRow(leftTitle: "기간", rightView: self.periodButton)
        self.addFormRow(leftTitle: "시간", rightView: self.timeButton)

        // 작성자 및 작성시간
        let currentTime = self.getCurrentFormattedTime()
        let writerLbl = self.makeSimpleLabel("")
        let timeLbl = self.makeSimpleLabel(currentTime)

        self.addFormRow(leftTitle: "작성자", rightView: writerLbl)
        self.addFormRow(leftTitle: "작성시간", rightView: timeLbl)

        // 상태값
        let statusLbl = self.makeSimpleLabel("진행")
        self.addFormRow(leftTitle: "상태값", rightView: statusLbl)

        // 설명
        self.addFormRow(leftTitle: "설명", rightView: self.descriptionTextView, rowHeight: nil, totalHeight: 120)
    }

    // 폼 행 추가 헬퍼 메서드
    func addFormRow(leftTitle: String, rightView: UIView, rowHeight: CGFloat? = 36, totalHeight: CGFloat? = nil) {
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

        self.verticalStack.addArrangedSubview(row)
    }

    // 유틸리티 메서드
    func makeRoundedTextField(_ placeholder: String) -> UITextField {
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

    func makePlainLabel(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = .darkGray
        lbl.textAlignment = .right
        lbl.setContentHuggingPriority(.required, for: .horizontal)
        return lbl
    }

    func makeSimpleLabel(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = .darkGray
        return lbl
    }

    func getCurrentFormattedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.string(from: Date())
    }
}
extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.size.height))
        leftView = paddingView
        leftViewMode = .always
    }
}
