//
//  HomeAPIUseCaseImpl.swift
//  Poppool
//
//  Created by Porori on 11/26/24.
//

import Foundation
import RxSwift

final class HomeAPIUseCaseImpl {
    var repository = HomeAPIRepository(provider: ProviderImpl())

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
