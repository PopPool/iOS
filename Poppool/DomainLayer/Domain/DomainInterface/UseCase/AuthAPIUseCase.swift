import Foundation

import RxSwift

public protocol AuthAPIUseCase {
    func postTryLogin(userCredential: Encodable, socialType: String) -> Observable<LoginResponse>
    func postTokenReissue() -> Observable<PostTokenReissueResponse>
}
