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

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension MapPopUpStore {
    func toMarkerInput() -> MapMarker.Input {
        return .init(
            title: self.markerTitle,
            count: 1  // 클러스터링 구현 시 수정
        )
    }
//
//    func toCardInput() -> MapPopupCarouselView.Input {
//        return .init(
//            image: nil,  
//            category: self.category,
//            title: self.name,
//            location: self.address,
//            date: "\(self.startDate) - \(self.endDate)"
//        )
//    }
}
