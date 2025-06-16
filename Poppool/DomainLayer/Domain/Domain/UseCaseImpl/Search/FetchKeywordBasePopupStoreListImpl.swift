import Foundation

import DomainInterface

import RxSwift

public final class FetchKeywordBasePopupListUseCaseImpl: FetchKeywordBasePopupListUseCase {

    private let repository: SearchAPIRepository

    public init(repository: SearchAPIRepository) {
        self.repository = repository
    }

    public func execute(keyword: String) -> Observable<KeywordBasePopupStoreListResponse> {
        return repository.fetchSearchResult(by: keyword)
    }
}
