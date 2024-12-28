//
//  SearchResultReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/7/24.
//

import UIKit

import ReactorKit
import RxSwift
import RxCocoa

final class SearchResultReactor: Reactor {
    
    // MARK: - Reactor
    enum Action {
        case returnSearch(text: String)
        case bookmarkButtonTapped(indexPath: IndexPath)
        case cellTapped(controller: BaseViewController, indexPath: IndexPath)
    }
    
    enum Mutation {
        case loadView
        case emptyView
        case moveToDetailScene(controller: BaseViewController, indexPath: IndexPath)
    }
    
    struct State {
        var sections: [any Sectionable] = []
        var isEmptyResult: Bool = false
    }
    
    // MARK: - properties
    
    var initialState: State
    var disposeBag = DisposeBag()
    private var popUpAPIUseCase = PopUpAPIUseCaseImpl(repository: PopUpAPIRepositoryImpl(provider: ProviderImpl()))
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
    
    private var titleSection = SearchTitleSection(inputDataList: [.init(title: "포함된 팝업", buttonTitle: nil)])
    private var searchCountSection = SearchResultCountSection(inputDataList: [.init(count: 65)])
    private var searchListSection = HomeCardGridSection(inputDataList: [])
    private let spacing24Section = SpacingSection(inputDataList: [.init(spacing: 24)])
    private let spacing16Section = SpacingSection(inputDataList: [.init(spacing: 16)])
    
    // MARK: - init
    init() {
        self.initialState = State()
    }
    
    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .cellTapped(let controller, let indexPath):
            return Observable.just(.moveToDetailScene(controller: controller, indexPath: indexPath))
        case .returnSearch(let text):
            titleSection.inputDataList = [.init(title: "\(text)이/가 포함된 팝업")]
            return popUpAPIUseCase.getSearchPopUpList(query: text)
                .withUnretained(self)
                .map { (owner, response) in
                    owner.searchCountSection.inputDataList = [.init(count: response.popUpStoreList.count)]
                    let isLogin = response.loginYn
                    owner.searchListSection.inputDataList = response.popUpStoreList.map({ response in
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
                    return .loadView
                }
                .catch { _ in
                    return Observable.just(.emptyView)
                }
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
            newState.isEmptyResult = searchListSection.isEmpty
            newState.sections = getSection()
        case .emptyView:
            newState.isEmptyResult = true
        case .moveToDetailScene(let controller, let indexPath):
            let nextController = BaseViewController()
            controller.navigationController?.pushViewController(nextController, animated: true)
        }
        return newState
    }
    
    
    func getSection() -> [any Sectionable] {
        return [
            spacing24Section,
            titleSection,
            searchCountSection,
            spacing16Section,
            searchListSection
        ]
    }
}
