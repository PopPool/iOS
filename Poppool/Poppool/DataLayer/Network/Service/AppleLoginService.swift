//
//  AppleLoginService.swift
//  MomsVillage
//
//  Created by SeoJunYoung on 8/20/24.
//

import AuthenticationServices
import RxSwift

final class AppleLoginService: NSObject, AuthServiceable {

    // 사용자 자격 증명 정보를 방출할 subject
    private var authServiceResponse: PublishSubject<AuthServiceResponse> = .init()

    func fetchUserCredential() -> Observable<AuthServiceResponse> {
        performRequest()
        return authServiceResponse
    }

    // Apple 인증 요청을 수행하는 함수
    private func performRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension AppleLoginService: ASAuthorizationControllerPresentationContextProviding,
                                ASAuthorizationControllerDelegate {
    // 인증 컨트롤러의 프레젠테이션 앵커를 반환하는 함수
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes
        let windowSecne = scenes.first as? UIWindowScene
        guard let window = windowSecne?.windows.first else {
            Logger.log(
                message: "\(#function) UIWindow fetch Fail",
                category: .error,
                fileName: #file,
                line: #line
            )
            return UIWindow()
        }
        return window
    }

    // 인증 성공 시 호출되는 함수
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            guard let idToken = appleIDCredential.identityToken else {
                // 토큰이 없는 경우 오류 방출
                authServiceResponse.onError(AuthError.unknownError(description: "AppleLogin Token is Not Found"))
                return
            }
            guard let idToken = String(data: idToken, encoding: .utf8) else {
                // 토큰 convert가 실패할 경우 오류 방출
                authServiceResponse.onError(AuthError.unknownError(description: "AppleLogin Token Convert Fail"))
                return
            }
            guard let authorizationCode = appleIDCredential.authorizationCode else {
                return
            }

            guard let convertAuthorizationCode = String(data: authorizationCode, encoding: .utf8) else {
                return
            }
            Logger.log(message: "IDToken: \(idToken)", category: .info)
            Logger.log(message: "Auth Code: \(convertAuthorizationCode)", category: .info)
            authServiceResponse.onNext(.init(idToken: idToken, authorizationCode: convertAuthorizationCode))
        default:
            break
        }
    }
    // 인증 실패 시 호출되는 함수
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        Logger.log(
            message: "AppleLogin Fail",
            category: .error,
            fileName: #file,
            line: #line
        )
        authServiceResponse.onError(error)
    }
}
