//
//  SignOutSurveryView.swift
//  PopPool
//
//  Created by Porori on 7/18/24.
//

import UIKit
import SnapKit
import RxSwift

// MARK: - SurveyList

struct SurveyList {
    var title: String
}

class SignOutSurveyView: UIStackView {
    
    // MARK: - Components
    
    private let title: ContentTitleCPNT
    private let topSpaceView = UIView()
    private let buttonTopView = UIView()
    private let bottomSpaceView = UIView()
    
    lazy var surveyView = self.survey.map { return TermsViewCPNT(title: $0.title) }
    private let surveyStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        return stack
    }()
    
    private let surveyTextView: DynamicTextViewCPNT
    private let textViewContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    let skipButton: ButtonCPNT
    let confirmButton: ButtonCPNT
    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(skipButton)
        stack.addArrangedSubview(confirmButton)
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - Properties
    
    let disposeBag = DisposeBag()
    let tappedValues: PublishSubject<[Int]> = .init()
    
    private let survey: [SurveyList] = [
        SurveyList(title: "원하는 팝업에 대한 정보가 없어요"),
        SurveyList(title: "팝업 정보가 적어요"),
        SurveyList(title: "이용빈도가 낮아요"),
        SurveyList(title: "다시 가입하고 싶어요"),
        SurveyList(title: "앱에 오류가 많이 생겨요"),
        SurveyList(title: "기타")
    ]
    
    init() {
        self.title = ContentTitleCPNT(title: "탈퇴하려는 이유가\n무엇인가요?",
                                      type: .title_sub_fp(
                                        subTitle: "알려주시는 내용을 참고해 더 나은 팝풀을\n만들어볼게요."))
        self.confirmButton = ButtonCPNT(type: .primary, title: "확인")
        self.skipButton = ButtonCPNT(type: .secondary, title: "건너뛰기")
        self.surveyTextView = DynamicTextViewCPNT(placeholder: "탈퇴 이유를 입력해주세요", textLimit: 500)
        super.init(frame: .zero)
        setUp()
        setUpLayout()
        bind()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        Observable.from(surveyView)
            .withUnretained(self)
            .enumerated()
            .subscribe { (owner, index) in
                print("어떤 값?:", index)
            }
            .disposed(by: disposeBag)
    }
    
    func makeTextViewActive(_ isChecked: Bool) {
        self.surveyTextView.isHidden = !isChecked
        isChecked ? self.surveyTextView.activate() : self.surveyTextView.deactivate()
    }
    
    private func setButtonsAsHidden(_ view: TermsViewCPNT) {
        view.iconImageView.isHidden = true
    }
    
    private func setUp() {
        self.axis = .vertical
        self.title.subTitleLabel.numberOfLines = 0
        self.title.subTitleLabel.lineBreakMode = .byTruncatingTail
        self.title.subTitleLabel.adjustsFontSizeToFitWidth = true
    }
    
    private func setUpLayout() {
        self.addArrangedSubview(title)
        self.addArrangedSubview(topSpaceView)
        self.addArrangedSubview(surveyStack)
        self.addArrangedSubview(textViewContainer)
        self.addArrangedSubview(buttonTopView)
        self.addArrangedSubview(buttonStack)
        self.addArrangedSubview(bottomSpaceView)
        
        title.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        topSpaceView.snp.makeConstraints { make in
            make.height.equalTo(Constants.spaceGuide.medium400)
        }
        
        surveyView.forEach { list in
            surveyStack.addArrangedSubview(list)
            self.setButtonsAsHidden(list)
            list.snp.makeConstraints { make in
                make.height.equalTo(49)
            }
        }
        
        surveyStack.snp.makeConstraints { make in
            make.top.equalTo(topSpaceView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        textViewContainer.addSubview(surveyTextView)
        textViewContainer.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(80)
        }
        
        surveyTextView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(26)
            make.top.bottom.trailing.equalToSuperview()
        }
        
        buttonTopView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualToSuperview().priority(.low)
        }
        
        buttonStack.snp.makeConstraints { make in
            make.height.equalTo(52)
        }
        
        bottomSpaceView.snp.makeConstraints { make in
            make.height.equalTo(Constants.spaceGuide.medium400)
        }
    }
}
