//
//  SearchReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/4/24.
//

import UIKit

import ReactorKit
import RxSwift
import RxCocoa

final class SearchReactor: Reactor {
    
    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case returnSearchKeyword(text: String?)
        case recentSearchListDeleteButtonTapped(indexPath: IndexPath)
        case recentSearchListAllDeleteButtonTapped
        case cellTapped(indexPath: IndexPath, controller: BaseViewController)
        case sortedButtonTapped(controller: BaseViewController)
        case changeSortedFilterIndex(filterIndex: Int, sortedIndex: Int)
        case changeCategory(categoryList: [Int64], categoryTitleList: [String?])
        case categoryDelteButtonTapped(indexPath: IndexPath)
        case resetCategory
        case changePage
        case bookmarkButtonTapped(indexPath: IndexPath)
        case resetSearchKeyWord
    }
    
    enum Mutation {
        case loadView
        case moveToCategoryScene(controller: BaseViewController)
        case moveToSortedScene(controller: BaseViewController)
        case moveToDetailScene(controller: BaseViewController, indexPath: IndexPath)
        case setSearchKeyWord(text: String?)
        case resetSearchKeyWord
    }
    
    struct State {
        var sections: [any Sectionable] = []
        var searchKeyWord: String?
    }
    
    // MARK: - properties
    
    var initialState: State
    var disposeBag = DisposeBag()
    
    private var sortedIndex: Int = 1
    private var filterIndex: Int = 0
    
    private var currentPage: Int32 = 0
    private var lastAppendPage: Int32 = 0
    private var lastPage: Int32 = 0
    private var isLoading: Bool = false
    
    private let userDefaultService = UserDefaultService()
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
    
    private let recentKeywordTitleSection = SearchTitleSection(inputDataList: [.init(title: "최근 검색어", buttonTitle: "모두삭제")])
    private var recentKeywordSection = CancelableTagSection(inputDataList: [])
    
    private let searchTitleSection = SearchTitleSection(inputDataList: [.init(title: "팝업스토어 찾기")])
    private var searchCategorySection = CancelableTagSection(inputDataList: [
        .init(title: "카테고리", isSelected: false, isCancelAble: false)
    ])
    private var searchListSection = HomeCardGridSection(inputDataList: [])
    private var searchSortedSection = SearchCountTitleSection(inputDataList: [])
    private let spacing24Section = SpacingSection(inputDataList: [.init(spacing: 24)])
    private let spacing16Section = SpacingSection(inputDataList: [.init(spacing: 16)])
    private let spacing18Section = SpacingSection(inputDataList: [.init(spacing: 18)])
    private let spacing48Section = SpacingSection(inputDataList: [.init(spacing: 48)])
    private let spacing64Section = SpacingSection(inputDataList: [.init(spacing: 64)])
    
    // MARK: - init
    init() {
        self.initialState = State()
    }
    
    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        let sort = sortedIndex == 0 ? "NEWEST" : "MOST_VIEWED,MOST_COMMENTED,MOST_BOOKMARKED"
        switch action {
        case .resetSearchKeyWord:
            return Observable.just(.resetSearchKeyWord)
        case .changePage:
            if isLoading {
                return Observable.just(.loadView)
            } else {
                if currentPage < lastPage {
                    isLoading = true
                    currentPage += 1
                    return setBottomSearchList(sort: sort)
                } else {
                    return Observable.just(.loadView)
                }
            }
        case .viewWillAppear:
            setSearchList()
            return setBottomSearchList(sort: sort)
        case .returnSearchKeyword(let text):
            appendSearchList(text: text)
            return Observable.just(.loadView)
        case .recentSearchListDeleteButtonTapped(let indexPath):
            removeSearchList(indexPath: indexPath)
            return Observable.just(.loadView)
        case .recentSearchListAllDeleteButtonTapped:
            resetSearchList()
            return Observable.just(.loadView)
        case .cellTapped(let indexPath, let controller):
            let searchList = userDefaultService.fetchArray(key: "searchList") ?? []
            let section = searchList.isEmpty ? indexPath.section + 4 : indexPath.section
            switch section {
            case 3:
                let text = recentKeywordSection.inputDataList[indexPath.row].title
                appendSearchList(text: text)
                return Observable.just(.setSearchKeyWord(text: text))
            case 7:
                return Observable.just(.moveToCategoryScene(controller: controller))
            case 11:
                return Observable.just(.moveToDetailScene(controller: controller, indexPath: indexPath))
            default:
                return Observable.just(.loadView)
            }
        case .sortedButtonTapped(let controller):
            return Observable.just(.moveToSortedScene(controller: controller))
        case .changeSortedFilterIndex(let filterIndex, let sortedIndex):
            self.sortedIndex = sortedIndex
            self.filterIndex = filterIndex
            self.currentPage = 0
            self.lastAppendPage = 0
            return Observable.just(.loadView)
        case .changeCategory(let categoryList, let categoryTitleList):
            self.currentPage = 0
            self.lastAppendPage = 0
            let datas = zip(categoryList, categoryTitleList)
            searchCategorySection.inputDataList = datas.map { return .init(title: $0.1, id: $0.0, isSelected: true, isCancelAble: true)}
            return Observable.just(.loadView)
        case .resetCategory:
            self.currentPage = 0
            self.lastAppendPage = 0
            searchCategorySection.inputDataList = [.init(title: "카테고리", isSelected: false, isCancelAble: false)]
            return Observable.just(.loadView)
        case .categoryDelteButtonTapped(let indexPath):
            self.currentPage = 0
            self.lastAppendPage = 0
            searchCategorySection.inputDataList.remove(at: indexPath.row)
            if searchCategorySection.inputDataList.isEmpty { searchCategorySection.inputDataList = [.init(title: "카테고리", isSelected: false, isCancelAble: false)] }
            return setBottomSearchList(sort: sort)
        case .bookmarkButtonTapped(let indexPath):
            let data = searchListSection.inputDataList[indexPath.row]
            let isBookmark = data.isBookmark
            let id = data.id
            searchListSection.inputDataList[indexPath.row].isBookmark.toggle()
            if isBookmark {
                return userAPIUseCase.deleteBookmarkPopUp(popUpID: id)
                    .andThen(Observable.just(.loadView))
            } else {
                return userAPIUseCase.postBookmarkPopUp(popUpID: id)
                    .andThen(Observable.just(.loadView))
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .loadView:
            newState.sections = getSection()
        case .moveToCategoryScene(let controller):
            let categoryIDList = searchCategorySection.inputDataList.compactMap { $0.id }
            let nextController = SearchCategoryController()
            nextController.reactor = SearchCategoryReactor(originCategoryList: categoryIDList)
            controller.presentPanModal(nextController)
            nextController.reactor?.state
                .withUnretained(self)
                .subscribe(onNext: { (owner, state) in
                    if state.isSave {
                        if state.categoryTitleList.isEmpty {
                            owner.searchCategorySection.inputDataList = [.init(title: "카테고리", isSelected: false, isCancelAble: false)]
                        } else {
                            owner.action.onNext(.changeCategory(categoryList: state.categoryIDList, categoryTitleList: state.categoryTitleList))
                        }
                        
                    }
                    if state.isReset { owner.action.onNext(.resetCategory)}
                })
                .disposed(by: nextController.disposeBag)
        case .moveToSortedScene(let controller):
            let nextController = SearchSortedController()
            nextController.reactor = SearchSortedReactor(filterIndex: filterIndex, sortedIndex: sortedIndex)
            controller.presentPanModal(nextController)
            nextController.reactor?.state
                .withUnretained(self)
                .subscribe(onNext: { (owner, state) in
                    if state.isSave {
                        ToastMaker.createToast(message: "선택하신 옵션을 저장했어요")
                        owner.action.onNext(.changeSortedFilterIndex(filterIndex: state.filterIndex, sortedIndex: state.sortedIndex))
                    }
                })
                .disposed(by: nextController.disposeBag)
        case .moveToDetailScene(let controller, let indexPath):
            let nextController = DetailController()
            nextController.reactor = DetailReactor(popUpID: searchListSection.inputDataList[indexPath.row].id)
            controller.navigationController?.pushViewController(nextController, animated: true)
        case .setSearchKeyWord(let text):
            newState.searchKeyWord = text
        case .resetSearchKeyWord:
            newState.searchKeyWord = nil
            newState.sections = getSection()
        }
        return newState
    }
    
    func getSection() -> [any Sectionable] {
        let searchList = userDefaultService.fetchArray(key: "searchList") ?? []
        if searchList.isEmpty {
            return [
                spacing24Section,
                searchTitleSection,
                spacing16Section,
                searchCategorySection,
                spacing18Section,
                searchSortedSection,
                spacing16Section,
                searchListSection,
                spacing64Section
            ]
        } else {
            return [
                spacing24Section,
                recentKeywordTitleSection,
                spacing16Section,
                recentKeywordSection,
                spacing48Section,
                searchTitleSection,
                spacing16Section,
                searchCategorySection,
                spacing18Section,
                searchSortedSection,
                spacing16Section,
                searchListSection,
                spacing64Section
            ]
        }
    }
    
    func setSearchList() {
        let searchList = userDefaultService.fetchArray(key: "searchList") ?? []
        recentKeywordSection.inputDataList = searchList.map { return .init(title: $0) }
    }
    
    func appendSearchList(text: String?) {
        if let text = text {
            if !text.isEmpty {
                var searchList = userDefaultService.fetchArray(key: "searchList") ?? []
                if searchList.contains(text) {
                    let targetIndex = searchList.firstIndex(of: text)!
                    searchList.remove(at: targetIndex)   
                }
                searchList = [text] + searchList
                userDefaultService.save(key: "searchList", value: searchList)
                recentKeywordSection.inputDataList = searchList.map { return .init(title: $0) }
            }
        }
    }
    
    func removeSearchList(indexPath: IndexPath) {
        var searchList = userDefaultService.fetchArray(key: "searchList") ?? []
        searchList.remove(at: indexPath.row)
        userDefaultService.save(key: "searchList", value: searchList)
        recentKeywordSection.inputDataList = searchList.map { return .init(title: $0) }
    }
    
    func resetSearchList() {
        userDefaultService.save(key: "searchList", value: [])
        recentKeywordSection.inputDataList = []
    }
    
    func setBottomSearchList(sort: String?) -> Observable<Mutation> {
        let isOpen = filterIndex == 0 ? true : false
        let categorys = searchCategorySection.inputDataList.compactMap { $0.id }
        return popUpAPIUseCase.getSearchBottomPopUpList(isOpen: isOpen, categories: categorys, page: currentPage, size: 50, sort: sort)
            .withUnretained(self)
            .map { (owner, response) in
                let isLogin = response.loginYn
                if owner.currentPage == 0 {
                    owner.searchListSection.inputDataList = response.popUpStoreList.map {
                        return .init(
                            imagePath: $0.mainImageUrl,
                            id: $0.id,
                            category: $0.category,
                            title: $0.name,
                            address: $0.address,
                            startDate: $0.startDate,
                            endDate: $0.endDate,
                            isBookmark: $0.bookmarkYn,
                            isLogin: isLogin
                        )
                    }
                } else {
                    if owner.currentPage != owner.lastAppendPage {
                        owner.lastAppendPage = owner.currentPage
                        let newData = response.popUpStoreList.map {
                            return HomeCardSectionCell.Input(
                                imagePath: $0.mainImageUrl,
                                id: $0.id,
                                category: $0.category,
                                title: $0.name,
                                address: $0.address,
                                startDate: $0.startDate,
                                endDate: $0.endDate,
                                isBookmark: $0.bookmarkYn,
                                isLogin: isLogin
                            )
                        }
                        owner.searchListSection.inputDataList.append(contentsOf: newData)
                    }
                }
                let isOpenString = isOpen ? "오픈・" : "종료・"
                let sortedString = owner.sortedIndex == 0 ? "신규순" : "인기순"
                let sortedTitle = isOpenString + sortedString
                owner.searchSortedSection.inputDataList = [.init(count: response.totalElements, sortedTitle: sortedTitle)]
                owner.lastPage = response.totalPages
                owner.isLoading = false
                return .loadView
            }
    }
}
