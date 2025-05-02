import DomainInterface
import Infrastructure

import ReactorKit
import RxCocoa
import RxSwift

final class AdminReactor: Reactor {

    enum Action {
        case viewDidLoad
        case updateSearchQuery(String)
        case tapRegisterButton
        case tapEditButton(Int64)
        case resetNavigation
        case reloadData
    }

    enum Mutation {
        case setStores([AdminStore])
        case setIsLoading(Bool)
        case navigateToRegister(Bool)
        case navigateToEdit(AdminStore) // ✅ 수정 데이터 추가

    }

    struct State {
        var storeList: [AdminStore] = []
        var isLoading: Bool = false
        var shouldNavigateToRegister: Bool = false
        var selectedStoreForEdit: AdminStore? // ✅ 추가

    }

    var initialState: State
    var disposeBag = DisposeBag()
    private let adminUseCase: AdminUseCase

    init(adminUseCase: AdminUseCase) {
        self.adminUseCase = adminUseCase
        self.initialState = State()
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad, .reloadData:
            return .concat([
                .just(.setIsLoading(true)),
                adminUseCase.fetchStoreList(query: nil, page: 0, size: 100)
                    .map { .setStores($0) }, // ✅ nil 방지
                .just(.setIsLoading(false))
            ])

        case let .updateSearchQuery(query):
            return .concat([
                .just(.setIsLoading(true)),
                adminUseCase.fetchStoreList(query: query, page: 0, size: 100)
                    .do(onNext: { response in
                        Logger.log("조회 성공 - 응답 데이터: \(response)", category: .info)
                    }, onError: { error in
                        Logger.log("조회 실패 - 에러: \(error.localizedDescription)", category: .error)
                    })
                    .map { .setStores($0) },
                .just(.setIsLoading(false))
            ])

        case .tapRegisterButton:
            return .just(.navigateToRegister(true))

        case let .tapEditButton(storeId):
            if let store = currentState.storeList.first(where: { $0.id == storeId }) {
                return .just(.navigateToEdit(store))
            } else {
                return .empty() // 데이터 없으면 아무 동작 안 함
            }
        case .resetNavigation:
            return .just(.navigateToRegister(false))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setStores(stores):
            newState.storeList = stores

        case let .setIsLoading(isLoading):
            newState.isLoading = isLoading

        case let .navigateToRegister(shouldGo):
            newState.shouldNavigateToRegister = shouldGo
        case let .navigateToEdit(store):
            newState.selectedStoreForEdit = store // ✅ 수정할 데이터를 상태에 저장
        }
        return newState
    }
}
