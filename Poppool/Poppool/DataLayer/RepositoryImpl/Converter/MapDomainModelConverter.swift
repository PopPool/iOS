import Foundation

struct MapDomainModelConverter {
    /// MapPopUpStoreDTO
    /// → MapPopUpStore 도메인 모델로 변환
    static func convert(_ dto: MapPopUpStoreDTO) -> MapPopUpStore {
        return MapPopUpStore(
            id: dto.id,
            category: dto.categoryName,
            name: dto.name,
            address: dto.address,
            startDate: dto.startDate,
            endDate: dto.endDate,
            latitude: dto.latitude,
            longitude: dto.longitude,
            markerId: dto.markerId,
            markerTitle: dto.markerTitle,
            markerSnippet: dto.markerSnippet,
            mainImageUrl: dto.mainImageUrl
        )
    }
}
