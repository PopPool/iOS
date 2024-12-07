//
//  PopUpAPIRepositoryImpl.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/6/24.
//

import Foundation

import RxSwift

struct PopUpAPIRepositoryImpl {
    private let provider: Provider
    private let tokenInterceptor = TokenInterceptor()
    
    init(provider: Provider) {
        self.provider = provider
    }
    
    func postBookmarkPopUp(request: PostBookmarkPopUpRequestDTO) -> Completable {
        let endPoint = UserAPIEndPoint.postBookmarkPopUp(request: request)
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }
    
    func getClosePopUpList(request: GetSearchPopUpListRequestDTO) -> Observable<GetClosePopUpListResponseDTO> {
        let endPoint = PopUpAPIEndPoint.getClosePopUpList(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor)
    }
    
    func getOpenPopUpList(request: GetSearchPopUpListRequestDTO) -> Observable<GetOpenPopUpListResponseDTO> {
        let endPoint = PopUpAPIEndPoint.getOpenPopUpList(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor)
    }
    
    func getSearchPopUpList(request: GetSearchPopUpListRequestDTO) -> Observable<GetSearchPopUpListResponseDTO> {
        let endPoint = PopUpAPIEndPoint.getSearchPopUpList(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor)
    }
}
