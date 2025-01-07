import UIKit
import SnapKit

final class PopUpStoreRegisterViewController: UIViewController {

    // MARK: - Navigation/Header
    private let navContainer = UIView()

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "image_login_logo")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let accountIdLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "김채연님"
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

    // (3) 메인 이미지
    private let mainImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        return iv
    }()

    // MARK: - Scroll
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: - Form Background
    private let formBackgroundView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        // 시안상 사각형 테두리
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

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white:0.95, alpha:1)

        setupNavigation()
        setupLayout()
        setupRows()
    }

    // MARK: - Navigation
    private func setupNavigation() {
        backButton.addTarget(self, action: #selector(onBack), for: .touchUpInside)
    }

    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
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

        // (3) Scroll
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

        // 메인 이미지
        contentView.addSubview(mainImageView)
        mainImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }

        // (4) form BG
        contentView.addSubview(formBackgroundView)
        formBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(mainImageView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()

        }
        formBackgroundView.addSubview(verticalStack)
        verticalStack.axis = .vertical
        verticalStack.spacing = 0
        verticalStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // (5) 저장 버튼
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.top.equalTo(scrollView.snp.bottom).offset(15)
            make.height.equalTo(44)
        }
    }

    // MARK: - Setup Rows
    private func setupRows() {
        // 예시: 이름, 이미지, 카테고리...
        addRowTextField(leftTitle: "이름", placeholder: "팝업스토어 이름을 입력해 주세요.")
        addRowTextField(leftTitle: "이미지", placeholder: "팝업스토어 대표 이미지를 업로드 해주세요.")
        let catBtn = makeRoundedButton("카테고리 선택 ▾")
        addRowCustom(leftTitle: "카테고리", rightView: catBtn)

        // (위치) => 2줄
        // 1) 주소 (TextField)
        let addressField = makeRoundedTextField("팝업스토어 주소를 입력해 주세요.")
        addressField.snp.makeConstraints { make in
        }

        // 2) (위도 Label + TF) + (경도 Label + TF)
        let latLabel = makePlainLabel("위도")
        let latField = makeRoundedTextField("")
        latField.textAlignment = .center
        let lonLabel = makePlainLabel("경도")
        let lonField = makeRoundedTextField("")
        lonField.textAlignment = .center

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
        let periodBtn = makeIconButton("", iconName: "date")
        periodBtn.addTarget(self, action: #selector(didTapPeriodButton), for: .touchUpInside)

        addRowCustom(leftTitle: "기간", rightView: periodBtn)

        // (11) 시간
        let timeBtn = makeIconButton("", iconName: "due")
        timeBtn.addTarget(self, action: #selector(didTapTimeButton), for: .touchUpInside)
        addRowCustom(leftTitle: "시간", rightView: timeBtn)


        // (12) 작성자
        let writerLbl = makeSimpleLabel("김채연")
        addRowCustom(leftTitle: "작성자", rightView: writerLbl)

        // (13) 작성시간
        let timeLbl = makeSimpleLabel("2025.01.06 10:30")
        addRowCustom(leftTitle: "작성시간", rightView: timeLbl)

        // (14) 상태값
        let statusLbl = makeSimpleLabel("진행")
        addRowCustom(leftTitle: "상태값", rightView: statusLbl)

        // (15) 설명
        let descTV = makeRoundedTextView()
        addRowCustom(leftTitle: "설명", rightView: descTV, rowHeight: nil, totalHeight: 120)
    }


    // MARK: - Row
    private func addRowTextField(leftTitle: String, placeholder: String) {
        let tf = makeRoundedTextField(placeholder)
        addRowCustom(leftTitle: leftTitle, rightView: tf)
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
        DateTimePickerManager.shared.showDateRange(on: self) { start, end in
            // 여기서 ViewController는 날짜 2개만 받고, UI 업데이트
            self.selectedStartDate = start
            self.selectedEndDate = end
            self.updatePeriodButtonTitle()
        }
    }

    @objc private func didTapTimeButton() {
        DateTimePickerManager.shared.showTimeRange(on: self) { st, et in
            self.selectedStartTime = st
            self.selectedEndTime = et
            self.updateTimeButtonTitle()
        }
    }

    private func updatePeriodButtonTitle() {
        guard let s = selectedStartDate, let e = selectedEndDate else { return }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let sStr = df.string(from: s)
        let eStr = df.string(from: e)

        // verticalStack 안에서 "기간" 라벨 있는 row 찾아서, or 그냥 recall the same button if you stored it:
        // For simplicity, let's re-scan or keep a reference
        if let periodBtn = findButtonByIconName("date") {
            periodBtn.setTitle("\(sStr) ~ \(eStr)", for: .normal)
        }
    }

    private func updateTimeButtonTitle() {
        guard let st = selectedStartTime, let et = selectedEndTime else { return }
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        let stStr = df.string(from: st)
        let etStr = df.string(from: et)
        if let timeBtn = findButtonByIconName("due") {
            timeBtn.setTitle("\(stStr) ~ \(etStr)", for: .normal)
        }
    }

    // MARK: - helper to find icon button
    private func findButtonByIconName(_ iconName: String) -> UIButton? {
        for rowView in verticalStack.arrangedSubviews {
            for sub in rowView.subviews {
                for sub2 in sub.subviews {
                    if let btn = sub2 as? UIButton,
                       let image = btn.image(for: .normal),
                       image == UIImage(named: iconName) {
                        return btn
                    }
                }
            }
        }
        return nil
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
        tv.isScrollEnabled = false
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
