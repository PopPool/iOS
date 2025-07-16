import UIKit

import DesignSystem

import SnapKit
import Then

final class LoginView: UIView {

    // MARK: - Components
    let guestButton = UIButton(type: .system).then {
        $0.setTitle("둘러보기", for: .normal)
        $0.titleLabel?.font = .korFont(style: .regular, size: 14)
        $0.setTitleColor(.g1000, for: .normal)
    }

    private let logoImageView = UIImageView().then {
        $0.image = UIImage(named: "image_login_logo")
        $0.contentMode = .scaleAspectFit
    }

    private let titleLabel = PPLabel(
        style: .bold,
        fontSize: 16,
        text: "간편하게 SNS 로그인하고\n팝풀 서비스를 이용해보세요"
    ).then {
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }

    let kakaoButton = PPButton(style: .kakao, text: "카카오톡으로 로그인")

    private let kakaoImageView = UIImageView().then {
        $0.image = UIImage(named: "icon_login_kakao")
    }

    let appleButton = PPButton(style: .apple, text: "Apple로 로그인")

    private let appleImageView = UIImageView().then {
        $0.image = UIImage(named: "icon_login_apple")
    }

    let inquiryButton = UIButton(type: .system).then {
        $0.setTitle("로그인이 어려우신가요?", for: .normal)
        $0.titleLabel?.font = .korFont(style: .regular, size: 12)
        $0.setTitleColor(.g1000, for: .normal)
    }

    // MARK: - init
    init() {
        super.init(frame: .zero)

        self.addViews()
        self.setupConstraints()
        self.configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("\(#file), \(#function) Error")
    }
}

// MARK: - SetUp
private extension LoginView {

    func addViews() {
        [guestButton, logoImageView, titleLabel, kakaoButton, appleButton, inquiryButton].forEach {
            self.addSubview($0)
        }

        [kakaoImageView].forEach {
            kakaoButton.addSubview($0)
        }

        [appleImageView].forEach {
            appleButton.addSubview($0)
        }
    }

    func setupConstraints() {
        guestButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(11)
            make.trailing.equalToSuperview().inset(20)
        }

        logoImageView.snp.makeConstraints { make in
            make.height.equalTo(90)
            make.width.equalTo(70)
            make.top.equalTo(guestButton.snp.bottom).offset(75)
            make.centerX.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoImageView.snp.bottom).offset(28)
        }

        kakaoButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(156)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        kakaoImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
            make.size.equalTo(22)
        }

        appleButton.snp.makeConstraints { make in
            make.top.equalTo(kakaoButton.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        appleImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
            make.size.equalTo(22)
        }

        inquiryButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(56)
            make.centerX.equalToSuperview()
        }
    }

    func configureUI() { }
}
