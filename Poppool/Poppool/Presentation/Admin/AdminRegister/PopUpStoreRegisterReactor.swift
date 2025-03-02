import ReactorKit
import RxSwift
import RxCocoa


final class PopUpStoreRegisterReactor: Reactor {

    // MARK: - Action
    enum Action {
        case updateName(String)
        case updateAddress(String)
        case updateLat(String)
        case updateLon(String)
        case updateDescription(String)
        case selectCategory(String)
        case addImage(ExtendedImage)
        case removeImage(Int)
        case tapSave
    }

    // MARK: - Mutation
    enum Mutation {
        case setName(String)
        case setAddress(String)
        case setLat(String)
        case setLon(String)
        case setDescription(String)
        case setCategory(String)
        case addImage(ExtendedImage)
        case removeImage(Int)
        case setSaveEnabled(Bool)
    }

    // MARK: - State
    struct State {
        var name: String = ""
        var address: String = ""
        var lat: String = ""
        var lon: String = ""
        var description: String = ""
        var category: String = ""
        var images: [ExtendedImage] = []
        var isSaveEnabled: Bool = false
    }

    let initialState = State()

    // MARK: - Mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateName(name):
            return .just(.setName(name))
        case let .updateAddress(address):
            return .just(.setAddress(address))
        case let .updateLat(lat):
            return .just(.setLat(lat))
        case let .updateLon(lon):
            return .just(.setLon(lon))
        case let .updateDescription(desc):
            return .just(.setDescription(desc))
        case let .selectCategory(category):
            return .just(.setCategory(category))
        case let .addImage(image):
            return .just(.addImage(image))
        case let .removeImage(index):
            return .just(.removeImage(index))
        case .tapSave:
            // API 호출 등 저장 로직은 여기서 처리하거나 별도 Service로 위임합니다.
            // 이 예제에서는 저장 전 폼 유효성 검증만 진행합니다.
            return .empty()
        }
    }

    // MARK: - Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setName(name):
            newState.name = name
        case let .setAddress(address):
            newState.address = address
        case let .setLat(lat):
            newState.lat = lat
        case let .setLon(lon):
            newState.lon = lon
        case let .setDescription(desc):
            newState.description = desc
        case let .setCategory(category):
            newState.category = category
        case let .addImage(image):
            newState.images.append(image)
        case let .removeImage(index):
            if index < newState.images.count {
                newState.images.remove(at: index)
            }
        case .setSaveEnabled(let enabled):
            newState.isSaveEnabled = enabled
        }

        let isValid = !newState.name.isEmpty &&
                      !newState.address.isEmpty &&
                      !newState.lat.isEmpty &&
                      !newState.lon.isEmpty &&
                      !newState.description.isEmpty &&
                      !newState.category.isEmpty &&
                      !newState.images.isEmpty
        newState.isSaveEnabled = isValid

        return newState
    }
}
