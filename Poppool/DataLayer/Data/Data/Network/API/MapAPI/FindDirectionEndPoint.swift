import Foundation

import Infrastructure

struct FindDirectionEndPoint {
   // MARK: - Direction
   static func fetchDirection(
       popUpStoreId: Int64
   ) -> Endpoint<GetPopUpDirectionResponseDTO> {
       return Endpoint(
           baseURL: Secrets.popPoolBaseURL,
           path: "/popup/\(popUpStoreId)/directions",
           method: .get
       )
   }
}
