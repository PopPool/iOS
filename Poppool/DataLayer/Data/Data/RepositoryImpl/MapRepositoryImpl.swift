import Foundation

import DomainInterface
import Infrastructure

import RxSwift

public final class MapRepositoryImpl: MapRepository {

    private let provider: Provider

    public init(provider: Provider) {
        self.provider = provider
    }

    public func fetchStoresInBounds(
        northEastLat: Double,
        northEastLon: Double,
        southWestLat: Double,
        southWestLon: Double,
        categories: [Int]
    ) -> Observable<[MapPopUpStore]> {
        return provider.requestData(
            with: MapAPIEndpoint.locations_fetchStoresInBounds(
                northEastLat: northEastLat,
                northEastLon: northEastLon,
                southWestLat: southWestLat,
                southWestLon: southWestLon,
                categories: categories.map { Int64($0 ) }
            ),
            interceptor: TokenInterceptor()
        )
        .map { $0.popUpStoreList.map { $0.toDomain() } }
    }

    public func searchStores(
        query: String,
        categories: [Int]
    ) -> Observable<[MapPopUpStore]> {
        return provider.requestData(
            with: MapAPIEndpoint.locations_searchStores(
                query: query,
                categories: categories.map { Int64($0 ) }
            ),
            interceptor: TokenInterceptor()
        )
        .map { $0.popUpStoreList.map { $0.toDomain() } }
    }

    public func fetchCategories() -> Observable<[CategoryResponse]> {
        Logger.log(message: "카테고리 목록 요청을 시작합니다.", category: .network)

        return provider.requestData(
            with: SignUpAPIEndpoint.signUp_getCategoryList(),
            interceptor: TokenInterceptor()
        )
        .do(onNext: { _ in
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
