import Foundation

import DomainInterface

import ReactorKit
import RxCocoa
import RxSwift

final class CategorySelectReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case closeButtonTapped
        case resetButtonTapped
        case saveButtonTapped
        case categoryTagButtonTapped(indexPath: IndexPath)
    }

    enum Mutation {
        case setupCategotyTag(items: [TagModel])
        case dismiss
        case resetCategory
        case saveCategory
        case updateCategoryTagSelection(categoryID: Int)
        case updateSaveButtonEnable
        case updateSelectedCategory
    }

    struct State {
        var categoryItems: [TagModel] = []
        var saveButtonIsEnable: Bool = false
        var selectedCategoryChanged: Bool?

        @Pulse var categoryChanged: Void?
        @Pulse var dismiss: Void?
    }

    // MARK: - properties
    var initialState: State
    var disposeBag = DisposeBag()

    private var originCategoryItems: [TagModel] = []
    private let fetchCategoryListUseCase: FetchCategoryListUseCase

    // MARK: - init
    init(
        fetchCategoryListUseCase: FetchCategoryListUseCase
    ) {
        self.initialState = State()
        self.fetchCategoryListUseCase = fetchCategoryListUseCase
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return fetchCategoryListUseCase.execute()
                .withUnretained(self)
                .map { (_, response) in
                    let items = response.map {
                        return TagModel(title: $0.category, id: $0.categoryId, isCancelable: false)
                    }
                    return .setupCategotyTag(items: items)
                }

        case .closeButtonTapped:
            return .just(.dismiss)

        case .resetButtonTapped:
            return Observable.concat([
                .just(.resetCategory),
                .just(.dismiss),
                .just(.updateSelectedCategory)
            ])

        case .saveButtonTapped:
            return Observable.concat([
                .just(.saveCategory),
                .just(.dismiss),
                .just(.updateSelectedCategory)
            ])

        case .categoryTagButtonTapped(let indexPath):
            guard let categoryID = currentState.categoryItems[indexPath.row].id else { return .empty() }
            return Observable.concat([
                .just(.updateCategoryTagSelection(categoryID: categoryID)),
                .just(.updateSaveButtonEnable)
            ])
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .setupCategotyTag(let items):
            let fetchedItems = items.map {
                if let id = $0.id, Category.shared.contains(id: id) { return $0.selectionToggledItem() } else { return $0 }
            }
            originCategoryItems = fetchedItems
            newState.categoryItems = fetchedItems

        case .dismiss:
            newState.dismiss = ()

        case .resetCategory:
            Category.shared.resetItems()
            newState.categoryChanged = ()

        case .saveCategory:
            Category.shared.items = newState.categoryItems.filter { $0.isSelected == true }
            newState.categoryChanged = ()

        case .updateCategoryTagSelection(let categoryID):
            newState.categoryItems = state.categoryItems.map {
                if $0.id == categoryID { return $0.selectionToggledItem() } else { return $0 }
            }

        case .updateSaveButtonEnable:
            newState.saveButtonIsEnable = (originCategoryItems != newState.categoryItems)

        case .updateSelectedCategory:
            newState.selectedCategoryChanged = (originCategoryItems != newState.categoryItems)
        }

        return newState
    }
}
