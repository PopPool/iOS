import Foundation

import RxSwift

public protocol FetchKeywordBasePopupListUseCase {
    func execute(keyword: String) -> Observable<KeywordBasePopupStoreListResponse>
}
