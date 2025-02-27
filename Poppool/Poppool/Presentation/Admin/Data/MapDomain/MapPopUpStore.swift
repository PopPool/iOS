//
//  MapPopUpStore.swift
//  Poppool
//
//  Created by 김기현 on 12/3/24.
//
import Foundation
import CoreLocation

struct MapPopUpStore: Equatable {
    let id: Int64
    let category: String
    let name: String
    let address: String
    let startDate: String
    let endDate: String
    let latitude: Double
    let longitude: Double
    let markerId: Int64
    let markerTitle: String
    let markerSnippet: String
    let mainImageUrl: String? // 이미지 URL 추가
    

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

    extension MapPopUpStore {
        func toMarkerInput() -> MapMarker.Input {
            return MapMarker.Input(
                isSelected: false,
                isCluster: false,
                regionName: self.markerTitle,  // 또는 name이나 다른 적절한 필드
                count: 0
            )
        }
    


    func toStoreItem() -> StoreItem {
        return StoreItem(
            id: id,
            thumbnailURL: mainImageUrl ?? "", // 이미지 URL 매핑
            category: category,
            title: name,
            location: address,
            dateRange: "\(startDate) ~ \(endDate)",
            isBookmarked: false // 기본값
        )
    }
}
