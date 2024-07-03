//
//  LocalFetchUseCaseImpl.swift
//  PopPool
//
//  Created by Porori on 7/4/24.
//

import Foundation
import RxSwift

final class LocalFetchUseCaseImpl: LocalFetchUseCase {
    
    var repository: LocalDBRepository
    
    init(repository: LocalDBRepository) {
        self.repository = repository
    }
    
    func execute(key: String, from database: String) -> Single<String> {
        repository.fetch(key: key, from: database)
    }
}
