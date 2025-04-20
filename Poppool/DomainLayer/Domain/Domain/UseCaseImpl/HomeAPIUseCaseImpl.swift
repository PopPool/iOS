import Foundation

import DomainInterface

import RxSwift

public final class HomeAPIUseCaseImpl: HomeAPIUseCase {

    private let repository: HomeAPIRepository

    public init(repository: HomeAPIRepository) {
        self.repository = repository
    }

    func fetchHome(
        page: Int32?,
        size: Int32?,
        sort: String?
    ) -> Observable<GetHomeInfoResponse> {
        return repository.fetchHome(page: page, size: size, sort: sort)
    }

    func fetchCustomPopUp(
        page: Int32?,
        size: Int32?,
        sort: String?
    ) -> Observable<GetHomeInfoResponse> {
        return repository.fetchCustomPopUp(page: page, size: size, sort: sort)
    }

    func fetchNewPopUp(
        page: Int32?,
        size: Int32?,
        sort: String?
    ) -> Observable<GetHomeInfoResponse> {
        return repository.fetchNewPopUp(page: page, size: size, sort: sort)
    }

    func fetchPopularPopUp(
        page: Int32?,
        size: Int32?,
        sort: String?
    ) -> Observable<GetHomeInfoResponse> {
        return repository.fetchPopularPopUp(page: page, size: size, sort: sort)
    }
}
