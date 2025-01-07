
import Foundation

// MARK: - Store List Request
struct StoreListRequestDTO: Encodable {
    let query: String?
    let page: Int
    let size: Int

    enum CodingKeys: String, CodingKey {
        case query
        case page = "pageable.page"
        case size = "pageable.size"
    }
}

// MARK: - Create Store Request
struct CreatePopUpStoreRequestDTO: Encodable {
    let name: String
    let categoryId: Int64
    let desc: String
    let address: String
    let startDate: String
    let endDate: String
    let mainImageUrl: String
    let bannerYn: Bool
    let imageUrlList: [String]
    let latitude: Double
    let longitude: Double
    let markerTitle: String
    let markerSnippet: String
    let startDateBeforeEndDate: Bool
}

// MARK: - Update Store Request
struct UpdatePopUpStoreRequestDTO: Encodable {
    let popUpStore: PopUpStore
    let location: Location
    let imagesToAdd: [String]
    let imagesToDelete: [Int64]

    struct PopUpStore: Encodable {
        let id: Int64
        let name: String
        let categoryId: Int64
        let desc: String
        let address: String
        let startDate: String
        let endDate: String
        let mainImageUrl: String
        let bannerYn: Bool
        let imageUrl: [String]
        let startDateBeforeEndDate: Bool
    }

    struct Location: Encodable {
        let latitude: Double
        let longitude: Double
        let markerTitle: String
        let markerSnippet: String
    }
}

// MARK: - Notice Request
struct CreateNoticeRequestDTO: Encodable {
    let title: String
    let content: String
    let imageUrlList: [String]
}

struct UpdateNoticeRequestDTO: Encodable {
    let title: String
    let content: String
    let imageUrlList: [String]
    let imagesToDelete: [Int64]
}
