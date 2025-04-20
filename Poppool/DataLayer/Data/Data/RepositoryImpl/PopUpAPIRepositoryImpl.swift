import Foundation

import DomainInterface

import RxSwift

public final class PopUpAPIRepositoryImpl: PopUpAPIRepository {

    private let provider: Provider
    private let tokenInterceptor = TokenInterceptor()

    public init(provider: Provider) {
        self.provider = provider
    }

    public func postBookmarkPopUp(popUpStoreId: Int64) -> Completable {
        let request = PostBookmarkPopUpRequestDTO(popUpStoreId: popUpStoreId)
        let endPoint = UserAPIEndPoint.postBookmarkPopUp(request: request)
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }

    public func getClosePopUpList(
        categories: String?,
        page: Int32?,
        size: Int32?,
        sort: String?,
        query: String?,
        sortCode: String?
    ) -> Observable<GetSearchBottomPopUpListResponse> {
        let request = GetSearchPopUpListRequestDTO(categories: categories, page: page, size: size, sort: sort, query: query, sortCode: sortCode)
        let endPoint = PopUpAPIEndPoint.getClosePopUpList(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map { $0.toDomain() }
    }

    public func getOpenPopUpList(
        categories: String?,
        page: Int32?,
        size: Int32?,
        sort: String?,
        query: String?,
        sortCode: String?
    ) -> Observable<GetSearchBottomPopUpListResponse> {
        let request = GetSearchPopUpListRequestDTO(categories: categories, page: page, size: size, sort: sort, query: query, sortCode: sortCode)
        let endPoint = PopUpAPIEndPoint.getOpenPopUpList(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map { $0.toDomain() }
    }

    public func getSearchPopUpList(
        categories: String?,
        page: Int32?,
        size: Int32?,
        sort: String?,
        query: String?,
        sortCode: String?
    ) -> Observable<GetSearchPopUpListResponse> {
        let request = GetSearchPopUpListRequestDTO(categories: categories, page: page, size: size, sort: sort, query: query, sortCode: sortCode)
        let endPoint = PopUpAPIEndPoint.getSearchPopUpList(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map { $0.toDomain() }
    }

    public func getPopUpDetail(commentType: String?, popUpStoreId: Int64, viewCountYn: Bool?) -> Observable<GetPopUpDetailResponse> {
        let request = GetPopUpDetailRequestDTO(commentType: commentType, popUpStoreId: popUpStoreId, viewCountYn: viewCountYn)
        let endPoint = PopUpAPIEndPoint.getPopUpDetail(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map { $0.toDomain() }
    }

    public func getPopUpComment(commentType: String?, page: Int32?, size: Int32?, sort: String?, popUpStoreId: Int64) -> Observable<GetPopUpCommentResponse> {
        let request = GetPopUpCommentRequestDTO(commentType: commentType, page: page, size: size, sort: sort, popUpStoreId: popUpStoreId)
        let endPoint = PopUpAPIEndPoint.getPopUpComment(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor).map { $0.toDomain() }
    }
}
