import Foundation

// MARK: - Store List Request
struct StoreListRequestDTO: Encodable {
    let query: String?
    let page: Int
    let size: Int

    enum CodingKeys: String, CodingKey {
        case query
        case page
        case size
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
    let imageUrlList: [String?]
    let latitude: Double
    let longitude: Double
    let markerTitle: String
    let markerSnippet: String
    let startDateBeforeEndDate: Bool

    init(name: String,
         categoryId: Int64,
         desc: String,
         address: String,
         startDate: String,
         endDate: String,
         mainImageUrl: String,
         imageUrlList: [String?],
         latitude: Double,
         longitude: Double,
         markerTitle: String,
         markerSnippet: String,
         startDateBeforeEndDate: Bool) {

        self.name = name
        self.categoryId = categoryId
        self.desc = desc
        self.address = address
        self.startDate = startDate
        self.endDate = endDate
        self.mainImageUrl = mainImageUrl
        self.imageUrlList = imageUrlList
        self.latitude = latitude
        self.longitude = longitude
        self.markerTitle = markerTitle
        self.markerSnippet = markerSnippet
        self.startDateBeforeEndDate = startDateBeforeEndDate
        self.bannerYn = !mainImageUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Update Store Request
struct UpdatePopUpStoreRequestDTO: Encodable {
    let popUpStore: PopUpStore
    let location: Location
    let imagesToAdd: [String]
    let imagesToDelete: [Int64]

    // CodingKeys 추가
    private enum CodingKeys: String, CodingKey {
        case popUpStore
        case location
        case imagesToAdd
        case imagesToDelete
    }

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

        // PopUpStore의 CodingKeys도 추가
        private enum CodingKeys: String, CodingKey {
            case id
            case name
            case categoryId
            case desc
            case address
            case startDate
            case endDate
            case mainImageUrl
            case bannerYn
            case imageUrl
            case startDateBeforeEndDate
        }
    }

    struct Location: Encodable {
        let latitude: Double
        let longitude: Double
        let markerTitle: String
        let markerSnippet: String

        // Location의 CodingKeys도 추가
        private enum CodingKeys: String, CodingKey {
            case latitude
            case longitude
            case markerTitle
            case markerSnippet
        }
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
