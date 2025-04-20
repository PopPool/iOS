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
    
    var profileImageUrl: String?
    var nickname: String?
    var email: String?
    var instagramId: String?
    var intro: String?
    var gender: String?
    var age: Int32
    var interestCategoryList: [CategoryResponse]
}
