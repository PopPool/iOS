import Foundation

import RxSwift

protocol AuthAPIUseCase {
    func postTryLogin(userCredential: Encodable, socialType: String) -> Observable<LoginResponse>
    func postTokenReissue() -> Observable<PostTokenReissueResponse>
}
