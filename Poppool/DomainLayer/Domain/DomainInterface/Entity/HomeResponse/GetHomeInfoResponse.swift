import Foundation

public struct GetHomeInfoResponse {
    public init(bannerPopUpStoreList: [BannerPopUpStore], nickname: String? = nil, customPopUpStoreList: [PopUpStoreResponse], customPopUpStoreTotalPages: Int32, customPopUpStoreTotalElements: Int64, popularPopUpStoreList: [PopUpStoreResponse], popularPopUpStoreTotalPages: Int32, popularPopUpStoreTotalElements: Int64, newPopUpStoreList: [PopUpStoreResponse], newPopUpStoreTotalPages: Int32, newPopUpStoreTotalElements: Int64, loginYn: Bool) {
        self.bannerPopUpStoreList = bannerPopUpStoreList
        self.nickname = nickname
        self.customPopUpStoreList = customPopUpStoreList
        self.customPopUpStoreTotalPages = customPopUpStoreTotalPages
        self.customPopUpStoreTotalElements = customPopUpStoreTotalElements
        self.popularPopUpStoreList = popularPopUpStoreList
        self.popularPopUpStoreTotalPages = popularPopUpStoreTotalPages
        self.popularPopUpStoreTotalElements = popularPopUpStoreTotalElements
        self.newPopUpStoreList = newPopUpStoreList
        self.newPopUpStoreTotalPages = newPopUpStoreTotalPages
        self.newPopUpStoreTotalElements = newPopUpStoreTotalElements
        self.loginYn = loginYn
    }

    var bannerPopUpStoreList: [BannerPopUpStore]
    var nickname: String?
    var customPopUpStoreList: [PopUpStoreResponse]
    var customPopUpStoreTotalPages: Int32
    var customPopUpStoreTotalElements: Int64
    var popularPopUpStoreList: [PopUpStoreResponse]
    var popularPopUpStoreTotalPages: Int32
    var popularPopUpStoreTotalElements: Int64
    var newPopUpStoreList: [PopUpStoreResponse]
    var newPopUpStoreTotalPages: Int32
    var newPopUpStoreTotalElements: Int64
    var loginYn: Bool
}
