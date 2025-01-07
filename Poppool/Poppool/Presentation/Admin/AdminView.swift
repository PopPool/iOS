import UIKit
import SnapKit
import Then

final class AdminView: UIView {

    // MARK: - Components
    let navigationView = UIView()
    let logoImageView = UIImageView().then {
        $0.image = UIImage(named: "image_login_logo")
        $0.contentMode = .scaleAspectFit
    }

    let separatorView = UIView().then {
        $0.backgroundColor = UIColor.g50
    }

    let usernameLabel = PPLabel(
        style: .bold,
        fontSize: 14,
        text: "김채연님"
    )

    let menuButton = UIButton(type: .system).then {
        $0.setImage(UIImage(named: "adminlist"), for: .normal)
        $0.tintColor = .black
    }

    let titleLabel = PPLabel(
        style: .bold,
        fontSize: 20,
        text: "팝업스토어 관리"
    )

    let searchInput = UITextField().then {
        $0.placeholder = "팝업스토어명을 입력해보세요"
        $0.borderStyle = .none
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .g400
        $0.backgroundColor = UIColor.g50
        $0.layer.cornerRadius = 8
        $0.leftView = {
            let imageView = UIImageView(image: UIImage(named: "icon_search_gray"))
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 20))
            paddingView.addSubview(imageView)
            imageView.center = paddingView.center
            return paddingView
        }()
        $0.leftViewMode = .always
        $0.clearButtonMode = .whileEditing
    }

    let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("등록", for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.backgroundColor = .white
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
        return button
    }()

    let filterContainer = UIView()
    let dropdownButton = UIButton(type: .system).then {
        $0.setTitle("전체", for: .normal)
        $0.setTitleColor(.g900, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        let dropdownIcon = UIImageView(image: UIImage(named: "icon_dropdown"))
        dropdownIcon.contentMode = .scaleAspectFit
        $0.addSubview(dropdownIcon)
        dropdownIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(8)
            make.width.height.equalTo(22)
        }
    }

    let popupCountLabel = UILabel().then {
        $0.text = "총 52건"
        $0.textColor = .lightGray
        $0.font = UIFont.systemFont(ofSize: 14)
    }

    let tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        [navigationView, separatorView, titleLabel, searchInput, registerButton, filterContainer, tableView].forEach {
            addSubview($0)
        }

        [logoImageView, usernameLabel, menuButton].forEach {
            navigationView.addSubview($0)
        }

        [dropdownButton, popupCountLabel].forEach {
            filterContainer.addSubview($0)
        }

        navigationView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }

        separatorView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(22)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(3)
        }

        logoImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(28)
            make.centerY.equalToSuperview()
            make.width.equalTo(22)
            make.height.equalTo(28)
        }

        usernameLabel.snp.makeConstraints { make in
            make.leading.equalTo(logoImageView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }

        menuButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(16)
        }

        registerButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(16)
            make.width.equalTo(65)
            make.height.equalTo(37)
        }

        searchInput.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(37)
        }

        filterContainer.snp.makeConstraints { make in
            make.top.equalTo(searchInput.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(32)
        }

        dropdownButton.snp.makeConstraints { make in
//            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(searchInput)
            make.width.equalTo(80)
            make.height.equalTo(32)
        }

        popupCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(dropdownButton)
            make.leading.equalTo(searchInput)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(filterContainer.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
extension AdminView {
    func updateFilterOption(_ option: String) {
        dropdownButton.setTitle(option, for: .normal)
    }
}
