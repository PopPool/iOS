//
//  SignUpVC.swift
//  PopPool
//
//  Created by SeoJunYoung on 6/23/24.
//

import Foundation
import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class SignUpVC: UIViewController {
    
    // MARK: - Components
    private let headerView = HeaderViewCPNT(title: "asdfasdf", style: .text("취소"))
    private let progressIndicator = ProgressIndicatorCPNT(totalStep: 4, startPoint: 1)
    
    // MARK: - ContentTitleViews
    private let step1_contentTitleView = ContentTitleCPNT(
        title: "서비스 이용을 위한\n약관을 확인해주세요",
        type: .title_fp
    )
    private let step2_contentTitleView = ContentTitleCPNT(
        title: "팝풀에서 사용할\n별명을 설정해볼까요?",
        type: .title_sub_fp(subTitle: "이 단계를 건너뛰시면 자동으로 별명이 만들어져요.")
    )
    private let step3_contentTitleView = ContentTitleCPNT(
        title: "$유저명$님에 대해\n조금 더 알려주시겠어요?",
        type: .title_fp
    )
    private let step4_contentTitleView = ContentTitleCPNT(
        title: "$유저명$님에 대해\n조금 더 알려주시겠어요?",
        type: .title_fp
    )
    private lazy var contentTitleViews: [ContentTitleCPNT] = [
        step1_contentTitleView,
        step2_contentTitleView,
        step3_contentTitleView,
        step4_contentTitleView
    ]
    private let contentTitleStackView: UIStackView = UIStackView()
    
    // MARK: - ContentViews
    private let step1_ContentView = SignUpStep1View()
    private let step2_ContentView = SignUpStep2View()
    private let step3_ContentView = SignUpStep3View()
    private let step4_ContentView = SignUpStep4View()
    private lazy var contentViews = [
        step1_ContentView,
        step2_ContentView,
        step3_ContentView,
        step4_ContentView
    ]
    private let contentStackView: UIStackView = UIStackView()
    
    // MARK: - Buttons
    private let step1_primaryButton: ButtonCPNT = {
        let button = ButtonCPNT(type: .primary, title: "확인", disabledTitle: "확인")
        button.isEnabled = false
        return button
    }()
    private let step2_primaryButton: ButtonCPNT = {
        let button = ButtonCPNT(type: .primary, title: "확인", disabledTitle: "다음")
        button.isEnabled = false
        return button
    }()
    private let step2_secondaryButton = ButtonCPNT(type: .secondary, title: "건너뛰기")
    private lazy var step2_buttons: UIStackView = {
        let view = UIStackView(arrangedSubviews: [self.step2_secondaryButton, self.step2_primaryButton])
        view.spacing = 10
        view.distribution = .fillEqually
        return view
    }()
    private let step3_primaryButton: ButtonCPNT = {
        let button = ButtonCPNT(type: .primary, title: "다음", disabledTitle: "다음")
        button.isEnabled = false
        return button
    }()
    private let step3_secondaryButton = ButtonCPNT(type: .secondary, title: "건너뛰기")
    private lazy var step3_buttons: UIStackView = {
        let view = UIStackView(arrangedSubviews: [self.step3_secondaryButton, self.step3_primaryButton])
        view.spacing = 10
        view.distribution = .fillEqually
        return view
    }()
    private let step4_primaryButton = ButtonCPNT(type: .primary, title: "확인", disabledTitle: "확인")
    private let step4_secondaryButton = ButtonCPNT(type: .secondary, title: "건너뛰기")
    private lazy var step4_buttons: UIStackView = {
        let view = UIStackView(arrangedSubviews: [self.step4_secondaryButton, self.step4_primaryButton])
        view.spacing = 10
        view.distribution = .fillEqually
        return view
    }()
    private lazy var bottomButtons = [
        step1_primaryButton,
        step2_buttons,
        step3_buttons,
        step4_buttons
        
    ]
    private let buttonStackView: UIStackView = UIStackView()
    
    // MARK: - Properties
    private let viewModel = SignUpVM()
    private let disposeBag = DisposeBag()
    
    deinit {
        print(self, #function)
    }
}

// MARK: - Life Cycle
extension SignUpVC {
    override func viewDidLoad() {
        setUp()
        setUpConstraints()
        bind()
    }
}
// MARK: - SetUp
private extension SignUpVC {
    func setUp() {
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .systemBackground
        headerView.leftBarButton.isHidden = true
        headerView.titleLabel.isHidden = true
    }
    /// UI 요소의 레이아웃 제약 설정
    func setUpConstraints() {
        contentTitleStackView.addArrangedSubview(contentTitleViews[0])
        contentStackView.addArrangedSubview(contentViews[0])
        buttonStackView.addArrangedSubview(bottomButtons[0])
        view.addSubview(headerView)
        view.addSubview(progressIndicator)
        view.addSubview(contentTitleStackView)
        view.addSubview(contentStackView)
        view.addSubview(buttonStackView)
        
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(Constants.spaceGuide._16px)
            make.leading.trailing.equalToSuperview()
        }
        progressIndicator.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(Constants.spaceGuide._16px)
            make.leading.trailing.equalToSuperview().inset(Constants.spaceGuide._20px)
        }
        contentTitleStackView.snp.makeConstraints { make in
            make.top.equalTo(progressIndicator.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(Constants.spaceGuide._20px)
        }
        buttonStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Constants.spaceGuide._20px)
            make.height.equalTo(52)
            make.bottom.equalToSuperview().inset(Constants.spaceGuide._48px)
        }
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(contentTitleStackView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(Constants.spaceGuide._20px)
            make.bottom.equalTo(buttonStackView.snp.top)
        }
    }
    
    /// ViewModel과의 바인딩을 설정
    func bind() {
        step2_ContentView.validationTextField.duplicationCheckButton.rx.tap
            .withUnretained(self)
            .subscribe { (owner, _) in
                owner.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        
        let input = SignUpVM.Input(
            tap_header_cancelButton: headerView.rightBarButton.rx.tap,
            tap_header_backButton: headerView.leftBarButton.rx.tap,
            tap_step1_primaryButton: step1_primaryButton.rx.tap,
            event_step1_didChangeTerms: step1_ContentView.terms,
            tap_step2_primaryButton: step2_primaryButton.rx.tap,
            tap_step2_secondaryButton: step2_secondaryButton.rx.tap,
            tap_step2_nickNameCheckButton: step2_ContentView.validationTextField.duplicationCheckButton.rx.tap,
            event_step2_availableNickName: step2_ContentView.validationTextField.nickNameObserver,
            tap_step3_primaryButton: step3_primaryButton.rx.tap,
            tap_step3_secondaryButton: step3_secondaryButton.rx.tap,
            event_step3_didChangeInterestList: step3_ContentView.fetchSelectedList(),
            event_step4_didSelectedGender: step4_ContentView.genderSegmentedControl.rx.selectedSegmentIndex,
            tap_step4_ageButton: step4_ContentView.ageButton.rx.tap,
            tap_step4_secondaryButton: step4_secondaryButton.rx.tap
        )
        let output = viewModel.transform(input: input)
        
        // 페이지 인덱스 증가 이벤트 처리
        output.increasePageIndex
            .withUnretained(self)
            .subscribe { (owner, pageIndex) in
                owner.progressIndicator.increaseIndicator()
                owner.reloadView(pageIndex: pageIndex, isIncrease: true)
            }
            .disposed(by: disposeBag)
        
        // 페이지 인덱스 감소 이벤트 처리
        output.decreasePageIndex
            .withUnretained(self)
            .subscribe { (owner, pageIndex) in
                owner.progressIndicator.decreaseIndicator()
                owner.reloadView(pageIndex: pageIndex, isIncrease: false)
            }
            .disposed(by: disposeBag)
        
        // Step 1 primary button 활성/비활성 상태 처리
        output.step1_primaryButton_isEnabled
            .withUnretained(self)
            .subscribe { (owner, isEnabled) in
                owner.changeButtonState(button: owner.step1_primaryButton, isEnabled: isEnabled)
            }
            .disposed(by: disposeBag)
        
        // Step 2 중복확인 button 결과 전달
        output.step2_isDuplicate
            .withUnretained(self)
            .debounce(.microseconds(200), scheduler: MainScheduler.instance)
            .subscribe { (owner, isDuplicate) in
                owner.step2_ContentView.validationTextField.validationState.accept(isDuplicate ? .duplicateNickname : .available)
            }
            .disposed(by: disposeBag)
        
        // Step 2 primary button 활성/비활성 상태 처리
        output.step2_primaryButton_isEnabled
            .withUnretained(self)
            .subscribe { (owner, isEnabled) in
                owner.changeButtonState(button: owner.step2_primaryButton, isEnabled: isEnabled)
            }
            .disposed(by: disposeBag)
        
        // Step 3 primary button 활성/비활성 상태 처리
        output.step3_primaryButton_isEnabled
            .withUnretained(self)
            .subscribe { (owner, isEnabled) in
                owner.changeButtonState(button: owner.step3_primaryButton, isEnabled: isEnabled)
            }
            .disposed(by: disposeBag)
        
        // 카테고리 리스트 가져오기
        output.fetchCategoryList
            .withUnretained(self)
            .subscribe { (owner, list) in
                owner.step3_ContentView.setCategoryList(list: list)
            }
            .disposed(by: disposeBag)
        
        // Step3,4 nickname 설정
        output.fetchUserNickname
            .withUnretained(self)
            .subscribe { (owner, nickname) in
                owner.step3_contentTitleView.setNickName(nickName: nickname)
                owner.step4_contentTitleView.setNickName(nickName: nickname)
            }
            .disposed(by: disposeBag)
        
        output.moveToRecentVC
            .withUnretained(self)
            .subscribe { (owner, _) in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    /// 페이지 인덱스에 따라 뷰 변경을 처리하는 메서드
    ///
    /// - Parameters:
    ///   - pageIndex: 현재 페이지 인덱스
    ///   - previousIndex: 이전 페이지 인덱스
    func reloadView(pageIndex: Int, isIncrease: Bool) {
        view.endEditing(true)
        let previousIndex = isIncrease ? pageIndex - 1 : pageIndex + 1
        
        UIView.transition(with: contentTitleStackView, duration: 0.2, options: .transitionCrossDissolve) {
            self.headerView.leftBarButton.isHidden = pageIndex == 0 ? true : false
        }
        if pageIndex < contentTitleViews.count {
            UIView.transition(with: contentTitleStackView, duration: 0.2, options: .transitionCrossDissolve) {
                self.contentTitleViews[previousIndex].removeFromSuperview()
                self.contentTitleStackView.addArrangedSubview(self.contentTitleViews[pageIndex])
            }
        }
        if pageIndex < contentViews.count {
            UIView.transition(with: contentStackView, duration: 0.2, options: .transitionCrossDissolve) {
                self.contentViews[previousIndex].removeFromSuperview()
                self.contentStackView.addArrangedSubview(self.contentViews[pageIndex])
            }
        }
        if pageIndex < bottomButtons.count {
            UIView.transition(with: buttonStackView, duration: 0.2, options: .transitionCrossDissolve) {
                self.bottomButtons[previousIndex].removeFromSuperview()
                self.buttonStackView.addArrangedSubview(self.bottomButtons[pageIndex])
            }
        }
    }
    
    /// 버튼의 활성/비활성 상태를 변경하는 메서드
    ///
    /// - Parameters:
    ///   - button: 대상 버튼
    ///   - isEnabled: 활성화 여부
    func changeButtonState(button: UIButton, isEnabled: Bool) {
        if button.isEnabled != isEnabled {
            UIView.transition(with: button, duration: 0.2, options: .transitionCrossDissolve) {
                button.isEnabled = isEnabled
            }
        }
    }
}
