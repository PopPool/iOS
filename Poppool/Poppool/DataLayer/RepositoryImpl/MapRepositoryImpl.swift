import Foundation

import RxSwift

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
    ) -> Observable<[MapPopUpStore]> {
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
        .map { $0.popUpStoreList.map(MapDomainModelConverter.convert) }
    }

    func searchStores(
        query: String,
        categories: [Int64]
    ) -> Observable<[MapPopUpStore]> {
        return provider.requestData(
            with: MapAPIEndpoint.locations_searchStores(
                query: query,
                categories: categories
            ),
            interceptor: TokenInterceptor()
        )
        .map { $0.popUpStoreList.map(MapDomainModelConverter.convert) }
    }

    func fetchCategories() -> Observable<[CategoryResponse]> {
        Logger.log(message: "카테고리 목록 요청을 시작합니다.", category: .network)

        return provider.requestData(
            with: SignUpAPIEndpoint.signUp_getCategoryList(),
            interceptor: TokenInterceptor()
        )
        .do(onNext: { responseDTO in
            Logger.log(
                message: "카테고리 목록 응답 성공",
                category: .debug
            )
        })
        .map { responseDTO in
            responseDTO.categoryResponseList.map { $0.toDomain() }
        }
        .catch { error in
            Logger.log(
                message: "카테고리 목록 요청 실패: \(error.localizedDescription)",
                category: .error
            )
            throw error
        }
    }
}
