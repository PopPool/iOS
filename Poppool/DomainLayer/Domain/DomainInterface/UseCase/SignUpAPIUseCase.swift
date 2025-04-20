import Foundation

import RxSwift

public protocol SignUpAPIUseCase {
    func trySignUp(
        nickName: String,
        gender: String,
        age: Int32,
        socialEmail: String,
        socialType: String,
        interests: [Int64],
        appleAuthorizationCode: String?
    ) -> Completable

    func checkNickName(nickName: String) -> Observable<Bool>

    func fetchCategoryList() -> Observable<[CategoryResponse]>
}
