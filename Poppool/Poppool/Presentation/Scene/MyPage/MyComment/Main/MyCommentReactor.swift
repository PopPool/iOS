//
//  MyCommentReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/8/25.
//

import UIKit

import ReactorKit
import RxSwift
import RxCocoa

final class MyCommentReactor: Reactor {
    
    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case changePage
        case listTapped(controller: BaseViewController, row: Int)
        case sortButtonTapped(controller: BaseViewController)
        case backButtonTapped(controller: BaseViewController)
    }
    
    enum Mutation {
        case loadView
        case skip
        case moveToDetailScene(controller: BaseViewController, row: Int)
        case presentSortModal(controller: BaseViewController)
        case moveToRecentScene(controller: BaseViewController)
    }
    
    struct State {
        var sections: [any Sectionable] = []
        var isReloadView: Bool = false
    }
    
    // MARK: - properties
    
    var initialState: State
    var disposeBag = DisposeBag()
    private var isLoading: Bool = false
    private var totalPage: Int32 = 0
    private var currentPage: Int32 = 0
    private var size: Int32 = 10
    private var sortCode: String = "NEWEST"
    
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
    
    private var listCountSection = ListCountButtonSection(inputDataList: [])
    private var listSection = OtherUserCommentSection(inputDataList: [])
    private var spacing16Section = SpacingSection(inputDataList: [.init(spacing: 16)])
    private var spacing64Section = SpacingSection(inputDataList: [.init(spacing: 64)])
    
    // MARK: - init
    init() {
        self.initialState = State()
    }
    
    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            if listSection.isEmpty {
                return userAPIUseCase.getMyComment(commentType: "NORMAL", sortCode: sortCode, page: currentPage, size: size, sort: nil)
                    .withUnretained(self)
                    .map { (owner, response) in
                        owner.listCountSection.inputDataList = [.init(count: response.totalElements, buttonTitle: owner.sortCode == "NEWEST" ? "최신순" : "반응순")]
                        owner.listSection.inputDataList = response.commentList.map { .init(
                            imagePath: $0.popUpStoreInfo.mainImageUrl,
                            likeCount: $0.likeCount,
                            title: $0.popUpStoreInfo.popUpStoreName,
                            comment: $0.content,
                            date: $0.createDateTime,
                            popUpID: $0.popUpStoreInfo.popUpStoreId)
                        }
                        return .loadView
                    }
            } else {
                return Observable.just(.skip)
            }
        case .changePage:
            if isLoading {
                return Observable.just(.skip)
            } else {
                if currentPage <= totalPage {
                    isLoading = true
                    currentPage += 1
                    return userAPIUseCase.getMyComment(commentType: "NORMAL", sortCode: sortCode, page: currentPage, size: size, sort: nil)
                        .withUnretained(self)
                        .map { (owner, response) in
                            owner.listCountSection.inputDataList = [.init(count: response.totalElements, buttonTitle: owner.sortCode == "NEWEST" ? "최신순" : "반응순")]
                            owner.listSection.inputDataList.append(contentsOf: response.commentList.map { .init(
                                imagePath: $0.popUpStoreInfo.mainImageUrl,
                                likeCount: $0.likeCount,
                                title: $0.popUpStoreInfo.popUpStoreName,
                                comment: $0.content,
                                date: $0.createDateTime,
                                popUpID: $0.popUpStoreInfo.popUpStoreId)
                            })
                            return .loadView
                        }
                } else {
                    return Observable.just(.skip)
                }
            }
        case .listTapped(let controller, let row):
            return Observable.just(.moveToDetailScene(controller: controller, row: row))
        case .sortButtonTapped(let controller):
            return Observable.just(.presentSortModal(controller: controller))
        case .backButtonTapped(let controller):
            return Observable.just(.moveToRecentScene(controller: controller))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.isReloadView = false
        switch mutation {
        case .loadView:
            newState.isReloadView = true
            newState.sections = getSection()
        case .skip:
            break
        case .moveToDetailScene(let controller, let row):
            let popUpID = listSection.inputDataList[row].popUpID
            let nextController = DetailController()
            nextController.reactor = DetailReactor(popUpID: popUpID)
            controller.navigationController?.pushViewController(nextController, animated: true)
        case .presentSortModal(let controller):
            let nextController = MyCommentSortedModalController()
            nextController.reactor = MyCommentSortedModalReactor(sortedCode: sortCode)
            nextController.reactor?.state
                .withUnretained(self)
                .subscribe(onNext: { (owner, state) in
                    if state.isSave {
                        owner.listSection.inputDataList = []
                        owner.sortCode = state.currentSortedCode ?? ""
                        owner.currentPage = 0
                        ToastMaker.createToast(message: "보기 옵션이 반영되었어요")
                    }
                })
                .disposed(by: nextController.disposeBag)
            controller.presentPanModal(nextController)
        case .moveToRecentScene(let controller):
            controller.navigationController?.popViewController(animated: true)
        }
        return newState
    }
    
    func getSection() -> [any Sectionable] {
        return [
            spacing16Section,
            listCountSection,
            spacing16Section,
            listSection,
            spacing64Section
        ]
    }
}
