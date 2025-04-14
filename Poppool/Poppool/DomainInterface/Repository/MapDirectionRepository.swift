import Foundation

import RxSwift

protocol MapDirectionRepository {
    func getPopUpDirection(popUpStoreId: Int64) -> Observable<GetPopUpDirectionResponseDTO>
}
