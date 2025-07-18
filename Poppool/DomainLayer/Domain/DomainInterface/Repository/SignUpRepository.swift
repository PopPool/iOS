import Foundation

import RxSwift

public protocol SignUpRepository {
    func checkNickName(nickName: String) -> Observable<Bool>
    func fetchCategoryList() -> Observable<[CategoryResponse]>
    func trySignUp(
        nickName: String,
        gender: String,
        age: Int32,
        socialEmail: String,
        socialType: String,
        interests: [Int],
        appleAuthorizationCode: String?
    ) -> Completable
}
