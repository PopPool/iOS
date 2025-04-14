import Foundation

import RxSwift

protocol SignUpRepository {
    func checkNickName(nickName: String) -> Observable<Bool>
    func fetchCategoryList() -> Observable<[Category]>
    func trySignUp(
        nickName: String,
        gender: String,
        age: Int32,
        socialEmail: String,
        socialType: String,
        interests: [Int64],
        appleAuthorizationCode: String?
    ) -> Completable
}
