import ReactorKit
import RxSwift
import RxCocoa
import UIKit

final class StoreListReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case viewDidLoad
        case didSelectItem(Int)
        case toggleBookmark(Int)
        case didDragSheet(CGFloat)
    }

    enum Mutation {
        case setStores([StoreItem])
        case updateBookmark(Int)
        case updateSheetHeight(CGFloat)
    }

    struct State {
        var stores: [StoreItem] = []
        var sheetHeight: CGFloat = UIScreen.main.bounds.height * 0.75
    }

    // MARK: - Properties
    let initialState: State

    // MARK: - Init
    init() {
        self.initialState = State()
    }

    // MARK: - Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return fetchStores()

        case .didSelectItem(let index):
            // TODO: 아이템 선택 처리
            return .empty()

        case .toggleBookmark(let index):
            return .just(.updateBookmark(index))

        case .didDragSheet(let height):
            return .just(.updateSheetHeight(height))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .setStores(let stores):
            newState.stores = stores

        case .updateBookmark(let index):
            // TODO: 북마크 상태 업데이트
            break

        case .updateSheetHeight(let height):
            newState.sheetHeight = height
        }

        return newState
    }

    private func fetchStores() -> Observable<Mutation> {
        let mockStores: [StoreItem] = [
            StoreItem(
                id: 1,
                thumbnailURL: "",
                category: "카페",
                title: "팝업스토어명 최대 22까지",
                location: "서울 강남구",
                dateRange: "2024. 06. 30 ~ 2024. 08. 23",
                isBookmarked: false
            ),
            StoreItem(
                id: 2,
                thumbnailURL: "",
                category: "전시",
                title: "두 번째 팝업스토어",
                location: "서울 성동구",
                dateRange: "2024. 07. 01 ~ 2024. 07. 30",
                isBookmarked: true
            ),
            StoreItem(
                id: 3,
                thumbnailURL: "",
                category: "카페",
                title: "팝업스토어명 최대 22까지",
                location: "서울 강남구",
                dateRange: "2024. 06. 30 ~ 2024. 08. 23",
                isBookmarked: false
            ),
            StoreItem(
                id: 4,
                thumbnailURL: "",
                category: "전시",
                title: "두 번째 팝업스토어",
                location: "서울 성동구",
                dateRange: "2024. 07. 01 ~ 2024. 07. 30",
                isBookmarked: true
            ),


            ]
        return .just(.setStores(mockStores))
    }
}

// 데이터 모델
struct StoreItem {
    let id: Int
    let thumbnailURL: String
    let category: String
    let title: String
    let location: String
    let dateRange: String
    var isBookmarked: Bool
}
