import Foundation

import RxSwift

public protocol CategoryRepository {
    func fetchCategoryList() -> Observable<[CategoryResponse]>
}
