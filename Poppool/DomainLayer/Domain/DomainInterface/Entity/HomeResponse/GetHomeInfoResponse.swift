import Foundation

public struct GetHomeInfoResponse {
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
