//
//  MapDirectionUseCase.swift
//  Poppool
//
//  Created by 김기현 on 1/23/25.
//

import Foundation
import RxSwift

protocol MapDirectionUseCase {
    func getPopUpDirection(popUpStoreId: Int64) -> Observable<GetPopUpDirectionResponse>
}

final class DefaultMapDirectionUseCase: MapDirectionUseCase {
    private let repository: MapDirectionRepository

    init(repository: MapDirectionRepository) {
        self.repository = repository
    }

    func getPopUpDirection(popUpStoreId: Int64) -> Observable<GetPopUpDirectionResponse> {
        return repository.getPopUpDirection(popUpStoreId: popUpStoreId)
            .map { $0.toDomain() }
    }
}
