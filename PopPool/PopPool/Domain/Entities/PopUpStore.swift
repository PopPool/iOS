//
//  PopUpStore.swift
//  PopPool
//
//  Created by 김기현 on 8/6/24.
//

import CoreLocation

struct PopUpStore {
    let id: String
    let name: String
    let categories: [String] // 여러 카테고리를 가질 수 있도록 배열로 변경
    let location: CLLocationCoordinate2D
    let address: String
    let dateRange: String

    var latitude: CLLocationDegrees {
        return location.latitude
    }

    var longitude: CLLocationDegrees {
        return location.longitude
    }
    
}
