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
        var category: Category
        var saveButtonIsEnable: Bool = false
    }

    // MARK: - properties

    var initialState: State
    var disposeBag = DisposeBag()

    let originCategory: Category
    private let fetchCategoryListUseCase: FetchCategoryListUseCase

    // MARK: - init
    init(
        originCategory: Category,
        fetchCategoryListUseCase: FetchCategoryListUseCase
    ) {
        self.initialState = State(category: originCategory.copy() as! Category)
        self.originCategory = originCategory
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
                        let isSelected = owner.originCategory.contains(id: $0.categoryId)
                        return TagCollectionViewCell.Input(
                            title: $0.category,
                            id: $0.categoryId,
                            isSelected: isSelected,
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
            newState.category.items = items

        case .resetCategory:
            newState.category.turnOffAllItemSelection()

        case .saveCategory:
            self.originCategory.items = newState.category.items

        case .toggleTappedCell(let categoryID):
            newState.category.toggleItemSelection(by: categoryID)
        }

        newState.saveButtonIsEnable = (originCategory != newState.category)
        return newState
    }
}
