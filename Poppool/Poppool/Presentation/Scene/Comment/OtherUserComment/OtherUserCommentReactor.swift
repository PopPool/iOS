//
//  OtherUserCommentReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/27/24.
//

import UIKit

import ReactorKit
import RxSwift
import RxCocoa

final class OtherUserCommentReactor: Reactor {
    
    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case backButtonTapped(controller: BaseViewController)
        case changePage
        case cellTapped(controller: BaseViewController, row: Int)
    }
    
    enum Mutation {
        case moveToRecentScene(controller: BaseViewController)
        case loadView
        case appendData
        case skip
        case moveToDetailScene(controller: BaseViewController, row: Int)
    }
    
    struct State {
        var sections: [any Sectionable] = []
        var isReloadView: Bool = false
    }
    
    // MARK: - properties
    
    var initialState: State
    var disposeBag = DisposeBag()
    
    private let commenterID: String?
    private let userAPIUseCase = UserAPIUseCaseImpl(repository: UserAPIRepositoryImpl(provider: ProviderImpl()))
    
    private var isLoading: Bool = false
    private var totalPage: Int32 = 0
    private var currentPage: Int32 = 0
    private var size: Int32 = 10
    
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
    private let spacing16Section = SpacingSection(inputDataList: [.init(spacing: 16)])
    private var countTitleSection = CommentListTitleSection(inputDataList: [])
    private var popUpSection = OtherUserCommentSection(inputDataList: [])
    
    // MARK: - init
    init(commenterID: String?) {
        self.initialState = State()
        self.commenterID = commenterID
    }
    
    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .changePage:
            if isLoading {
                return Observable.just(.skip)
            } else {
                if currentPage <= totalPage {
                    isLoading = true
                    currentPage += 1
                    return userAPIUseCase.getOtherUserCommentList(commenterId: commenterID, commentType: "NORMAL", page: currentPage, size: size, sort: nil)
                        .withUnretained(self)
                        .map { (owner, response) in
                            owner.popUpSection.inputDataList.append(contentsOf: response.commentList.map { .init(
                                imagePath: $0.popUpStoreInfo.mainImageUrl,
                                likeCount: $0.likeCount,
                                title: $0.popUpStoreInfo.popUpStoreName,
                                comment: $0.content,
                                date: $0.createDateTime,
                                popUpID: $0.popUpStoreInfo.popUpStoreId
                            )})
                            return .loadView
                        }
                } else {
                    return Observable.just(.skip)
                }
            }
        case .viewWillAppear:
            if popUpSection.isEmpty {
                return userAPIUseCase.getOtherUserCommentList(commenterId: commenterID, commentType: "NORMAL", page: currentPage, size: size, sort: nil)
                    .withUnretained(self)
                    .map { (owner, response) in
                        owner.countTitleSection.inputDataList = [.init(count: Int(response.totalElements))]
                        owner.popUpSection.inputDataList = response.commentList.map { .init(
                            imagePath: $0.popUpStoreInfo.mainImageUrl,
                            likeCount: $0.likeCount,
                            title: $0.popUpStoreInfo.popUpStoreName,
                            comment: $0.content,
                            date: $0.createDateTime,
                            popUpID: $0.popUpStoreInfo.popUpStoreId
                        )}
                        owner.totalPage = response.totalPages
                        return .loadView
                    }
            } else {
                return Observable.just(.skip)
            }
        case .backButtonTapped(let controller):
            return Observable.just(.moveToRecentScene(controller: controller))
        case .cellTapped(let controller, let row):
            return Observable.just(.moveToDetailScene(controller: controller, row: row))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.isReloadView = false
        switch mutation {
        case .moveToRecentScene(let controller):
            controller.navigationController?.popViewController(animated: true)
        case .loadView:
            newState.isReloadView = true
            newState.sections = getSection()
        case .appendData:
            newState.isReloadView = true
            newState.sections = getSection()
            isLoading = false
        case .skip:
            break
        case .moveToDetailScene(let controller, let row):
            let id = popUpSection.inputDataList[row].popUpID
            let nextController = DetailController()
            nextController.reactor = DetailReactor(popUpID: id)
            controller.navigationController?.pushViewController(nextController, animated: true)
        }
        return newState
    }
    
    func getSection() -> [any Sectionable] {
        return [
            spacing16Section,
            countTitleSection,
            spacing16Section,
            popUpSection
        ]
    }
}
