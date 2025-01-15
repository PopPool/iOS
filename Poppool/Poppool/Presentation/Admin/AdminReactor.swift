import ReactorKit
import RxSwift
import RxCocoa

final class AdminReactor: Reactor {

    enum Action {
        case viewDidLoad
        case updateSearchQuery(String)
        case tapRegisterButton
        case tapEditButton(Int64)

        // 화면 이동 후 상태를 초기화하기 위한 액션
        case resetNavigation
    }

    enum Mutation {
        case setStores([GetAdminPopUpStoreListResponseDTO.PopUpStore])
        case setIsLoading(Bool)
        case navigateToRegister(Bool)
    }

    struct State {
        var storeList: [GetAdminPopUpStoreListResponseDTO.PopUpStore] = []
        var isLoading: Bool = false

        // true가 되면 등록 화면 이동
        var shouldNavigateToRegister: Bool = false
    }

    var initialState: State
    var disposeBag = DisposeBag()
    private let useCase: AdminUseCase

    init(useCase: AdminUseCase) {
        self.useCase = useCase
        self.initialState = State()
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .concat([
                .just(.setIsLoading(true)),
                useCase.fetchStoreList(query: nil, page: 0, size: 20)
                    .map { .setStores($0.popUpStoreList) },
                .just(.setIsLoading(false))
            ])

        case let .updateSearchQuery(query):
            return .concat([
                .just(.setIsLoading(true)),
                useCase.fetchStoreList(query: query, page: 0, size: 20)
                    .do(onNext: { response in
                        Logger.log(message: "조회 성공 - 응답 데이터: \(response)", category: .info)
                    }, onError: { error in
                        Logger.log(message: "조회 실패 - 에러: \(error.localizedDescription)", category: .error)
                    })
                    .map { .setStores($0.popUpStoreList) },
                .just(.setIsLoading(false))
            ])


        case .tapRegisterButton:
            // 여기서 State.shouldNavigateToRegister = true 로 변경
            return .just(.navigateToRegister(true))

        case .tapEditButton(_):
            // 편집 화면 이동 등 다른 로직이 있을 수 있으나, 여기서는 생략
            return .empty()

        case .resetNavigation:
            // 화면 이동 후 다시 false로
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
        }
        return newState
    }
}
