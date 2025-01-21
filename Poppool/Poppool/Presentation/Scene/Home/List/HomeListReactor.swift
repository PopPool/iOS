//
//  HomeListReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/2/24.
//

import UIKit

import ReactorKit
import RxSwift
import RxCocoa

final class HomeListReactor: Reactor {
    
    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case backButtonTapped(controller: BaseViewController)
        case bookMarkButtonTapped(indexPath: IndexPath)
        case changePage
        case cellTapped(controller: BaseViewController, row: Int)
    }
    
    enum Mutation {
        case moveToRecentScene(controller: BaseViewController)
        case loadView
        case reloadView(indexPath: IndexPath)
        case skipAction
        case appendData
        case moveToDetailScene(controller: BaseViewController, row: Int)
    }
    
    struct State {
        var popUpType: HomePopUpType
        var sections: [any Sectionable] = []
        var isReloadView: Bool = false
    }
    
    // MARK: - properties
    
    var initialState: State
    var disposeBag = DisposeBag()
    var popUpType: HomePopUpType
    
    private let homeAPIUseCase = HomeAPIUseCaseImpl()
    private let userDefaultService = UserDefaultService()
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
    private let spacing24Section = SpacingSection(inputDataList: [.init(spacing: 24)])
    private var cardSections = HomeCardGridSection(inputDataList: [])
    
    // MARK: - init
    init(popUpType: HomePopUpType) {
        self.initialState = State(popUpType: popUpType)
        self.popUpType = popUpType
    }
    
    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .changePage:
            if isLoading {
                return Observable.just(.skipAction)
            } else {
                if currentPage <= totalPage {
                    isLoading = true
                    currentPage += 1
                    return homeAPIUseCase.fetchHome(page: currentPage, size: size, sort: "viewCount,desc")
                        .withUnretained(self)
                        .map { (owner, response) in
                            owner.appendSectionData(response: response)
                            return .appendData
                        }
                } else {
                    return Observable.just(.skipAction)
                }
            }
        case .viewWillAppear:
            return homeAPIUseCase.fetchHome(page: currentPage, size: size, sort: "viewCount,desc")
                .withUnretained(self)
                .map { (owner, response) in
                    owner.setSection(response: response)
                    return .loadView
                }
        case .backButtonTapped(let controller):
            return Observable.just(.moveToRecentScene(controller: controller))
        case .bookMarkButtonTapped(let indexPath):
            let popUpData = cardSections.inputDataList[indexPath.row]
            if popUpData.isBookmark {
                return userAPIUseCase.deleteBookmarkPopUp(popUpID: popUpData.id)
                    .andThen(Observable.just(.reloadView(indexPath: indexPath)))
            } else {
                return userAPIUseCase.postBookmarkPopUp(popUpID: popUpData.id)
                    .andThen(Observable.just(.reloadView(indexPath: indexPath)))
            }
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
        case .reloadView(let indexPath):
            newState.isReloadView = true
            cardSections.inputDataList[indexPath.row].isBookmark.toggle()
            newState.sections = getSection()
        case .skipAction:
            newState.isReloadView = false
        case .appendData:
            newState.isReloadView = true
            newState.sections = getSection()
            isLoading = false
        case .moveToDetailScene(let controller, let row):
            let nextController = DetailController()
            nextController.reactor = DetailReactor(popUpID: cardSections.inputDataList[row].id)
            controller.navigationController?.pushViewController(nextController, animated: true)
        }
        return newState
    }
    
    func getSection() -> [any Sectionable] {
        return [spacing24Section,cardSections]
    }
    
    func setSection(response: GetHomeInfoResponse) {
        let isLogin = response.loginYn
        switch popUpType {
        case .curation:
            cardSections.inputDataList = response.customPopUpStoreList.map({ response in
                return .init(
                    imagePath: response.mainImageUrl,
                    id: response.id,
                    category: response.category,
                    title: response.name,
                    address: response.address,
                    startDate: response.startDate,
                    endDate: response.endDate,
                    isBookmark: response.bookmarkYn,
                    isLogin: isLogin
                )
            })
            totalPage = response.customPopUpStoreTotalPages
        case .new:
            cardSections.inputDataList = response.newPopUpStoreList.map({ response in
                return .init(
                    imagePath: response.mainImageUrl,
                    id: response.id,
                    category: response.category,
                    title: response.name,
                    address: response.address,
                    startDate: response.startDate,
                    endDate: response.endDate,
                    isBookmark: response.bookmarkYn,
                    isLogin: isLogin
                )
            })
            totalPage = response.newPopUpStoreTotalPages
        case .popular:
            cardSections.inputDataList = response.popularPopUpStoreList.enumerated().map({ (index, response) in
                return .init(
                    imagePath: response.mainImageUrl,
                    id: response.id,
                    category: response.category,
                    title: response.name,
                    address: response.address,
                    startDate: response.startDate,
                    endDate: response.endDate,
                    isBookmark: response.bookmarkYn,
                    isLogin: isLogin,
                    isPopular: true,
                    row: index
                )
            })
            totalPage = response.popularPopUpStoreTotalPages
        }
    }
    
    func appendSectionData(response: GetHomeInfoResponse) {
        let isLogin = response.loginYn
        switch popUpType {
        case .curation:
            let appendData: [HomeCardSectionCell.Input] = response.customPopUpStoreList.map({ response in
                return .init(
                    imagePath: response.mainImageUrl,
                    id: response.id,
                    category: response.category,
                    title: response.name,
                    address: response.address,
                    startDate: response.startDate,
                    endDate: response.endDate,
                    isBookmark: response.bookmarkYn,
                    isLogin: isLogin
                )
            })
            cardSections.inputDataList.append(contentsOf: appendData)
            totalPage = response.customPopUpStoreTotalPages
        case .new:
            let appendData: [HomeCardSectionCell.Input] = response.newPopUpStoreList.map({ response in
                return .init(
                    imagePath: response.mainImageUrl,
                    id: response.id,
                    category: response.category,
                    title: response.name,
                    address: response.address,
                    startDate: response.startDate,
                    endDate: response.endDate,
                    isBookmark: response.bookmarkYn,
                    isLogin: isLogin
                )
            })
            cardSections.inputDataList.append(contentsOf: appendData)
            totalPage = response.newPopUpStoreTotalPages
        case .popular:
            let appendData: [HomeCardSectionCell.Input] = response.popularPopUpStoreList.enumerated().map({ (index, response) in
                return .init(
                    imagePath: response.mainImageUrl,
                    id: response.id,
                    category: response.category,
                    title: response.name,
                    address: response.address,
                    startDate: response.startDate,
                    endDate: response.endDate,
                    isBookmark: response.bookmarkYn,
                    isLogin: isLogin,
                    isPopular: true,
                    row: index
                )
            })
            cardSections.inputDataList.append(contentsOf: appendData)
            totalPage = response.popularPopUpStoreTotalPages
        }
    }
}
