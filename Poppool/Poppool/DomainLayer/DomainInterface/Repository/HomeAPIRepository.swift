import Foundation

import RxSwift

protocol HomeAPIRepository {
    func fetchHome(request: SortedRequestDTO) -> Observable<GetHomeInfoResponse>
    func fetchCustomPopUp(request: SortedRequestDTO) -> Observable<GetHomeInfoResponse>
    func fetchNewPopUp(request: SortedRequestDTO) -> Observable<GetHomeInfoResponse>
    func fetchPopularPopUp(request: SortedRequestDTO) -> Observable<GetHomeInfoResponse>
}
