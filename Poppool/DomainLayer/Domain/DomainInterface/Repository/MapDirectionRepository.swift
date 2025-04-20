import Foundation

import RxSwift

public protocol MapDirectionRepository {
    func getPopUpDirection(popUpStoreId: Int64) -> Observable<GetPopUpDirectionResponseDTO>
}
