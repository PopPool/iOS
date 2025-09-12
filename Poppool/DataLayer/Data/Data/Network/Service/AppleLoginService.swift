import DomainInterface
import Infrastructure

import AuthenticationServices
import RxSwift

public final class AppleLoginService: NSObject, AuthServiceable {

    private var authorizationController: ASAuthorizationController?
	private var authServiceResponse = PublishSubject<AuthServiceResponse>()	// 사용자 자격 증명 정보를 방출할 subject

    private func makeAuthController() -> ASAuthorizationController {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

		let controller = ASAuthorizationController(authorizationRequests: [request])
		controller.delegate = self
		controller.presentationContextProvider = self

        return controller
    }

    func fetchUserCredential() -> Observable<AuthServiceResponse> {
        authServiceResponse = PublishSubject<AuthServiceResponse>()
		authorizationController = makeAuthController()
		authorizationController?.performRequests()

        return authServiceResponse
    }
}

extension AppleLoginService: ASAuthorizationControllerPresentationContextProviding,
                                ASAuthorizationControllerDelegate {
    // 인증 컨트롤러의 프레젠테이션 앵커를 반환하는 함수
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes
        let windowSecne = scenes.first as? UIWindowScene
        guard let window = windowSecne?.windows.first else {
            Logger.log(
                "\(#function) UIWindow fetch Fail",
                category: .error
            )
            return UIWindow()
        }
        return window
    }

    // 인증 성공 시 호출되는 함수
    public func authorizationController(
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
            Logger.log("IDToken: \(idToken)", category: .info)
            Logger.log("Auth Code: \(convertAuthorizationCode)", category: .info)
            authServiceResponse.onNext(.init(idToken: idToken, authorizationCode: convertAuthorizationCode))
        default:
            break
        }
    }
    // 인증 실패 시 호출되는 함수
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        Logger.log(
            "AppleLogin Fail",
            category: .error
        )
        authServiceResponse.onError(error)
    }
}
