import Foundation
import RxSwift

protocol AuthAPIRepository {
    func tryLogIn(userCredential: Encodable, socialType: String) -> Observable<LoginResponse>
    func postTokenReissue() -> Observable<PostTokenReissueResponse>
}
