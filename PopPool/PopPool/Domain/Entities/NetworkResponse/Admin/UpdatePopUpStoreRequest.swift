//
//  UpdatePopUpStoreRequest.swift
//  PopPool
//
//  Created by Porori on 8/27/24.
//

import Foundation

struct UpdatePopUpStoreRequest {
    let popUpStore: [PopUpStore]
    let location: Location
    let imagesToAdd: [String]
    let imagesToDelete: [Int64]
}
