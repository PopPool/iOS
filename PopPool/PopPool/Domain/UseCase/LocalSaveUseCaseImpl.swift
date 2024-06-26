//
//  LocalSaveUseCaseImpl.swift
//  PopPool
//
//  Created by Porori on 6/19/24.
//

import Foundation
import RxSwift

final class LocalSaveUseCaseImpl: LocalSaveUseCase {
    var repository: LocalDBRepository
    
    init(repository: LocalDBRepository) {
        self.repository = repository
    }
    
    func save(key: String, value: String, to databaseType: String) -> Completable {
        repository.save(key: key, value: value, to: databaseType)
    }
}
