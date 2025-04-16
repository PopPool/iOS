import Foundation

import RxSwift

// MARK: - Implementation
final class MapRepositoryImpl: MapRepository {
    
    private let provider: Provider

    init(provider: Provider) {
        self.provider = provider
    }

    func fetchStoresInBounds(
        northEastLat: Double,
        northEastLon: Double,
        southWestLat: Double,
        southWestLon: Double,
        categories: [Int64]
    ) -> Observable<[MapPopUpStoreDTO]> {
        return provider.requestData(
            with: MapAPIEndpoint.locations_fetchStoresInBounds(
                northEastLat: northEastLat,
                northEastLon: northEastLon,
                southWestLat: southWestLat,
                southWestLon: southWestLon,
                categories: categories
            ),
            interceptor: TokenInterceptor()
        )
        .map { $0.popUpStoreList }
    }

    func searchStores(
        query: String,
        categories: [Int64]
    ) -> Observable<[MapPopUpStoreDTO]> {
        return provider.requestData(
            with: MapAPIEndpoint.locations_searchStores(
                query: query,
                categories: categories
            ),
            interceptor: TokenInterceptor()
        )
        .map { $0.popUpStoreList }
    }

    func fetchCategories() -> Observable<[CategoryResponse]> {
        Logger.log(message: "카테고리 매핑 요청을 시작합니다.", category: .network)

        return provider.requestData(
            with: SignUpAPIEndpoint.signUp_getCategoryList(),
            interceptor: TokenInterceptor()
        )
        .do(onNext: { responseDTO in
            Logger.log(
                message: """
                카테고리 매핑 응답:
                - Response: \(responseDTO)
                - categoryResponseList: \(responseDTO.categoryResponseList)
                """,
                category: .debug
            )
        })
        .map { responseDTO in
            let categories = responseDTO.categoryResponseList.map { $0.toDomain() }
            Logger.log(message: "매핑된 카테고리 데이터: \(categories)", category: .debug)
            return categories
        }
        .catch { error in
            Logger.log(
                message: "카테고리 매핑 요청 실패: \(error.localizedDescription)",
                category: .error
            )
            throw error
        }
    }

}
