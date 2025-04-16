//
//  CommentListReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/25/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class CommentListReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case backButtonTapped(controller: BaseViewController)
        case scrollDidEndPoint
        case likeButtonTapped(row: Int)
        case detailButtonTapped(controller: BaseViewController, row: Int)
        case imageCellTapped(controller: BaseViewController, commentRow: Int, imageRow: Int)
        case profileButtonTapped(controller: BaseViewController, row: Int)
        case detailSceneLikeButtonTapped(row: Int)
    }

    enum Mutation {
        case loadView
        case moveToRecentScene(controller: BaseViewController)
        case none
        case presentDetailScene(controller: BaseViewController, row: Int)
        case presentImageScene(controller: BaseViewController, commentRow: Int, imageRow: Int)
        case presentCommentMenuScene(controller: BaseViewController, row: Int)
    }

    struct State {
        var sections: [any Sectionable] = []
        var isReloadView: Bool = false
    }

    // MARK: - properties

    var initialState: State
    var disposeBag = DisposeBag()
    private let popUpID: Int64
    private let popUpName: String?
    private var page: Int32 = 0
    private var appendDataIsEmpty: Bool = false

    private var imageService = PreSignedService()
    private let popUpAPIUseCase: PopUpAPIUseCase
    private let userAPIUseCase: UserAPIUseCase
    private let commentAPIUseCase = CommentAPIUseCaseImpl(repository: CommentAPIRepositoryImpl(provider: ProviderImpl()))

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

    private var commentTitleSection = CommentListTitleSection(inputDataList: [])
    private var commentSection = DetailCommentSection(inputDataList: [])

    private let spacing24Section = SpacingSection(inputDataList: [.init(spacing: 24)])
    private let spacing28Section = SpacingSection(inputDataList: [.init(spacing: 28)])
    // MARK: - init
    init(
        popUpID: Int64,
        popUpName: String?,
        userAPIUseCase: UserAPIUseCase,
        popUpAPIUseCase: PopUpAPIUseCase
    ) {
        self.initialState = State()
        self.popUpID = popUpID
        self.popUpName = popUpName
        self.userAPIUseCase = userAPIUseCase
        self.popUpAPIUseCase = popUpAPIUseCase
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            if page != 0 { return Observable.just(.none) }
            return popUpAPIUseCase.getPopUpComment(commentType: "NORMAL", page: page, size: 10, sort: nil, popUpStoreId: popUpID)
                .withUnretained(self)
                .map { (owner, response) in
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
                            isLogin: true,
                            title: nil,
                            creator: commentResponse.creator,
                            isMyComment: commentResponse.myCommentYn
                        )
                    })
                    for (index, cell) in owner.commentSection.inputDataList.enumerated() {
                        owner.commentSection.inputDataList[index].isLastCell = (index == owner.commentSection.inputDataList.count - 1)
                    }
                    owner.commentTitleSection.inputDataList = [.init(count: response.commentList.count)]
                    return .loadView
                }
        case .backButtonTapped(let controller):
            return Observable.just(.moveToRecentScene(controller: controller))
        case .scrollDidEndPoint:
            page += 1
            if appendDataIsEmpty {
                return Observable.just(.none)
            }
            return popUpAPIUseCase.getPopUpComment(commentType: "NORMAL", page: page, size: 10, sort: nil, popUpStoreId: popUpID)
                .withUnretained(self)
                .map { (owner, response) in
                    owner.appendDataIsEmpty = response.commentList.isEmpty
                    owner.appendDataIsEmpty = response.commentList.count <= 10
                    owner.commentSection.inputDataList.append(contentsOf: response.commentList.map({ commentResponse in
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
                            isLogin: true,
                            title: nil,
                            creator: commentResponse.creator,
                            isMyComment: commentResponse.myCommentYn
                        )
                    }))
                    for (index, cell) in owner.commentSection.inputDataList.enumerated() {
                        owner.commentSection.inputDataList[index].isLastCell = (index == owner.commentSection.inputDataList.count - 1)
                    }
                    owner.commentTitleSection.inputDataList = [.init(count: owner.commentSection.dataCount)]
                    return .loadView
                }
        case .likeButtonTapped(let row):
            let comment = commentSection.inputDataList[row]
            commentSection.inputDataList[row].isLike.toggle()
            if comment.isLike {
                commentSection.inputDataList[row].likeCount -= 1
                return userAPIUseCase.deleteCommentLike(commentId: comment.commentID)
                    .andThen(Observable.just(.loadView))
            } else {
                commentSection.inputDataList[row].likeCount += 1
                return userAPIUseCase.postCommentLike(commentId: comment.commentID)
                    .andThen(Observable.just(.loadView))
            }
        case .detailButtonTapped(let controller, let row):
            return Observable.just(.presentDetailScene(controller: controller, row: row))
        case .imageCellTapped(let controller, let commentRow, let imageRow):
            return Observable.just(.presentImageScene(controller: controller, commentRow: commentRow, imageRow: imageRow))
        case .profileButtonTapped(let controller, let row):
            return Observable.just(.presentCommentMenuScene(controller: controller, row: row))
        case .detailSceneLikeButtonTapped(let row):
            commentSection.inputDataList[row].isLike.toggle()
            if commentSection.inputDataList[row].isLike {
                commentSection.inputDataList[row].likeCount += 1
            } else {
                commentSection.inputDataList[row].likeCount -= 1
            }
            return Observable.just(.loadView)
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.isReloadView = false
        switch mutation {
        case .loadView:
            newState.isReloadView = true
            newState.sections = getSection()
        case .moveToRecentScene(let controller):
            controller.navigationController?.popViewController(animated: true)
        case .none:
            return newState
        case .presentDetailScene(let controller, let row):
            let comment = commentSection.inputDataList[row]
            let nextController = CommentDetailController()
            nextController.reactor = CommentDetailReactor(
                comment: comment,
                userAPIUseCase: userAPIUseCase
            )
            nextController.mainView.likeButton.rx.tap
                .map { Action.detailSceneLikeButtonTapped(row: row)}
                .bind(to: action)
                .disposed(by: nextController.disposeBag)
            controller.present(nextController, animated: true)
        case .presentImageScene(let controller, let commentRow, let imageRow):
            let imagePath = commentSection.inputDataList[commentRow].imageList[imageRow]
            let nextController = ImageDetailController()
            nextController.reactor = ImageDetailReactor(imagePath: imagePath)
            nextController.modalPresentationStyle = .overCurrentContext
            controller.present(nextController, animated: true)
        case .presentCommentMenuScene(let controller, let row):
            let comment = commentSection.inputDataList[row]
            if comment.isMyComment {
                showMyCommentMenu(controller: controller, comment: comment)
            } else {
                showOtherUserCommentMenu(controller: controller, comment: comment)
            }

        }
        return newState
    }

    func getSection() -> [any Sectionable] {
        return [
            spacing24Section,
            commentTitleSection,
            spacing28Section,
            commentSection
        ]
    }

    func showOtherUserCommentMenu(controller: BaseViewController, comment: DetailCommentSection.CellType.Input) {
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
                        otherUserCommentController.reactor = OtherUserCommentReactor(
                            commenterID: comment.creator,
                            userAPIUseCase: self.userAPIUseCase
                        )
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
                                    ToastMaker.createToast(message: "\(comment.nickName ?? "")을 차단했어요")
                                    self.userAPIUseCase.postUserBlock(blockedUserId: comment.creator)
                                        .subscribe(onDisposed: {
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

    func showMyCommentMenu(controller: BaseViewController, comment: DetailCommentSection.CellType.Input) {
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
                        .disposed(by: self.disposeBag)

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
