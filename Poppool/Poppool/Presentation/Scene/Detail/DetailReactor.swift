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
import LinkPresentation

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
        case commentImageTapped(controller: BaseViewController, cellRow: Int, ImageRow: Int)
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
        case moveToImageDetailScene(controller: BaseViewController, cellRow: Int, ImageRow: Int)
    }
    
    private var commentButtonIsEnable: Bool = false
    
    struct State {
        var sections: [any Sectionable] = []
        var barkGroundImagePath: String?
        var commentButtonIsEnable: Bool = false
    }
    
    // MARK: - properties
    
    var initialState: State
    var disposeBag = DisposeBag()
    private let popUpID: Int64
    private var popUpName: String?
    private var isLogin: Bool = false
    
    private var imageService = PreSignedService()
    private let popUpAPIUseCase = PopUpAPIUseCaseImpl(repository: PopUpAPIRepositoryImpl(provider: ProviderImpl()))
    private let userAPIUseCase = UserAPIUseCaseImpl(repository: UserAPIRepositoryImpl(provider: ProviderImpl()))
    private let commentAPIUseCase = CommentAPIUseCaseImpl(repository: CommentAPIRepository(provider: ProviderImpl()))
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
    private var commentEmptySection = DetailEmptyCommetSection(inputDataList: [.init()])
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
            return bookMark()
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
            return commentLike(indexPath: indexPath)
        case .similarSectionTapped(let controller, let indexPath):
            return Observable.just(.moveToDetailScene(controller: controller, indexPath: indexPath))
        case .backButtonTapped(let controller):
            return Observable.just(.moveToRecentScene(controller: controller))
        case .loginButtonTapped(let controller):
            return Observable.just(.moveToLoginScene(controller: controller))
        case .commentImageTapped(let controller, let cellRow, let ImageRow):
            return Observable.just(.moveToImageDetailScene(controller: controller, cellRow: cellRow, ImageRow: ImageRow))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .loadView:
            newState.sections = getSection()
            newState.commentButtonIsEnable = commentButtonIsEnable
            if let path = imageBannerSection.inputDataList.first?.imagePaths.first {
                newState.barkGroundImagePath = path
            }
        case .moveToCommentTypeSelectedScene(let controller):
            if isLogin {
                let commentController = NormalCommentAddController()
                commentController.reactor = NormalCommentAddReactor(popUpID: popUpID, popUpName: popUpName ?? "")
                controller.navigationController?.pushViewController(commentController, animated: true)
            } else {
                let loginController = SubLoginController()
                loginController.reactor = SubLoginReactor()
                let nextController = UINavigationController(rootViewController: loginController)
                nextController.modalPresentationStyle = .fullScreen
                controller.present(nextController, animated: true)
            }
        case .showSharedBoard(let controller):
            showSharedBoard(controller: controller)
        case .copyAddress:
            UIPasteboard.general.string = infoSection.inputDataList.first?.address
            ToastMaker.createToast(message: "주소를 복사했어요")
        case .moveToAddressScene(let controller):
                 let mapGuideController = MapGuideViewController(popUpStoreId: popUpID)
                 let reactor = MapGuideReactor(popUpStoreId: popUpID)
                 mapGuideController.reactor = reactor 
            // 네비게이션 컨트롤러로 감싸기
            let navigationController = UINavigationController(rootViewController: mapGuideController)
            navigationController.modalPresentationStyle = .fullScreen

            // 모달로 표시
            controller.present(navigationController, animated: true)



        case .moveToCommentTotalScene(let controller):
            if isLogin {
                let nextController = CommentListController()
                nextController.reactor = CommentListReactor(popUpID: popUpID)
                controller.navigationController?.pushViewController(nextController, animated: true)
            } else {
                let loginController = SubLoginController()
                loginController.reactor = SubLoginReactor()
                let nextController = UINavigationController(rootViewController: loginController)
                nextController.modalPresentationStyle = .fullScreen
                controller.present(nextController, animated: true)
            }
        case .showCommentMenu(let controller, let indexPath):
            let comment = commentSection.inputDataList[indexPath.row]
            if comment.isMyComment {
                showMyCommentMenu(controller: controller, indexPath: indexPath, comment: comment)
            } else {
                showOtherUserCommentMenu(controller: controller, indexPath: indexPath, comment: comment)
            }
        case .showCommentDetailScene(let controller, let indexPath):
            let comment = commentSection.inputDataList[indexPath.row]
            let nextController = CommentDetailController()
            nextController.reactor = CommentDetailReactor(comment: comment)
            controller.presentPanModal(nextController)
        case .moveToDetailScene(let controller, let indexPath):
            let id = similarSection.inputDataList[indexPath.row].id
            let nextController = DetailController()
            nextController.reactor = DetailReactor(popUpID: id)
            controller.navigationController?.pushViewController(nextController, animated: true)
        case .moveToRecentScene(let controller):
            controller.navigationController?.popViewController(animated: true)
        case .moveToLoginScene(let controller):
            let loginController = SubLoginController()
            loginController.reactor = SubLoginReactor()
            let nextController = UINavigationController(rootViewController: loginController)
            nextController.modalPresentationStyle = .fullScreen
            controller.present(nextController, animated: true)
        case .moveToImageDetailScene(let controller, let cellRow, let ImageRow):
            let imagePath = commentSection.inputDataList[cellRow].imageList[ImageRow]
            let nextController = ImageDetailController()
            nextController.reactor = ImageDetailReactor(imagePath: imagePath)
            nextController.modalPresentationStyle = .overCurrentContext
            controller.present(nextController, animated: true)
        }
        return newState
    }
    
    func getSection() -> [any Sectionable] {
        if similarSection.inputDataList.isEmpty {
            if commentSection.inputDataList.isEmpty {
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
                    commentEmptySection,
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
                    spacing70Section
                ]
            }
        } else {
            if commentSection.inputDataList.isEmpty {
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
                    commentEmptySection,
                    spacing40Section,
                    similarTitleSecion,
                    spacing24Section,
                    similarSection,
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
        
    }
    
    func setContent() -> Observable<Mutation> {
        return popUpAPIUseCase.getPopUpDetail(commentType: "NORMAL", popUpStoredId: popUpID)
            .withUnretained(self)
            .map { (owner, response) in
                
                owner.isLogin = response.loginYn
                // image Banner
                let imagePaths = response.imageList.compactMap { $0.imageUrl }
                let idList = response.imageList.map { $0.id }
                owner.imageBannerSection.inputDataList = [.init(imagePaths: imagePaths, idList: idList, isHiddenPauseButton: true)]
                owner.commentButtonIsEnable = !response.hasCommented
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
                owner.commentTitleSection.inputDataList = [.init(commentCount: response.commentCount, buttonIsHidden: response.commentCount == 0 ? true : false)]
                owner.commentSection.inputDataList = response.commentList.map({ commentResponse in
                    return .init(
                        commentID: commentResponse.commentId,
                        nickName: commentResponse.nickname,
                        profileImagePath: commentResponse.profileImageUrl,
                        date: commentResponse.createDateTime,
                        comment: commentResponse.content,
                        imageList: commentResponse.commentImageList.map { $0.imageUrl },
                        imageIDList: commentResponse.commentImageList.map { $0.id },
                        isLike: commentResponse.likeYn,
                        likeCount: commentResponse.likeCount,
                        isLogin: response.loginYn,
                        title: response.name,
                        creator: commentResponse.creator,
                        isMyComment: commentResponse.myCommentYn
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
            titleSection.inputDataList[0].isBookMark.toggle()
            ToastMaker.createBookMarkToast(isBookMark: !isBookMark)
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
        let storeName = titleSection.inputDataList.first?.title ?? ""
        let imagePath = Secrets.popPoolS3BaseURL.rawValue + (imageBannerSection.inputDataList.first?.imagePaths.first ?? "")
        
        // URL 인코딩 후 생성
        guard let encodedPath = imagePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedPath) else {
            Logger.log(message: "URL 생성 실패", category: .error)
            return
        }
        
        // 🔹 비동기적으로 이미지 다운로드
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                Logger.log(message: "다운로드 실패", category: .error)
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                Logger.log(message: "이미지 변환 실패", category: .error)
                return
            }
            
            Logger.log(message: "이미지 다운로드 성공", category: .info)
            
            let sharedText = "[팝풀] \(storeName) 팝업 어때요?\n지금 바로 팝풀에서 확인해보세요!"
            // UI 업데이트는 메인 스레드에서 실행
            DispatchQueue.main.async {
                let imageItem = ItemDetailSource(name: storeName, image: image)
                let activityViewController = UIActivityViewController(
                    activityItems: [imageItem, sharedText],
                    applicationActivities: nil
                )
                controller.present(activityViewController, animated: true, completion: nil)
            }
            
        }.resume()
    }
    
    func commentLike(indexPath: IndexPath) -> Observable<Mutation> {
        let isLike = commentSection.inputDataList[indexPath.row].isLike
        let commentID = commentSection.inputDataList[indexPath.row].commentID
        commentSection.inputDataList[indexPath.row].isLike.toggle()
        if isLike {
            commentSection.inputDataList[indexPath.row].likeCount -= 1
            return userAPIUseCase.deleteCommentLike(commentId: commentID)
                .andThen(Observable.just(.loadView))
        } else {
            commentSection.inputDataList[indexPath.row].likeCount += 1
            return userAPIUseCase.postCommentLike(commentId: commentID)
                .andThen(Observable.just(.loadView))
        }
    }
    
    func showOtherUserCommentMenu(controller: BaseViewController, indexPath: IndexPath, comment: DetailCommentSection.CellType.Input) {
        let nextController = CommentUserInfoController()
        nextController.reactor = CommentUserInfoReactor(nickName: comment.nickName)
        controller.presentPanModal(nextController)
        nextController.reactor?.state
            .withUnretained(nextController)
            .subscribe(onNext: { [weak self] (owner, state) in
                guard let self = self else { return }
                switch state.selectedType {
                case .normal:
                    owner.dismiss(animated: true) { [weak controller] in
                        let otherUserCommentController = OtherUserCommentController()
                        otherUserCommentController.reactor = OtherUserCommentReactor(commenterID: comment.creator)
                        controller?.navigationController?.pushViewController(otherUserCommentController, animated: true)
                    }
                case .block:
                    owner.dismiss(animated: true) { [weak controller] in
                        let blockController = CommentUserBlockController()
                        blockController.reactor = CommentUserBlockReactor(nickName: comment.nickName)
                        controller?.presentPanModal(blockController)
                        blockController.reactor?.state
                            .withUnretained(blockController)
                            .subscribe(onNext: { (blockController, state) in
                                switch state.selectedType {
                                case .none:
                                    break
                                case .block:
                                    self.userAPIUseCase.postUserBlock(blockedUserId: comment.creator)
                                        .subscribe(onDisposed:  {
                                            blockController.dismiss(animated: true)
                                        })
                                        .disposed(by: self.disposeBag)
                                case .cancel:
                                    blockController.dismiss(animated: true)
                                }
                            })
                            .disposed(by: self.disposeBag)
                    }
                case .cancel:
                    owner.dismiss(animated: true)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    func showMyCommentMenu(controller: BaseViewController, indexPath: IndexPath, comment: DetailCommentSection.CellType.Input) {
        let nextController = CommentMyMenuController()
        nextController.reactor = CommentMyMenuReactor(nickName: comment.nickName)
        imageService = PreSignedService()
        controller.presentPanModal(nextController)
        
        nextController.reactor?.state
            .withUnretained(nextController)
            .subscribe(onNext: { [weak self] (owner, state) in
                guard let self = self else { return }
                switch state.selectedType {
                case .remove:
                    self.commentAPIUseCase.deleteComment(popUpStoreId: self.popUpID, commentId: comment.commentID)
                        .subscribe(onDisposed: {
                            owner.dismiss(animated: true)
                            ToastMaker.createToast(message: "작성한 코멘트를 삭제했어요")
                        })
                        .disposed(by: owner.disposeBag)
                    
                    let commentList = comment.imageList.compactMap { $0 }
                    self.imageService.tryDelete(targetPaths: .init(objectKeyList: commentList))
                        .subscribe {
                            Logger.log(message: "S3 Image Delete 완료", category: .info)
                        }
                        .disposed(by: self.disposeBag)

                case .edit:
                    owner.dismiss(animated: true) { [weak controller] in
                        guard let popUpName = self.popUpName else { return }
                        let editController = NormalCommentEditController()
                        editController.reactor = NormalCommentEditReactor(popUpID: self.popUpID, popUpName: popUpName, comment: comment)
                        controller?.navigationController?.pushViewController(editController, animated: true)
                    }
                case .cancel:
                    owner.dismiss(animated: true)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
}

class ItemDetailSource: NSObject {
    let name: String
    let image: UIImage
    
    init(name: String, image: UIImage) {
        self.name = name
        self.image = image
    }
}

extension ItemDetailSource: UIActivityItemSource {
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        image
    }
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        image
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metaData = LPLinkMetadata()
        metaData.title = name
        metaData.imageProvider = NSItemProvider(object: image)
        return metaData
    }
}
