//
//  !_!_!_.swift
//  PopPool
//
//  Created by SeoJunYoung on 6/20/24.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class LoginVC: UIViewController {
    
// MARK: - Properties
    let headerView = HeaderViewCPNT(title: "둘러보기", style: .text("둘러보기"))
    
    let logoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        return stack
    }()
    
    let logoImageView: UIImageView = {
        let logoView = UIImageView()
        logoView.image = .lightLogo
        logoView.contentMode = .scaleAspectFit
        return logoView
    }()
    
    let notificationLabel: UILabel = {
        let label = UILabel()
        let text = "간편하게 SNS 로그인하고\n팝풀 서비스를 이용해보세요"
        label.numberOfLines = 0
        label.font = .KorFont(style: .bold, size: 16)
        let attributedStr = NSMutableAttributedString(string: text)
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.4
        label.attributedText = NSMutableAttributedString(
            string: text,
            attributes: [.paragraphStyle: style]
        )
        label.textAlignment = .center
        return label
    }()
    
    let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fillEqually
        return stack
    }()
    
    let inquiryButton: UIButton = {
        let button = UIButton()
        button.setTitle("로그인이 어려우신가요?", for: .normal)
        button.setTitleColor(.g1000, for: .normal)
        button.titleLabel?.font = .KorFont(style: .regular, size: 12)
        return button
    }()
    
    let kakaoSignInButton: ButtonCPNT = ButtonCPNT(type: .kakao, title: "카카오톡으로 로그인")
    let appleSignInButton: ButtonCPNT = ButtonCPNT(type: .apple, title: "Apple로 로그인")
    lazy var spacer28 = SpacingFactory.shared.createSpace(on: self.view, size: 28)
    lazy var spacer64 = SpacingFactory.shared.createSpace(on: self.view, size: 64)
    lazy var spacer156 = SpacingFactory.shared.createSpace(on: self.view, size: 156)
    lazy var belowTip = CMPTToolTipView(frame: .zero, direction: .notifyBelow)
    lazy var aboveTip = CMPTToolTipView(frame: .zero, direction: .notifyAbove)
    
    private let viewModel = LoginVM()
    private let disposeBag = DisposeBag()
}


// MARK: - Life Cycle
extension LoginVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        bind()
    }
}


// MARK: - Setup
extension LoginVC {
    private func setupLayout() {
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .systemBackground
        headerView.leftBarButton.isHidden = true
        headerView.titleLabel.isHidden = true
        
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(logoStackView)
        logoStackView.addArrangedSubview(spacer64)
        logoStackView.addArrangedSubview(logoImageView)
        logoStackView.addArrangedSubview(spacer28)
        logoStackView.addArrangedSubview(notificationLabel)
        logoStackView.addArrangedSubview(spacer156)
        
        logoStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(64)
            make.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(kakaoSignInButton)
        buttonStackView.addArrangedSubview(appleSignInButton)
        
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(logoStackView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(116)
        }
        
        view.addSubview(inquiryButton)
        inquiryButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(88)
            make.centerX.equalToSuperview()
        }
        setToolTip()
    }
    
    private func setToolTip() {
        
        if true {
            view.addSubview(belowTip)
            belowTip.snp.makeConstraints { make in
                make.bottom.equalTo(kakaoSignInButton.snp.top).inset(-8)
                make.centerX.equalToSuperview()
            }
        } else {
            view.addSubview(aboveTip)
            aboveTip.snp.makeConstraints { make in
                make.top.equalTo(appleSignInButton.snp.bottom).inset(8)
                make.centerX.equalToSuperview()
            }
        }
    }
    
    func bind() {
        let input = LoginVM.Input(
            tourButtonTapped: headerView.rightBarButton.rx.tap,
            kakaoLoginButtonTapped: kakaoSignInButton.rx.tap,
            appleLoginButtonTapped: appleSignInButton.rx.tap,
            inquryButtonTapped: inquiryButton.rx.tap
        )
        let output = viewModel.transform(input: input)
        
        output.showLoginBottomSheet
            .subscribe(onNext: { [weak self] _ in
                print("버튼이 눌렸습니다")
                let vc = AgeSelectionBottomSheet()
                self?.presentViewControllerModally(vc: vc)
            })
            .disposed(by: disposeBag)
        
        output.moveToInquryPage
            .subscribe(onNext: { [weak self] _ in
                // 메인 화면으로 이동
            })
            .disposed(by: disposeBag)
        
        output.moveToSignUpPage
            .withUnretained(self)
            .subscribe { (owner, _) in
                let vc = SignUpVC()
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
}
