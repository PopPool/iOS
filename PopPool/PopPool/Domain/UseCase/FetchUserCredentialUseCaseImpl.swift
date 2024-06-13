//
//  AuthUseCaseImpl.swift
//  PopPool
//
//  Created by SeoJunYoung on 6/8/24.
//

import Foundation

import RxSwift

final class FetchUserCredentialUseCaseImpl: FetchUserCredentialUseCase {

    var authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func executeFromKakao() -> Observable<KakaoUserCredentialResponse> {
        return authRepository.fetchUserCredentialFromKakao()
    }
    
    func executeFromApple() -> Observable<AppleUserCredentialResponse> {
        return authRepository.fetchUserCredentialFromApple()
    }
}