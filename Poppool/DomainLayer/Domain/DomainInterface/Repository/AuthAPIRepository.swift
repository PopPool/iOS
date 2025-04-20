import Foundation

import RxSwift

public protocol AuthAPIRepository {
    func tryLogIn(userCredential: Encodable, socialType: String) -> Observable<LoginResponse>
    func postTokenReissue() -> Observable<PostTokenReissueResponse>
}
