import Foundation

import RxSwift

public protocol SearchAPIRepository {
    func fetchSearchResult(by query: String) -> Observable<KeywordBasePopupStoreListResponse>
}
