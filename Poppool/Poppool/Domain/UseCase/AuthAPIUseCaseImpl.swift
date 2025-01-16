//
//  AuthAPIUseCaseImpl.swift
//  Poppool
//
//  Created by Porori on 11/25/24.
//

import Foundation
import RxSwift

final class AuthAPIUseCaseImpl {
    
    var repository: AuthAPIRepositoryImpl
    
    init(repository: AuthAPIRepositoryImpl) {
        self.repository = repository
    }
    
    func postTryLogin(userCredential: Encodable, socialType: String) -> Observable<LoginResponse> {
        return repository.tryLogIn(userCredential: userCredential, socialType: socialType)
    }
    
    func postTokenReissue() -> Observable<PostTokenReissueResponse> {
        let endPoint = AuthAPIEndPoint.postTokenReissue()
        return repository.postTokenReissue().map { $0.toDomain() }
    }
}
