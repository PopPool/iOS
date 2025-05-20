import Foundation

import RxSwift

public protocol FetchCategoryListUseCase {
    func execute() -> Observable<[CategoryResponse]>
}
