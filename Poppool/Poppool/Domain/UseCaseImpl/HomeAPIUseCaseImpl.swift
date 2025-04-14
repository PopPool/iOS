import Foundation

import RxSwift

final class HomeAPIUseCaseImpl: HomeAPIUseCase {

    private let repository: HomeAPIRepository

    init(repository: HomeAPIRepository) {
        self.repository = repository
    }

    func fetchHome(
        page: Int32?,
        size: Int32?,
        sort: String?
    ) -> Observable<GetHomeInfoResponse> {
        return repository.fetchHome(request: .init(page: page, size: size, sort: sort))
    }

    func fetchCustomPopUp(
        page: Int32?,
        size: Int32?,
        sort: String?
    ) -> Observable<GetHomeInfoResponse> {
        return repository.fetchCustomPopUp(request: .init(page: page, size: size, sort: sort))
    }

    func fetchNewPopUp(
        page: Int32?,
        size: Int32?,
        sort: String?
    ) -> Observable<GetHomeInfoResponse> {
        return repository.fetchNewPopUp(request: .init(page: page, size: size, sort: sort))
    }

    func fetchPopularPopUp(
        page: Int32?,
        size: Int32?,
        sort: String?
    ) -> Observable<GetHomeInfoResponse> {
        return repository.fetchPopularPopUp(request: .init(page: page, size: size, sort: sort))
    }
}
