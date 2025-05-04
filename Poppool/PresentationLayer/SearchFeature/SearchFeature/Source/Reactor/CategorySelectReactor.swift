import Foundation

import DomainInterface

import ReactorKit
import RxCocoa
import RxSwift

final class CategorySelectReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case resetButtonTapped
        case saveButtonTapped
        case cellTapped(categoryID: Int)
    }

    enum Mutation {
        case setupCategotyTag(items: [TagCollectionViewCell.Input])
        case resetCategory
        case saveCategory
        case toggleTappedCell(categoryID: Int)
    }

    struct State {
        var categoryItems: [TagCollectionViewCell.Input] = []
        var saveButtonIsEnable: Bool = false
        var isSaveOrResetButtonTapped: Bool = false
    }

    // MARK: - properties

    var initialState: State
    private var originCategoryItems: [TagCollectionViewCell.Input] = []
    var disposeBag = DisposeBag()

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
                .map { (owner, response) in
                    let items = response.map {
                        return TagCollectionViewCell.Input(
                            title: $0.category,
                            id: $0.categoryId,
                            isCancelable: false
                        )
                    }
                    return .setupCategotyTag(items: items)
                }
            
        case .resetButtonTapped:
            return Observable.just(.resetCategory)

        case .saveButtonTapped:
            return Observable.just(.saveCategory)

        case .cellTapped(let categoryID):
            return Observable.just(.toggleTappedCell(categoryID: categoryID))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .setupCategotyTag(let items):
            let fetchedItems = items.map {
                if let id = $0.id, Category.shared.contains(id: id) {
                    return $0.selectionToggledItem()
                } else { return $0 }
            }

            originCategoryItems = fetchedItems
            newState.categoryItems = fetchedItems

        case .resetCategory:
            Category.shared.resetItems()
            newState.isSaveOrResetButtonTapped = true

        case .saveCategory:
            Category.shared.items = newState.categoryItems.filter { $0.isSelected == true }
            newState.isSaveOrResetButtonTapped = true

        case .toggleTappedCell(let categoryID):
            newState.categoryItems = state.categoryItems.map {
                if $0.id == categoryID { return $0.selectionToggledItem() }
                else { return $0 }
            }
            newState.saveButtonIsEnable = (originCategoryItems != newState.categoryItems)
        }

        return newState
    }
}
