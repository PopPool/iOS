import ReactorKit
import RxSwift
import CoreLocation
import UIKit

final class MapGuideReactor: Reactor {
    // MARK: - Actions
    enum Action {
        case viewDidLoad(Int64)
        case loadMap(CLLocationCoordinate2D)
        case openMapApp(String)
        case closeButtonTapped
        case expandMapView
        case didSelectItem(MapPopUpStore)  // 선택된 스토어 반영 액션
    }

    // MARK: - Mutations
    enum Mutation {
        case setMap(CLLocationCoordinate2D)
        case showToast(String)
        case navigateBack
        case expandToFullScreen
        
        case setSearchResult(MapPopUpStore)
        case setSelectedStore(MapPopUpStore) // [추가]

    }

    // MARK: - State
    struct State {
        var destinationCoordinate: CLLocationCoordinate2D?
        var toastMessage: String?
        var isMapExpanded: Bool = false
        var shouldDismiss: Bool = false
        var searchResult: MapPopUpStore?  // 네트워크 요청 결과
        var selectedStore: MapPopUpStore? = nil  // 사용자가 선택한 스토어 [추가]

    }

    let initialState: State

    private let popUpStoreId: Int64
    private let directionRepository: MapDirectionRepository

    // MARK: - Init
    init(
        popUpStoreId: Int64,
        repository: MapDirectionRepository = DefaultMapDirectionRepository(provider: ProviderImpl())
    ) {
        self.popUpStoreId = popUpStoreId
        self.directionRepository = repository
        self.initialState = State()
    }

    // MARK: - Mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .expandMapView:
            return Observable.just(.expandToFullScreen)

        case .loadMap(let coordinate):
            return Observable.just(.setMap(coordinate))

        case .openMapApp(let appType):
            return openMapApp(appType)

        case .closeButtonTapped:
            return Observable.just(.navigateBack)

        case .viewDidLoad(let id):
            return directionRepository.getPopUpDirection(popUpStoreId: id)
                .do(
                    onNext: { response in
                        Logger.log(
                            message: """
                            ✅ [응답]: 요청 성공 - popUpStoreId: \(id)
                            - 위도: \(response.latitude)
                            - 경도: \(response.longitude)
                            - 주소: \(response.address)
                            """,
                            category: .network
                        )
                    },
                    onError: { error in
                        Logger.log(
                            message: "❌ [에러]: 요청 실패 - \(error.localizedDescription)",
                            category: .error
                        )
                    },
                    onSubscribe: {
                        Logger.log(
                            message: "🌎 [네트워크]: 요청 보냄 - popUpStoreId: \(id)",
                            category: .network
                        )
                    }
                )
                .map { response in
                    // 여기서는 네트워크 응답으로부터 MapPopUpStore를 생성합니다.
                    return Mutation.setMap(CLLocationCoordinate2D(latitude: response.latitude, longitude: response.longitude))
                }

        case .didSelectItem(let store):
            return Observable.just(.setSelectedStore(store))
        }
    }

    private func openMapApp(_ appType: String) -> Observable<Mutation> {
        guard let coordinate = currentState.destinationCoordinate else {
            return Observable.just(.showToast("위치 정보를 가져올 수 없습니다."))
        }

        let appInfo: [String: (urlScheme: String, appStoreUrl: String)] = [
            "naver": (
                "nmap://place?lat=\(coordinate.latitude)&lng=\(coordinate.longitude)",
                "https://apps.apple.com/kr/app/id311867728"
            ),
            "kakao": (
                "kakaomap://look?p=\(coordinate.latitude),\(coordinate.longitude)",
                "https://apps.apple.com/kr/app/id304608425"
            ),
            "tmap": (
                "tmap://route?goalname=목적지&goaly=\(coordinate.latitude)&goalx=\(coordinate.longitude)",
                "https://apps.apple.com/kr/app/id431589174"
            )
        ]

        guard let (urlScheme, appStoreUrl) = appInfo[appType] else {
            return Observable.just(.showToast("지원하지 않는 맵 앱입니다."))
        }

        Logger.log(message: "🗺 맵 앱 열기 시도: \(urlScheme)", category: .debug)

        if let url = URL(string: urlScheme) {
            if UIApplication.shared.canOpenURL(url) {
                Logger.log(message: "✅ \(appType) 앱 실행", category: .debug)
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                return Observable.empty()
            } else {
                Logger.log(message: "❌ \(appType) 앱 미설치 - 앱스토어로 이동", category: .debug)
                if let appStoreURL = URL(string: appStoreUrl) {
                    UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
                }
                return Observable.just(.showToast("\(appType) 앱이 설치되어 있지 않아 앱스토어로 이동합니다."))
            }
        }

        return Observable.just(.showToast("앱을 열 수 없습니다."))
    }

    // MARK: - Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setMap(let coordinate):
            newState.destinationCoordinate = coordinate
        case .showToast(let message):
            newState.toastMessage = message
        case .navigateBack:
            newState.shouldDismiss = true
        case .expandToFullScreen:
            newState.isMapExpanded = true
        case .setSearchResult(let store):
            newState.searchResult = store
        case let .setSelectedStore(store):
            newState.searchResult = store
        }



        return newState
    }
}
