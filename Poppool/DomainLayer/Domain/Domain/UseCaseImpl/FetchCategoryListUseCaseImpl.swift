import Foundation

import DomainInterface

import RxSwift

public final class FetchCategoryListUseCaseImpl: FetchCategoryListUseCase {

    private let repository: CategoryRepository

    public init(repository: CategoryRepository) {
        self.repository = repository
    }

    public func execute() -> Observable<[CategoryResponse]> {
        return repository.fetchCategoryList()
    }
}
