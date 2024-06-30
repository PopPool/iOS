//
//  SignUpVM.swift
//  PopPool
//
//  Created by SeoJunYoung on 6/25/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SignUpVM: ViewModelable {

    /// 입력 이벤트
    struct Input {
        /// header cancelButton 탭 이벤트
        var tap_header_cancelButton: ControlEvent<Void>
        /// header backButton 탭 이벤트
        var tap_header_backButton: ControlEvent<Void>
        /// Sign Up Step1 primary button  탭 이벤트
        var tap_step1_primaryButton: ControlEvent<Void>
        /// 약관 동의 변경을 전달하는 Subject
        var event_step1_didChangeTerms: PublishSubject<[Bool]>
        /// Sign Up Step2 primary button  탭 이벤트
        var tap_step2_primaryButton: ControlEvent<Void>
        /// Sign Up Step2 secondary button  탭 이벤트
        var tap_step2_secondaryButton: ControlEvent<Void>
        /// Sign Up Step2 중복확인 button  탭 이벤트
        var tap_step2_nickNameCheckButton: ControlEvent<Void>
        /// Sign Up Step2 유효한 닉네임 전달 이벤트
        var event_step2_availableNickName: PublishSubject<String?>
        /// Sign Up Step3 primary button  탭 이벤트
        var tap_step3_primaryButton: ControlEvent<Void>
        /// Sign Up Step3 secondary button  탭 이벤트
        var tap_step3_secondaryButton: ControlEvent<Void>
        /// 관심사 변경을 전달하는 Subject
        var event_step3_didChangeInterestList: Observable<[String]>
        /// step 4 gender segmentedControl 이벤트
        var event_step4_didSelectedGender: ControlProperty<Int>
        /// step 4 나이 설정 버튼 탭 이벤트
        var tap_step4_ageButton: ControlEvent<Void>
        /// Sign Up Step4 secondary button  탭 이벤트
        var tap_step4_secondaryButton: ControlEvent<Void>
        
//        var event_age_selection: ControlEvent<Void>
//        
//        var tap_age_confirm_selection: ControlEvent<Void>
//        
//        var tap_age_cancel_selection: ControlEvent<Void>
    }
    
    /// 출력 이벤트
    struct Output {
        /// 페이지 인덱스 증가 이벤트를 방출하는 Subject
        var increasePageIndex: PublishSubject<Int>
        /// 페이지 인덱스 감소 이벤트를 방출하는 Subject
        var decreasePageIndex: PublishSubject<Int>
        /// Step 1의 primary button 활성/비활성 상태를 방출하는 Subject
        var step1_primaryButton_isEnabled: PublishSubject<Bool>
        /// nickName 중복 여부 상태를 방출하는 Subject
        var step2_isDuplicate: PublishSubject<Bool>
        /// Step 2의 primary button 활성/비활성 상태를 방출하는 Subject
        var step2_primaryButton_isEnabled: PublishSubject<Bool>
        /// 카테고리 리스트를 가져오는 Subject
        var fetchCategoryList: PublishSubject<[String]>
        /// Step 3의 primary button 활성/비활성 상태를 방출하는 Subject
        var step3_primaryButton_isEnabled: PublishSubject<Bool>
        /// 유효한 닉네임 전달 이벤트
        var fetchUserNickname: PublishSubject<String>
        /// 이전 화면으로 이동
        var moveToRecentVC: ControlEvent<Void>
    }
    
    var disposeBag: DisposeBag = DisposeBag()
    
    /// 현재 페이지 인덱스를 관리하는 BehaviorRelay
    private var pageIndex: BehaviorRelay<Int> = .init(value: 0)
    /// 현재 페이지 인덱스의 증,감소를 관리하는 PublishSubject
    private let pageIndexIncreaseObserver: PublishSubject<Int> = .init()
    private let pageIndexDecreaseObserver: PublishSubject<Int> = .init()
    
    private let userNickName: PublishSubject<String> = .init()
    
    /// 입력을 출력으로 변환하는 메서드
    ///
    /// - Parameter input: 입력 구조체
    /// - Returns: 출력 구조체
    func transform(input: Input) -> Output {
        let step1_primaryButton_isEnabled: PublishSubject<Bool> = .init()
        
        let step2_isDuplicate: PublishSubject<Bool> = .init()
        let step2_primaryButton_isEnabled: PublishSubject<Bool> = .init()
        
        let step3_primaryButton_isEnabled: PublishSubject<Bool> = .init()
        let fetchCategoryList: PublishSubject<[String]> = .init()

        // tap_header_cancelButton 이벤트 처리
        input.tap_header_cancelButton
            .withUnretained(self)
            .subscribe { (owner, _) in
                print("tap_header_cancelButton")
            }
            .disposed(by: disposeBag)
        
        // tap_header_backButton 이벤트 처리
        input.tap_header_backButton
            .withUnretained(self)
            .subscribe { (owner, _) in
                owner.decreasePageIndex()
            }
            .disposed(by: disposeBag)
        
        // 약관 동의 변경 이벤트 처리
        input.event_step1_didChangeTerms.asObserver()
            .subscribe(onNext: { isCheck in
                if isCheck[0] && isCheck[1] && isCheck[2] {
                    step1_primaryButton_isEnabled.onNext(true)
                } else {
                    step1_primaryButton_isEnabled.onNext(false)
                }
            })
            .disposed(by: disposeBag)
        
        // Step 1 primary button 탭 이벤트
        input.tap_step1_primaryButton
            .withUnretained(self)
            .subscribe { (owner, _) in
                owner.increasePageIndex()
            }
            .disposed(by: disposeBag)

        // Step 2 primary button 탭 이벤트 처리
        input.tap_step2_primaryButton
            .withUnretained(self)
            .subscribe { (owner, _) in
                owner.increasePageIndex()
                // 네트워크 사용으로 수정 필요
                fetchCategoryList.onNext([
                    "패션",
                    "라이프스타일",
                    "뷰티",
                    "음식/요리",
                    "예술",
                    "반려동물",
                    "여행",
                    "엔터테인먼트",
                    "애니메이션",
                    "키즈",
                    "스포츠",
                    "게임",
                ])
            }
            .disposed(by: disposeBag)
        
        // Step 2 secondary button 탭 이벤트 처리
        input.tap_step2_secondaryButton
            .withUnretained(self)
            .subscribe { (owner, _) in
                owner.increasePageIndex()
            }
            .disposed(by: disposeBag)
        
        // Step2 중복확인 버튼 이벤트 처리
        input.tap_step2_nickNameCheckButton
            .subscribe { _ in
                // 네트워크 사용으로 수정 필요
                step2_isDuplicate.onNext(false)
            }
            .disposed(by: disposeBag)
        
        // Step2 nickName Validation 상태 이벤트 처리
        input.event_step2_availableNickName
            .withUnretained(self)
            .subscribe(onNext: { (owner, nickname) in
                if let nickname = nickname {
                    owner.userNickName.onNext(nickname)
                    step2_primaryButton_isEnabled.onNext(true)
                } else {
                    owner.userNickName.onNext("error")
                    step2_primaryButton_isEnabled.onNext(false)
                }
            })
            .disposed(by: disposeBag)
        
        // 관심사 리스트 변경 이벤트 처리
        input.event_step3_didChangeInterestList
            .subscribe { list in
                step3_primaryButton_isEnabled.onNext(list.count > 0 ? true : false)
            } onError: { error in
                print("관심사 선택 중 알 수 없는 오류가 발생하였습니다.")
            }
            .disposed(by: disposeBag)

        // Step 3 primary button 탭 이벤트 처리
        input.tap_step3_primaryButton
            .withUnretained(self)
            .subscribe { (owner, _) in
                owner.increasePageIndex()
            }
            .disposed(by: disposeBag)
        
        // Step 3 secondary button 탭 이벤트 처리
        input.tap_step3_secondaryButton
            .withUnretained(self)
            .subscribe { (owner, _) in
                owner.increasePageIndex()
            }
            .disposed(by: disposeBag)
        
        // Step 4 segmented Control 이벤트 처리
        input.event_step4_didSelectedGender
            .subscribe { selectedIndex in
                print(selectedIndex)
            }
            .disposed(by: disposeBag)
        
        // Step 4 tap_step4_ageButton 이벤트 처리
        input.tap_step4_ageButton
            .subscribe { _ in
                print("tap_step4_ageButton")
            }
            .disposed(by: disposeBag)
        
        return Output(
            increasePageIndex: pageIndexIncreaseObserver,
            decreasePageIndex: pageIndexDecreaseObserver,
            step1_primaryButton_isEnabled: step1_primaryButton_isEnabled,
            step2_isDuplicate: step2_isDuplicate,
            step2_primaryButton_isEnabled: step2_primaryButton_isEnabled,
            fetchCategoryList: fetchCategoryList,
            step3_primaryButton_isEnabled: step3_primaryButton_isEnabled,
            fetchUserNickname: userNickName,
            moveToRecentVC: input.tap_header_cancelButton
        )
    }
}

private extension SignUpVM {
    func increasePageIndex() {
        let index = pageIndex.value + 1
        pageIndex.accept(index)
        pageIndexIncreaseObserver.onNext(index)
    }
    
    func decreasePageIndex() {
        let index = pageIndex.value - 1
        pageIndex.accept(index)
        pageIndexDecreaseObserver.onNext(index)
    }
}
