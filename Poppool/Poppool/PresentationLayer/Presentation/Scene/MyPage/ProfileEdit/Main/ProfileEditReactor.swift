//
//  ProfileEditReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/4/25.
//

import PhotosUI
import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class ProfileEditReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case categoryButtonTapped(controller: BaseViewController)
        case infoButtonTapped(controller: BaseViewController)
        case changeImage(image: UIImage)
        case changeDefaultImage
        case changeNickName(nickName: String?)
        case beginNickName
        case endNickName
        case nickNameCheckButtonTapped
        case changeIntro(intro: String?)
        case beginIntro
        case endIntro
        case saveButtonTapped
        case backButtonTapped(controller: BaseViewController)
    }

    enum Mutation {
        case loadView
        case moveToInfoEditScene(controller: BaseViewController)
        case moveToCategoryEditScene(controller: BaseViewController)
        case isValidateNickName(Bool)
        case moveToRecentScene(controller: BaseViewController)
        case changeNickNameState
    }

    struct State {
        var originProfileData: GetMyProfileResponse?
        var saveButtonIsEnable: Bool = false
        var nickNameState: NickNameState = .myNickName
        var introState: IntroState = .validate
    }

    // MARK: - properties

    var initialState: State
    var disposeBag = DisposeBag()
    var originProfileData: GetMyProfileResponse?

    var currentImage: UIImage?
    var isChangeImage: Bool = false
    var currentImagePath: String?

    var currentNickName: String?
    var nickNameIsActive: Bool = false

    var currentIntro: String?
    var introIsActive: Bool = false

    private let userAPIUseCase = UserAPIUseCaseImpl(repository: UserAPIRepositoryImpl(provider: ProviderImpl()))
    private let signUpAPIUseCase = SignUpAPIUseCaseImpl(repository: SignUpRepositoryImpl(provider: ProviderImpl()))
    private let imageService = PreSignedService()

    // MARK: - init
    init() {
        self.initialState = State()
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return loadProfileData()
        case .categoryButtonTapped(let controller):
            return Observable.just(.moveToCategoryEditScene(controller: controller))
        case .infoButtonTapped(let controller):
            return Observable.just(.moveToInfoEditScene(controller: controller))
        case .changeImage(let image):
            currentImage = image
            isChangeImage = true
            return Observable.just(.loadView)
        case .changeDefaultImage:
            currentImage = nil
            isChangeImage = true
            currentImagePath = nil
            return Observable.just(.loadView)
        case .saveButtonTapped:
            return Observable.concat([
                uploadS3(),
                editProfile(),
                loadProfileData()
            ])
        case .changeNickName(let nickName):
            currentNickName = nickName
            return Observable.just(.changeNickNameState)
        case .beginNickName:
            nickNameIsActive = true
            return Observable.just(.changeNickNameState)
        case .endNickName:
            nickNameIsActive = false
            return Observable.just(.changeNickNameState)
        case .nickNameCheckButtonTapped:
            return signUpAPIUseCase.checkNickName(nickName: currentNickName ?? "")
                .map { isValidate in
                    return .isValidateNickName(isValidate)
                }
        case .changeIntro(let intro):
            currentIntro = intro
            return Observable.just(.loadView)
        case .beginIntro:
            introIsActive = true
            return Observable.just(.loadView)
        case .endIntro:
            introIsActive = false
            return Observable.just(.loadView)
        case .backButtonTapped(let controller):
            return Observable.just(.moveToRecentScene(controller: controller))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .loadView:
            newState.originProfileData = originProfileData
            newState.introState = checkIntroState(text: currentIntro, isActive: introIsActive)
        case .moveToCategoryEditScene(let controller):
            let nextController = CategoryEditModalController()
            nextController.reactor = CategoryEditModalReactor(selectedID: newState.originProfileData?.interestCategoryList.map { $0.categoryId } ?? [])
            controller.presentPanModal(nextController)
        case .moveToInfoEditScene(let controller):
            let nextController = InfoEditModalController()
            nextController.reactor = InfoEditModalReactor(age: originProfileData?.age ?? 0, gender: originProfileData?.gender)
            controller.presentPanModal(nextController)
        case .isValidateNickName(let isValidate):
            if isValidate {
                newState.nickNameState = .duplicated
            } else {
                newState.nickNameState = .validate
            }
        case .moveToRecentScene(let controller):
            controller.navigationController?.popViewController(animated: true)
        case .changeNickNameState:
            newState.nickNameState = checkNickNameState(text: currentNickName, isActive: nickNameIsActive)
        }

        let originNickName = originProfileData?.nickname ?? ""
        let currentNickName = currentNickName ?? ""
        let originIntro = originProfileData?.intro ?? ""
        let currentIntro = currentIntro ?? ""

        if isChangeImage || originNickName != currentNickName || originIntro != currentIntro {
            if newState.nickNameState == .validate || newState.nickNameState == .validateActive || newState.nickNameState == .myNickName || newState.nickNameState == .myNickNameActive {
                if newState.introState == .validate || newState.introState == .validateActive || newState.introState == .empty || newState.introState == .emptyActive {
                    newState.saveButtonIsEnable = true
                } else {
                    newState.saveButtonIsEnable = false
                }
            } else {
                newState.saveButtonIsEnable = false
            }
        } else {
            newState.saveButtonIsEnable = false
        }

        return newState
    }

    func uploadS3() -> Observable<Mutation> {
        if let changeImage = currentImage {
            let newPath = "ProfileImage/\(UUID().uuidString).jpg"
            currentImagePath = newPath
            if originProfileData?.profileImageUrl == nil {
                return imageService.tryUpload(datas: [.init(filePath: newPath, image: changeImage)])
                    .asObservable()
                    .map { .loadView }
            } else {
                let deletePath = originProfileData?.profileImageUrl ?? ""
                return imageService.tryDelete(targetPaths: .init(objectKeyList: [deletePath]))
                    .andThen(
                        imageService.tryUpload(datas: [.init(filePath: newPath, image: changeImage)])
                        .asObservable()
                        .map { .loadView }
                    )
            }
        } else {
            // s3에서 삭제
            if currentImagePath == nil {
                if originProfileData?.profileImageUrl == nil {
                    return Observable.just(.loadView)
                } else {
                    currentImagePath = nil
                    let deletePath = originProfileData?.profileImageUrl ?? ""
                    return imageService.tryDelete(targetPaths: .init(objectKeyList: [deletePath]))
                        .andThen(Observable.just(.loadView))
                }
            } else {
                return Observable.just(.loadView)
            }
        }
    }

    func editProfile() -> Observable<Mutation> {
        isChangeImage = false
        ToastMaker.createToast(message: "내용을 저장했어요")
        return userAPIUseCase.putUserProfile(
            profileImageUrl: currentImagePath,
            nickname: currentNickName,
            email: originProfileData?.email,
            instagramId: originProfileData?.instagramId,
            intro: currentIntro
        )
        .andThen(Observable.just(.loadView))
    }

    func loadProfileData() -> Observable<Mutation> {
        return userAPIUseCase.getMyProfile()
            .withUnretained(self)
            .map { (owner, response) in
                owner.currentImagePath = response.profileImageUrl
                owner.currentNickName = response.nickname
                owner.currentIntro = response.intro
                owner.originProfileData = response
                return .loadView
            }
    }

    func checkNickNameState(text: String?, isActive: Bool) -> NickNameState {
        guard let text = text, let originNickName = originProfileData?.nickname else { return isActive ? .emptyActive : .empty }
        if originNickName == text { return isActive ? .myNickNameActive : .myNickName }

        // textEmpty Check
        if text.isEmpty { return isActive ? .emptyActive : .empty }

        // kor and end Check
        let pattern = "^[가-힣a-zA-Z\\s]+$" // 허용하는 문자만 검사
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return .empty }
        let range = NSRange(location: 0, length: text.utf16.count)
        if regex.firstMatch(in: text, options: [], range: range) == nil { return isActive ? .korAndEngActive : .korAndEng }

        // textLength Check

        if text.count < 2 { return isActive ? .shortLengthActive : .shortLength }
        if text.count > 10 { return isActive ? .longLengthActive : .longLength }
        return isActive ? .checkActive : .check
    }

    func checkIntroState(text: String?, isActive: Bool) -> IntroState {
        guard let text = text else { return isActive ? .emptyActive : .empty }
        if text.isEmpty { return isActive ? .emptyActive : .empty }
        if text.count > 30 { return isActive ? .longLengthActive : .longLength }
        return isActive ? .validateActive : .validate
    }
}
