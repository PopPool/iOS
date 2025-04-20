import Foundation

import RxSwift

public protocol HomeAPIUseCase {
    func fetchHome(page: Int32?, size: Int32?, sort: String?) -> Observable<GetHomeInfoResponse>
    func fetchCustomPopUp(page: Int32?, size: Int32?, sort: String?) -> Observable<GetHomeInfoResponse>
    func fetchNewPopUp(page: Int32?, size: Int32?, sort: String?) -> Observable<GetHomeInfoResponse>
    func fetchPopularPopUp(page: Int32?, size: Int32?, sort: String?) -> Observable<GetHomeInfoResponse>
}
