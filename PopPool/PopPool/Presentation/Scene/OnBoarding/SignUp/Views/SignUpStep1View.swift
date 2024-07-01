//
//  SignUpStep1View.swift
//  PopPool
//
//  Created by SeoJunYoung on 6/25/24.
//

import Foundation
import UIKit
import RxSwift
import SnapKit

final class SignUpStep1View: UIStackView {
    
    // MARK: - Components
    private let topSpacingView = UIView()
    private let middleSpacingView = UIView()
    private let checkBox = CheckBoxCPNT(title: "약관에 모두 동의할게요")
    private let term1View = TermsViewCPNT(title: "[필수] 이용약관")
    private let term2View = TermsViewCPNT(title: "[필수] 개인정보 수집 및 이용")
    private let term3View = TermsViewCPNT(title: "[필수] 만 14세 이상")
    private let term4View = TermsViewCPNT(title: "[선택] 광고성 정보 수신")
    private let termsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 16
        return view
    }()
    private let bottomSpacingView = UIView()
    
    struct TermsFormat {
        var title: String
        var content: String
    }
    
    private let termList: [TermsFormat] = [
        .init(
            title: "[필수] 이용약관",
            content: """
            하위의 텍스트는 모두 로렘 입숨입니다.
            
            모든 국민은 학문과 예술의 자유를 가진다. 모든 국민은 언론·출판의 자유와 집회·결사의 자유를 가진다. 헌법재판소는 법률에 저촉되지 아니하는 범위안에서 심판에 관한 절차, 내부규율과 사무처리에 관한 규칙을 제정할 수 있다. 국가는 농지에 관하여 경자유전의 원칙이 달성될 수 있도록 노력하여야 하며, 농지의 소작제도는 금지된다.
            
            국교는 인정되지 아니하며, 종교와 정치는 분리된다. 훈장등의 영전은 이를 받은 자에게만 효력이 있고, 어떠한 특권도 이에 따르지 아니한다. 모든 국민은 보건에 관하여 국가의 보호를 받는다. 모든 국민은 주거의 자유를 침해받지 아니한다. 주거에 대한 압수나 수색을 할 때에는 검사의 신청에 의하여 법관이 발부한 영장을 제시하여야 한다.
            
            국회의 정기회는 법률이 정하는 바에 의하여 매년 1회 집회되며, 국회의 임시회는 대통령 또는 국회재적의원 4분의 1 이상의 요구에 의하여 집회된다. 근로조건의 기준은 인간의 존엄성을 보장하도록 법률로 정한다. 국회의원의 선거구와 비례대표제 기타 선거에 관한 사항은 법률로 정한다. 대통령은 국민의 보통·평등·직접·비밀선거에 의하여 선출한다.
            
            제1항의 지시를 받은 당해 행정기관은 이에 응하여야 한다. 국무총리 또는 행정각부의 장은 소관사무에 관하여 법률이나 대통령령의 위임 또는 직권으로 총리령 또는 부령을 발할 수 있다. 제2항의 재판관중 3인은 국회에서 선출하는 자를, 3인은 대법원장이 지명하는 자를 임명한다. 국민경제의 발전을 위한 중요정책의 수립에 관하여 대통령의 자문에 응하기 위하여 국민경제자문회의를 둘 수 있다.
            """
        ),
        .init(
            title: "실험실험",
            content: "testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttest"
        ),
        .init(
            title: "title3",
            content: "testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttest"
        ),
        .init(
            title: "title4",
            content: "testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttest"
        )
    ]
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    /// 약관 동의 상태를 전달하는 PublishSubject
    var terms: PublishSubject<[Bool]> = .init()
    
    init() {
        super.init(frame: .zero)
        setUp()
        setUpConstraints()
        bind()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SetUp
private extension SignUpStep1View {
    
    /// 뷰 설정
    func setUp() {
        self.axis = .vertical
    }
    
    /// 제약 조건 설정
    func setUpConstraints() {
        topSpacingView.snp.makeConstraints { make in
            make.height.equalTo(Constants.spaceGuide._48px)
        }
        middleSpacingView.snp.makeConstraints { make in
            make.height.equalTo(Constants.spaceGuide._36px)
        }
        termsStackView.addArrangedSubview(term1View)
        termsStackView.addArrangedSubview(term2View)
        termsStackView.addArrangedSubview(term3View)
        termsStackView.addArrangedSubview(term4View)
        self.addArrangedSubview(topSpacingView)
        self.addArrangedSubview(checkBox)
        self.addArrangedSubview(middleSpacingView)
        self.addArrangedSubview(termsStackView)
        self.addArrangedSubview(bottomSpacingView)
    }
    
    /// 바인딩 설정
    func bind() {
        let termViews = [term1View, term2View, term3View, term4View]
        
        // 체크박스 탭 이벤트 처리
        checkBox.rx.tap
            .withUnretained(self)
            .subscribe { (owner, _) in
                let isCheck = owner.checkBox.isCheck.value
                termViews.forEach { term in
                    term.isCheck.accept(isCheck)
                }
            }
            .disposed(by: disposeBag)
        
        // 각 약관 동의 상태 변경 시 처리
        Observable.combineLatest(termViews.map{$0.isCheck})
            .withUnretained(self)
            .subscribe(onNext: { owner, isChecks in
                owner.terms.onNext(isChecks)
                let isAllCheck = isChecks.allSatisfy { $0 }
                owner.checkBox.isCheck.accept(isAllCheck)
            })
            .disposed(by: disposeBag)
        
        for (index, view) in termViews.enumerated() {
            view.termsButton.rx.tap
                .withUnretained(self)
                .subscribe { (owner, _) in
                    print(owner.termList[index])
                    // present를 할 때 돌려서 활용할 수 있어보임
                }
                .disposed(by: disposeBag)
        }
    }
}
