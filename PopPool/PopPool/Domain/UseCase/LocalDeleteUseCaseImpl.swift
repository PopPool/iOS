//
//  LocalDeleteUseCaseImpl.swift
//  PopPool
//
//  Created by Porori on 6/20/24.
//

import Foundation
import RxSwift

final class LocalDeleteUseCaseImpl: LocalDeleteUseCase {
    var repository: LocalDBRepository
    
    init(repository: LocalDBRepository) {
        self.repository = repository
    }
    
    func delete(key: String, from database: String) -> Completable {
        repository.delete(key: key, from: database)
    }
}
