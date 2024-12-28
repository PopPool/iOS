//
//  CommentDetailReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/25/24.
//

import UIKit

import ReactorKit
import RxSwift
import RxCocoa

final class CommentDetailReactor: Reactor {
    
    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case imageCellTapped(controller: BaseViewController, row: Int)
        case likeButtonTapped
    }
    
    enum Mutation {
        case loadView
        case presentImageDetailView(controller: BaseViewController, row: Int)
        case likeChange
    }
    
    struct State {
        var commentData: DetailCommentSection.CellType.Input
        var sections: [any Sectionable] = []
    }
    
    // MARK: - properties
    
    var initialState: State
    var disposeBag = DisposeBag()
    
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
    
    private var imageSection = CommentDetailImageSection(inputDataList: [])
    private var contentSection = CommentDetailContentSection(inputDataList: [])
    
    private let spacing16Section = SpacingSection(inputDataList: [.init(spacing: 16)])
    
    // MARK: - init
    init(comment: DetailCommentSection.CellType.Input) {
        self.initialState = State(commentData: comment)
    }
    
    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .likeButtonTapped:
            return Observable.just(.likeChange)
        case .viewWillAppear:
            return Observable.just(.loadView)
        case .imageCellTapped(let controller, let row):
            return Observable.just(.presentImageDetailView(controller: controller, row: row))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .loadView:
            imageSection.inputDataList = state.commentData.imageList.map { .init(imagePath: $0) }
            contentSection.inputDataList = [.init(content: state.commentData.comment)]
            newState.sections = getSection()
        case .presentImageDetailView(let controller, let row):
            let imagePath = imageSection.inputDataList[row].imagePath
            let nextController = ImageDetailController()
            nextController.reactor = ImageDetailReactor(imagePath: imagePath)
            nextController.modalPresentationStyle = .overFullScreen
            controller.present(nextController, animated: true)
        case .likeChange:

            newState.commentData.isLike.toggle()
            if newState.commentData.isLike {
                newState.commentData.likeCount += 1
                userAPIUseCase.postCommentLike(commentId: newState.commentData.commentID)
                    .subscribe(onDisposed:  {
                        Logger.log(message: "CommentLike", category: .info)
                    })
                    .disposed(by: disposeBag)
            } else {
                newState.commentData.likeCount -= 1
                userAPIUseCase.deleteCommentLike(commentId: newState.commentData.commentID)
                    .subscribe(onDisposed:  {
                        Logger.log(message: "CommentLikeDelete", category: .info)
                    })
                    .disposed(by: disposeBag)
            }
            newState.sections = getSection()
        }
        
        return newState
    }
    
    func getSection() -> [any Sectionable] {
        if imageSection.isEmpty  {
            return [
                contentSection
            ]
        } else {
            return [
                imageSection,
                spacing16Section,
                contentSection
            ]
        }
    }
}
