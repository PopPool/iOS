import Foundation

import DomainInterface

import RxSwift

public final class HomeAPIUseCaseImpl: HomeAPIUseCase {

    private let repository: HomeAPIRepository

    public init(repository: HomeAPIRepository) {
        self.repository = repository
    }

    public func fetchHome(
        page: Int32?,
        size: Int32?,
        sort: String?
    ) -> Observable<GetHomeInfoResponse> {
        return repository.fetchHome(page: page, size: size, sort: sort)
    }

    public func fetchCustomPopUp(
        page: Int32?,
        size: Int32?,
        sort: String?
    ) -> Observable<GetHomeInfoResponse> {
        return repository.fetchCustomPopUp(page: page, size: size, sort: sort)
    }

    public func fetchNewPopUp(
        page: Int32?,
        size: Int32?,
        sort: String?
    ) -> Observable<GetHomeInfoResponse> {
        return repository.fetchNewPopUp(page: page, size: size, sort: sort)
    }

    public func fetchPopularPopUp(
        page: Int32?,
        size: Int32?,
        sort: String?
    ) -> Observable<GetHomeInfoResponse> {
        return repository.fetchPopularPopUp(page: page, size: size, sort: sort)
    }
}
