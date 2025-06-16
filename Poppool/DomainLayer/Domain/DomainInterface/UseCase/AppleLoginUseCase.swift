import Foundation

import RxSwift

public protocol AppleLoginUseCase {
    func fetchUserCredential() -> Observable<AuthServiceResponse>
}
