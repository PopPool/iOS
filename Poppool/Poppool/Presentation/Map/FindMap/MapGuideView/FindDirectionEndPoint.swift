//
//  FindDirectionEndPoint.swift
//  Poppool
//
//  Created by 김기현 on 1/23/25.
//

import Foundation

struct FindDirectionEndPoint {
   // MARK: - Direction
   static func fetchDirection(
       popUpStoreId: Int64
   ) -> Endpoint<GetPopUpDirectionResponseDTO> {
       return Endpoint(
           baseURL: KeyPath.popPoolBaseURL,
           path: "/popup/\(popUpStoreId)/directions",
           method: .get
       )
   }
}

