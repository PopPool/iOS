//
//  DetailReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/9/24.
//

import UIKit

import ReactorKit
import RxSwift
import RxCocoa

final class DetailReactor: Reactor {
    
    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case commentButtonTapped(controller: BaseViewController)
        case bookMarkButtonTapped
        case sharedButtonTapped(controller: BaseViewController)
        case copyButtonTapped
        case addressButtonTapped(controller: BaseViewController)
        case commentTotalViewButtonTapped(controller: BaseViewController)
        case commentMenuButtonTapped(controller: BaseViewController, indexPath: IndexPath)
        case commentDetailButtonTapped(controller: BaseViewController, indexPath: IndexPath)
        case commentLikeButtonTapped(indexPath: IndexPath)
        case similarSectionTapped(controller: BaseViewController, indexPath: IndexPath)
        case backButtonTapped(controller: BaseViewController)
        case loginButtonTapped(controller: BaseViewController)
    }
    
    enum Mutation {
        case loadView
        case moveToCommentTypeSelectedScene(controller: BaseViewController)
        case showSharedBoard(controller: BaseViewController)
        case copyAddress
        case moveToAddressScene(controller: BaseViewController)
        case moveToCommentTotalScene(controller: BaseViewController)
        case showCommentMenu(controller: BaseViewController, indexPath: IndexPath)
        case showCommentDetailScene(controller: BaseViewController, indexPath: IndexPath)
        case moveToDetailScene(controller: BaseViewController, indexPath: IndexPath)
        case moveToRecentScene(controller: BaseViewController)
        case moveToLoginScene(controller: BaseViewController)
    }
    
    struct State {
        var sections: [any Sectionable] = []
    }
    
    // MARK: - properties
    
    var initialState: State
    var disposeBag = DisposeBag()
    private let popUpID: Int64
    private var popUpName: String?
    
    private let popUpAPIUseCase = PopUpAPIUseCaseImpl(repository: PopUpAPIRepositoryImpl(provider: ProviderImpl()))
    private let userAPIUseCase = UserAPIUseCaseImpl(repository: UserAPIRepositoryImpl(provider: ProviderImpl()))
    lazy var compositionalLayout: UICollectionViewCompositionalLayout = {
        UICollectionViewCompositionalLayout { [weak self] section, env in
            guard let self = self else {
                return NSCollectionLayoutSection(group: NSCollectionLayoutGroup(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)
                    ))
                )
            }
            return getSection()[section].getSection(section: section, env: env)
        }
    }()
    
    private var imageBannerSection = ImageBannerSection(inputDataList: [])
    private var titleSection = DetailTitleSection(inputDataList: [])
    private var contentSection = DetailContentSection(inputDataList: [])
    private var infoSection = DetailInfoSection(inputDataList: [])
    private var commentTitleSection = DetailCommentTitleSection(inputDataList: [])
    private var commentSection = DetailCommentSection(inputDataList: [])
    private var similarTitleSecion = SearchTitleSection(inputDataList: [.init(title: "지금 보고있는 팝업과 비슷한 팝업")])
    private var similarSection = DetailSimilarSection(inputDataList: [])
    
    
    private var spacing70Section = SpacingSection(inputDataList: [.init(spacing: 70)])
    private var spacing40Section = SpacingSection(inputDataList: [.init(spacing: 40)])
    private var spacing36Section = SpacingSection(inputDataList: [.init(spacing: 36)])
    private var spacing28Section = SpacingSection(inputDataList: [.init(spacing: 28)])
    private var spacing24Section = SpacingSection(inputDataList: [.init(spacing: 24)])
    private var spacing20Section = SpacingSection(inputDataList: [.init(spacing: 20)])
    private var spacing16Section = SpacingSection(inputDataList: [.init(spacing: 16)])
    private var spacing16GraySection = SpacingSection(inputDataList: [.init(spacing: 16, backgroundColor: .g50)])
    // MARK: - init
    init(popUpID: Int64) {
        self.popUpID = popUpID
        self.initialState = State()
    }
    
    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return setContent()
        case .bookMarkButtonTapped:
            return Observable.concat([
                bookMark(),
                setContent()
            ])
        case .sharedButtonTapped(let controller):
            return Observable.just(.showSharedBoard(controller: controller))
        case .copyButtonTapped:
            return Observable.just(.copyAddress)
        case .addressButtonTapped(let controller):
            return Observable.just(.moveToAddressScene(controller: controller))
        case .commentTotalViewButtonTapped(let controller):
            return Observable.just(.moveToCommentTotalScene(controller: controller))
        case .commentMenuButtonTapped(let controller, let indexPath):
            return Observable.just(.showCommentMenu(controller: controller, indexPath: indexPath))
        case .commentDetailButtonTapped(let controller, let indexPath):
            return Observable.just(.showCommentDetailScene(controller: controller, indexPath: indexPath))
        case .commentButtonTapped(let controller):
            return Observable.just(.moveToCommentTypeSelectedScene(controller: controller))
        case .commentLikeButtonTapped(let indexPath):
            return Observable.concat([
                commentLike(indexPath: indexPath),
                setContent()
            ])
        case .similarSectionTapped(let controller, let indexPath):
            return Observable.just(.moveToDetailScene(controller: controller, indexPath: indexPath))
        case .backButtonTapped(let controller):
            return Observable.just(.moveToRecentScene(controller: controller))
        case .loginButtonTapped(let controller):
            return Observable.just(.moveToLoginScene(controller: controller))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .loadView:
            newState.sections = getSection()
        case .moveToCommentTypeSelectedScene(let controller):
            let nextController = CommentSelectedController()
            nextController.reactor = CommentSelectedReactor()
            controller.presentPanModal(nextController)
            nextController.reactor?.state
                .withUnretained(nextController)
                .subscribe(onNext: { (nextController, state) in
                    switch state.selectedType {
                    case .cancel:
                        nextController.dismiss(animated: true)
                    case .normal:
                        nextController.dismiss(animated: true) {
                            let commentController = NormalCommentAddController()
                            commentController.reactor = NormalCommentAddReactor(popUpID: self.popUpID, popUpName: self.popUpName ?? "")
                            controller.navigationController?.pushViewController(commentController, animated: true)
                        }
                    case .insta:
                        nextController.dismiss(animated: true) {
                            let commentController = InstaCommentAddController()
                            commentController.reactor = InstaCommentAddReactor()
                            controller.navigationController?.pushViewController(commentController, animated: true)
                        }
                    case .none:
                        break
                    }
                })
                .disposed(by: disposeBag)
        case .showSharedBoard(let controller):
            showSharedBoard(controller: controller)
        case .copyAddress:
            print("Copy Address")
        case .moveToAddressScene(let controller):
            let nextController = BaseViewController()
            controller.navigationController?.pushViewController(nextController, animated: true)
        case .moveToCommentTotalScene(let controller):
            let nextController = BaseViewController()
            controller.navigationController?.pushViewController(nextController, animated: true)
        case .showCommentMenu(let controller, let indexPath):
            let nextController = BaseViewController()
            controller.navigationController?.pushViewController(nextController, animated: true)
        case .showCommentDetailScene(let controller, let indexPath):
            let nextController = BaseViewController()
            controller.navigationController?.pushViewController(nextController, animated: true)
        case .moveToDetailScene(let controller, let indexPath):
            let id = similarSection.inputDataList[indexPath.row].id
            let nextController = DetailController()
            nextController.reactor = DetailReactor(popUpID: id)
            controller.navigationController?.pushViewController(nextController, animated: true)
        case .moveToRecentScene(let controller):
            controller.navigationController?.popViewController(animated: true)
        case .moveToLoginScene(let controller):
            let nextController = BaseViewController()
            controller.navigationController?.pushViewController(nextController, animated: true)
        }
        return newState
    }
    
    func getSection() -> [any Sectionable] {
        if similarSection.inputDataList.isEmpty {
            return [
                imageBannerSection,
                spacing36Section,
                titleSection,
                spacing20Section,
                contentSection,
                spacing28Section,
                infoSection,
                spacing40Section,
                spacing16GraySection,
                spacing36Section,
                commentTitleSection,
                spacing16Section,
                commentSection,
                spacing70Section
            ]
        } else {
            return [
                imageBannerSection,
                spacing36Section,
                titleSection,
                spacing20Section,
                contentSection,
                spacing28Section,
                infoSection,
                spacing40Section,
                spacing16GraySection,
                spacing36Section,
                commentTitleSection,
                spacing16Section,
                commentSection,
                spacing40Section,
                similarTitleSecion,
                spacing24Section,
                similarSection,
                spacing70Section
            ]
        }

    }
    
    func setContent() -> Observable<Mutation> {
        return popUpAPIUseCase.getPopUpDetail(commentType: "NORMAL", popUpStoredId: popUpID)
            .withUnretained(self)
            .map { (owner, response) in
                
                // image Banner
                let imagePaths = response.imageList.compactMap { $0.imageUrl }
                let idList = response.imageList.map { $0.id }
                owner.imageBannerSection.inputDataList = [.init(imagePaths: imagePaths, idList: idList, isHiddenPauseButton: true)]
                
                // titleSection
                owner.titleSection.inputDataList = [.init(title: response.name, isBookMark: response.bookmarkYn, isLogin: response.loginYn)]
                owner.popUpName = response.name
                
                // contentSection
                owner.contentSection.inputDataList = [.init(content: response.desc)]
                owner.infoSection.inputDataList = [.init(
                    startDate: response.startDate,
                    endDate: response.endDate,
                    startTime: response.startTime,
                    endTime: response.endTime,
                    address: response.address)
                ]
                owner.commentTitleSection.inputDataList = [.init(commentCount: response.commentCount)]
                owner.commentSection.inputDataList = response.commentList.map({ commentResponse in
                    return .init(
                        commentID: commentResponse.commentId,
                        nickName: commentResponse.nickname,
                        profileImagePath: commentResponse.profileImageUrl,
                        date: commentResponse.createDateTime,
                        comment: commentResponse.content,
                        imageList: commentResponse.commentImageList.map { $0.imageUrl },
                        isLike: commentResponse.likeYn,
                        likeCount: commentResponse.likeCount,
                        isLogin: response.loginYn,
                        title: response.name
                    )
                })
                
                owner.similarSection.inputDataList = response.similarPopUpStoreList.map {
                    return .init(imagePath: $0.mainImageUrl, date: $0.endDate, title: $0.name, id: $0.id)
                }
                return .loadView
            }
    }
    
    func bookMark() -> Observable<Mutation> {
        if let isBookMark = titleSection.inputDataList.first?.isBookMark {
            if isBookMark {
                return userAPIUseCase.deleteBookmarkPopUp(popUpID: popUpID)
                    .andThen(Observable.just(.loadView))
            } else {
                return userAPIUseCase.postBookmarkPopUp(popUpID: popUpID)
                    .andThen(Observable.just(.loadView))
            }
        } else {
            return Observable.just(.loadView)
        }
    }
    
    func showSharedBoard(controller: BaseViewController) {
        let text = "Some Text"
        let itemsToShare: [Any] = [text]
        let activityViewController = UIActivityViewController(
            activityItems: itemsToShare,
            applicationActivities: nil
        )
        controller.present(activityViewController, animated: true, completion: nil)
        
    }
    
    func commentLike(indexPath: IndexPath) -> Observable<Mutation> {
        let isLike = commentSection.inputDataList[indexPath.row].isLike
        let commentID = commentSection.inputDataList[indexPath.row].commentID
        if isLike {
            return userAPIUseCase.deleteCommentLike(commentId: commentID)
                .andThen(Observable.just(.loadView))
        } else {
            return userAPIUseCase.postCommentLike(commentId: commentID)
                .andThen(Observable.just(.loadView))
        }
    }
}
