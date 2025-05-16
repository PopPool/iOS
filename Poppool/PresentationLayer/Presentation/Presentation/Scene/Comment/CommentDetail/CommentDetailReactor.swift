import UIKit

import DesignSystem
import DomainInterface
import Infrastructure

import ReactorKit
import RxCocoa
import RxSwift

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

    private let userAPIUseCase: UserAPIUseCase

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
    init(
        comment: DetailCommentSection.CellType.Input,
        userAPIUseCase: UserAPIUseCase
    ) {
        self.initialState = State(commentData: comment)
        self.userAPIUseCase = userAPIUseCase
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
            nextController.modalPresentationStyle = .overCurrentContext
            controller.present(nextController, animated: true)
        case .likeChange:

            newState.commentData.isLike.toggle()
            if newState.commentData.isLike {
                newState.commentData.likeCount += 1
                userAPIUseCase.postCommentLike(commentId: newState.commentData.commentID)
                    .subscribe(onDisposed: {
                        Logger.log("CommentLike", category: .info)
                    })
                    .disposed(by: disposeBag)
            } else {
                newState.commentData.likeCount -= 1
                userAPIUseCase.deleteCommentLike(commentId: newState.commentData.commentID)
                    .subscribe(onDisposed: {
                        Logger.log("CommentLikeDelete", category: .info)
                    })
                    .disposed(by: disposeBag)
            }
            newState.sections = getSection()
        }

        return newState
    }

    func getSection() -> [any Sectionable] {
        if imageSection.isEmpty {
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
