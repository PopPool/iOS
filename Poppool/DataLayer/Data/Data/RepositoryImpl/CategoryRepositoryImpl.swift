import Foundation

import DomainInterface

import RxSwift

public final class CategoryRepositoryImpl: CategoryRepository {

    private let provider: Provider

    public init(provider: Provider) {
        self.provider = provider
    }

    public func fetchCategoryList() -> Observable<[CategoryResponse]> {
        let endPoint = CategoryAPIEndpoint.getCategoryList()
        return provider.requestData(with: endPoint, interceptor: TokenInterceptor()).map { responseDTO in
            return responseDTO.categoryResponseList.map({ $0.toDomain() })
        }
    }
}
