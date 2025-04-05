//
//  SignUpAPIUseCaseImpl.swift
//  Poppool
//
//  Created by Porori on 11/25/24.
//

import Foundation
import RxSwift

final class SignUpAPIUseCaseImpl {
    var repository: SignUpRepositoryImpl

    init(repository: SignUpRepositoryImpl) {
        self.repository = repository
    }
    func trySignUp(
        nickName: String,
        gender: String,
        age: Int32,
        socialEmail: String,
        socialType: String,
        interests: [Int64],
        appleAuthorizationCode: String?
    ) -> Completable {
        return repository.trySignUp(
            nickName: nickName,
            gender: gender,
            age: age,
            socialEmail: socialEmail,
            socialType: socialType,
            interests: interests,
            appleAuthorizationCode: appleAuthorizationCode
        )
    }
    func checkNickName(nickName: String) -> Observable<Bool> {
        return repository.checkNickName(nickName: nickName)
    }

    func fetchCategoryList() -> Observable<[Category]> {
        return repository.fetchCategoryList()
    }
}
