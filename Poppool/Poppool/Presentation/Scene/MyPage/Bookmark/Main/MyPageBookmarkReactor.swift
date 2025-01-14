//
//  MyPageBookmarkReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/14/25.
//

import UIKit

import ReactorKit
import RxSwift
import RxCocoa

final class MyPageBookmarkReactor: Reactor {
    
    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case changePage
        case backButtonTapped(controller: BaseViewController)
        case cellTapped(controller: BaseViewController, row: Int)
        case dropDownButtonTapped(controller: BaseViewController)
        case emptyButtonTapped(controller: BaseViewController)
    }
    
    enum Mutation {
        case loadView
        case skip
        case moveToRecentScene(controller: BaseViewController)
        case moveToDetailScene(controller: BaseViewController, row: Int)
        case presentModal(controller: BaseViewController)
        case moveToSuggestScene(controller: BaseViewController)
    }
    
    struct State {
        var sections: [any Sectionable] = []
        var isReloadView: Bool = false
        var isEmptyCase: Bool = false
    }
    
    // MARK: - properties
    
    var initialState: State
    var disposeBag = DisposeBag()
    private var isLoading: Bool = false
    private var totalPage: Int32 = 0
    private var currentPage: Int32 = 0
    private var size: Int32 = 10
    private var viewType: String = "크게보기"
    
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
    
    private var countSection = ListCountButtonSection(inputDataList: [])
    private var listSection = RecentPopUpSection(inputDataList: [])
    private var cardListSection = PopUpCardSection(inputDataList: [])
    private var spacing12Section = SpacingSection(inputDataList: [.init(spacing: 12)])
    private var spacing16Section = SpacingSection(inputDataList: [.init(spacing: 16)])
    
    // MARK: - init
    init() {
        self.initialState = State()
    }
    
    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            currentPage = 0
            return userAPIUseCase.getBookmarkPopUp(page: currentPage, size: size, sort: nil)
                .withUnretained(self)
                .map { (owner, response) in
                    owner.countSection.inputDataList = [.init(count: Int64(response.totalElements), buttonTitle: owner.viewType)]
                    owner.listSection.inputDataList = response.popUpInfoList.map {
                        .init(imagePath: $0.mainImageUrl,
                              date: $0.endDate,
                              title: $0.popUpStoreName,
                              id: $0.popUpStoreId
                        )
                    }
                    owner.cardListSection.inputDataList = response.popUpInfoList.map {
                        .init(
                            imagePath: $0.mainImageUrl,
                            date: ($0.startDate ?? "") + " - " + ($0.endDate ?? ""),
                            title: $0.popUpStoreName,
                            id: $0.popUpStoreId,
                            address: $0.address
                        )
                    }
                    owner.totalPage = response.totalPages
                    return .loadView
                }
        case .changePage:
            if isLoading {
                return Observable.just(.skip)
            } else {
                if currentPage <= totalPage {
                    isLoading = true
                    currentPage += 1
                    return userAPIUseCase.getBookmarkPopUp(page: currentPage, size: size, sort: nil)
                        .withUnretained(self)
                        .map { (owner, response) in
                            owner.countSection.inputDataList = [.init(count: Int64(response.totalElements), buttonTitle: owner.viewType)]
                            owner.listSection.inputDataList.append(contentsOf: response.popUpInfoList.map {
                                .init(
                                    imagePath: $0.mainImageUrl,
                                    date: $0.endDate,
                                    title: $0.popUpStoreName,
                                    id: $0.popUpStoreId
                                )
                            })
                            owner.cardListSection.inputDataList.append(contentsOf: response.popUpInfoList.map {
                                .init(
                                    imagePath: $0.mainImageUrl,
                                    date: ($0.startDate ?? "") + " - " + ($0.endDate ?? ""),
                                    title: $0.popUpStoreName,
                                    id: $0.popUpStoreId,
                                    address: $0.address
                                )
                            })
                            return .loadView
                        }
                } else {
                    return Observable.just(.skip)
                }
            }
        case .backButtonTapped(let controller):
            return Observable.just(.moveToRecentScene(controller: controller))
        case .cellTapped(let controller, let row):
            return Observable.just(.moveToDetailScene(controller: controller, row: row))
        case .dropDownButtonTapped(let controller):
            return Observable.just(.presentModal(controller: controller))
        case .emptyButtonTapped(let controller):
            return Observable.just(.moveToSuggestScene(controller: controller))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.isReloadView = false
        switch mutation {
        case .loadView:
            newState.isReloadView = true
        case .skip:
            break
        case .moveToRecentScene(let controller):
            controller.navigationController?.popViewController(animated: true)
        case .moveToDetailScene(let controller, let row):
            let nextController = DetailController()
            nextController.reactor = DetailReactor(popUpID: listSection.inputDataList[row].id)
            controller.navigationController?.pushViewController(nextController, animated: true)
        case .presentModal(let controller):
            let nextController = BookMarkPopUpViewTypeModalController()
            nextController.reactor = BookMarkPopUpViewTypeModalReactor(sortedCode: viewType)
            controller.presentPanModal(nextController)
            nextController.reactor?.state
                .withUnretained(self)
                .subscribe(onNext: { (owner, state) in
                    if state.isSave {
                        owner.viewType = state.currentSortedCode ?? ""
                        owner.countSection.inputDataList[0].buttonTitle = state.currentSortedCode ?? ""
                    }
                })
                .disposed(by: nextController.disposeBag)
        case .moveToSuggestScene(let controller):
            let nextController = HomeListController()
            nextController.reactor = HomeListReactor(popUpType: .curation)
            controller.navigationController?.pushViewController(nextController, animated: true)
        }
        newState.sections = getSection()
        newState.isEmptyCase = listSection.isEmpty
        return newState
    }
    
    func getSection() -> [any Sectionable] {
        return [
            spacing16Section,
            countSection,
            spacing16Section,
            spacing12Section,
            viewType == "크게보기" ? cardListSection : listSection
        ]
    }
}
