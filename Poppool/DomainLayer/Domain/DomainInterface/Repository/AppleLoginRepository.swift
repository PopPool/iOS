import Foundation

import RxSwift

public protocol AppleLoginRepository {
    func fetchUserCredential() -> Observable<AuthServiceResponse>
}
