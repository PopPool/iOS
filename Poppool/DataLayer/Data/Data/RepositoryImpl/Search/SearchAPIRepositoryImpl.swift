import Foundation

import DomainInterface
import Infrastructure

import RxSwift

public final class SearchAPIRepositoryImpl: SearchAPIRepository {

    private let provider: Provider
    private let tokenInterceptor = TokenInterceptor()
    private let userDefaultService: UserDefaultService

    public init(
        provider: Provider,
        userDefaultService: UserDefaultService
    ) {
        self.provider = provider
        self.userDefaultService = userDefaultService
    }

    public func fetchSearchResult(by query: String) -> Observable<KeywordBasePopupStoreListResponse> {

        let request = GetSearchPopupStoreRequestDTO(query: query)
        let endPoint = SearchAPIEndPoint.getSearchPopUpList(request: request)
        return provider.requestData(    // 실패했을때는 키워드 저장이 안되도록 수정
            with: endPoint,
            interceptor: tokenInterceptor
        )
        .map { $0.toDomain() }
        .do { _ in self.saveSearchKeyword(keyword: query) }
    }
}

private extension SearchAPIRepositoryImpl {
    func saveSearchKeyword(keyword: String) {
        let existingList = userDefaultService.fetchArray(keyType: .searchKeyword) ?? []
        let updatedList = [keyword] + existingList.filter { $0 != keyword }
        userDefaultService.save(keyType: .searchKeyword, value: updatedList)
    }
}
