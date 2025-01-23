import ReactorKit
import RxSwift
import CoreLocation
import UIKit

final class MapGuideReactor: Reactor {
    private let popUpStoreId: Int64
    private let directionRepository: MapDirectionRepository

    // MARK: - Actions
    enum Action {
        case viewDidLoad
        case loadMap(CLLocationCoordinate2D)
        case openMapApp(String)
        case closeButtonTapped
        case expandMapView
    }

    // MARK: - Mutations
    enum Mutation {
        case setMap(CLLocationCoordinate2D)
        case showToast(String)
        case navigateBack
        case expandToFullScreen
    }

    // MARK: - State
    struct State {
        var destinationCoordinate: CLLocationCoordinate2D?
        var toastMessage: String?
        var isMapExpanded: Bool = false
        var shouldDismiss: Bool = false
    }

    let initialState: State  // 초기화를 선언에서만 수행

    // MARK: - Init
    init(
        popUpStoreId: Int64,
        repository: MapDirectionRepository = DefaultMapDirectionRepository(
            provider: ProviderImpl()
        )
    ) {
        self.popUpStoreId = popUpStoreId
        self.directionRepository = repository
        self.initialState = State()  // 선언 시 초기화만 수행
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

        case .viewDidLoad:
            return directionRepository.getPopUpDirection(popUpStoreId: self.popUpStoreId)
                .do(
                    onNext: { response in
                        print("✅ [응답]: 요청 성공 - popUpStoreId: \(self.popUpStoreId)")
                        print("   - 위도: \(response.latitude)")
                        print("   - 경도: \(response.longitude)")
                        print("   - 주소: \(response.address)")
                    },
                    onError: { error in
                        print("❌ [에러]: 요청 실패 - \(error.localizedDescription)")
                    },
                    onSubscribe: {
                        print("🌎 [네트워크]: 요청 보냄 - popUpStoreId: \(self.popUpStoreId)")
                    }
                )
                .map { response in
                    let coordinate = CLLocationCoordinate2D(
                        latitude: response.latitude,
                        longitude: response.longitude
                    )
                    return .setMap(coordinate)
                }
        }
    }

    private func openMapApp(_ appType: String) -> Observable<Mutation> {
        let appURLs: [String: String] = [
            "naver": "nmap://search?query=서울특별시 강남구",
            "kakao": "kakaomap://route?sp=37.5665,126.9780&ep=37.5665,126.9780&by=CAR",
            "tmap": "tmap://search?name=서울특별시 강남구"
        ]

        guard let url = URL(string: appURLs[appType] ?? ""),
              UIApplication.shared.canOpenURL(url) else {
            return Observable.just(.showToast("\(appType) 앱이 설치되지 않았습니다."))
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        return Observable.empty()
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
        }

        return newState
    }
}
