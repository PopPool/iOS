import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class PopUpStoreRegisterView: UIView {
    // 상단 네비게이션 영역
    let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "image_login_logo")
        iv.contentMode = .scaleAspectFit
        return iv
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

    // 입력 폼 영역
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "팝업스토어 이름을 입력해 주세요."
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        return tf
    }()

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

    let addressTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "팝업스토어 주소를 입력해 주세요."
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        return tf
    }()

    let latTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "위도"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textAlignment = .center
        tf.borderStyle = .roundedRect
        return tf
    }()

    let lonTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "경도"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textAlignment = .center
        tf.borderStyle = .roundedRect
        return tf
    }()

    let descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.layer.cornerRadius = 8
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.textContainerInset = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        return tv
    }()

    // 이미지 관련 영역
    let addImageButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("이미지 추가", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        return btn
    }()

    let removeAllButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("전체 삭제", for: .normal)
        btn.setTitleColor(.red, for: .normal)
        return btn
    }()

    lazy var imagesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 120)
        layout.minimumLineSpacing = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        // 셀 등록 등은 실제 프로젝트에 맞게 설정합니다.
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")
        return cv
    }()

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

    // 기타 UI 요소는 필요에 따라 추가하세요.

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.95, alpha: 1)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout Setup
    private func setupLayout() {
        // 예시로 상단 네비게이션과 입력폼 일부만 배치합니다.
        let navContainer = UIView()
        addSubview(navContainer)
        navContainer.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
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

        // 타이틀 영역
        let titleContainer = UIView()
        addSubview(titleContainer)
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

        // 입력폼 영역 (예시)
        let formStack = UIStackView(arrangedSubviews: [nameTextField, categoryButton, addressTextField])
        formStack.axis = .vertical
        formStack.spacing = 16
        addSubview(formStack)
        formStack.snp.makeConstraints { make in
            make.top.equalTo(titleContainer.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
        }

        // 위/경도는 수평 스택
        let latLonStack = UIStackView(arrangedSubviews: [latTextField, lonTextField])
        latLonStack.axis = .horizontal
        latLonStack.spacing = 16
        latLonStack.distribution = .fillEqually
        addSubview(latLonStack)
        latLonStack.snp.makeConstraints { make in
            make.top.equalTo(formStack.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
        }

        // 설명 텍스트뷰
        addSubview(descriptionTextView)
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(latLonStack.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(120)
        }

        // 이미지 영역 (Add/Remove 버튼과 CollectionView)
        let imageButtonStack = UIStackView(arrangedSubviews: [addImageButton, removeAllButton])
        imageButtonStack.axis = .horizontal
        imageButtonStack.distribution = .fillEqually
        imageButtonStack.spacing = 16
        addSubview(imageButtonStack)
        imageButtonStack.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }

        addSubview(imagesCollectionView)
        imagesCollectionView.snp.makeConstraints { make in
            make.top.equalTo(imageButtonStack.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(130)
        }

        // 저장 버튼
        addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.height.equalTo(44)
        }
    }
}
