import Foundation

public struct GetMyProfileResponse {
    public init(profileImageUrl: String? = nil, nickname: String? = nil, email: String? = nil, instagramId: String? = nil, intro: String? = nil, gender: String? = nil, age: Int32, interestCategoryList: [CategoryResponse]) {
        self.profileImageUrl = profileImageUrl
        self.nickname = nickname
        self.email = email
        self.instagramId = instagramId
        self.intro = intro
        self.gender = gender
        self.age = age
        self.interestCategoryList = interestCategoryList
    }

    public var profileImageUrl: String?
    public var nickname: String?
    public var email: String?
    public var instagramId: String?
    public var intro: String?
    public var gender: String?
    public var age: Int32
    public var interestCategoryList: [CategoryResponse]
}
