import Foundation
import Alamofire
import RxSwift

final class AdminRepositoryImpl: AdminRepository {

    // MARK: - Properties
    private let provider: Provider
    private let tokenInterceptor = TokenInterceptor()

    // MARK: - Init
    init(provider: Provider) {
        self.provider = provider
    }

    // MARK: - Store Methods
    func fetchStoreList(query: String?, page: Int, size: Int) -> Observable<[AdminStore]> {
        let endpoint = AdminAPIEndpoint.fetchStoreList(
            query: query,
            page: page,
            size: size
        )
        return provider.requestData(
            with: endpoint,
            interceptor: tokenInterceptor
        )
        .map { response in
            response.popUpStoreList?.map {
                AdminStore(id: $0.id, name: $0.name, categoryName: $0.categoryName, mainImageUrl: $0.mainImageUrl)
            } ?? []
        }
    }

    func fetchStoreDetail(id: Int64) -> Observable<AdminStoreDetail> {
       let endpoint = AdminAPIEndpoint.fetchStoreDetail(id: id)
       return provider.requestData(
           with: endpoint,
           interceptor: tokenInterceptor
       )
       .map { dto in
           AdminStoreDetail(
               id: dto.id,
               name: dto.name,
               categoryId: dto.categoryId,
               categoryName: dto.categoryName,
               description: dto.desc,
               address: dto.address,
               startDate: dto.startDate,
               endDate: dto.endDate,
               createUserId: dto.createUserId,
               createDateTime: dto.createDateTime,
               mainImageUrl: dto.mainImageUrl,
               bannerYn: dto.bannerYn,
               images: dto.imageList.map {
                   AdminStoreDetail.StoreImage(
                       id: $0.id,
                       imageUrl: $0.imageUrl
                   )
               },
               latitude: dto.latitude,
               longitude: dto.longitude,
               markerTitle: dto.markerTitle,
               markerSnippet: dto.markerSnippet
           )
       }
       .catch { error in
           if case .responseSerializationFailed = error as? AFError {
               return Observable.empty()
           }
           throw error
       }
    }

    func createStore(params: CreateStoreParams) -> Completable {
        let dto = CreatePopUpStoreRequestDTO(
            name: params.name,
            categoryId: params.categoryId,
            desc: params.desc,
            address: params.address,
            startDate: params.startDate,
            endDate: params.endDate,
            mainImageUrl: params.mainImageUrl,
            imageUrlList: params.imageUrlList,
            latitude: params.latitude,
            longitude: params.longitude,
            markerTitle: params.markerTitle,
            markerSnippet: params.markerSnippet,
            startDateBeforeEndDate: params.startDateBeforeEndDate
        )
        let endpoint = AdminAPIEndpoint.createStore(request: dto)
        return provider.request(with: endpoint, interceptor: tokenInterceptor)
    }

    func updateStore(params: UpdateStoreParams) -> Completable {
        let dto = UpdatePopUpStoreRequestDTO(
            popUpStore: UpdatePopUpStoreRequestDTO.PopUpStore(
                id: params.id,
                name: params.name,
                categoryId: params.categoryId,
                desc: params.desc,
                address: params.address,
                startDate: params.startDate,
                endDate: params.endDate,
                mainImageUrl: params.mainImageUrl,
                bannerYn: !params.mainImageUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                imageUrl: params.imageUrlList.compactMap { $0 },
                startDateBeforeEndDate: params.startDateBeforeEndDate
            ),
            location: UpdatePopUpStoreRequestDTO.Location(
                latitude: params.latitude,
                longitude: params.longitude,
                markerTitle: params.markerTitle,
                markerSnippet: params.markerSnippet
            ),
            imagesToAdd: params.imageUrlList.compactMap { $0 },
            imagesToDelete: params.imagesToDelete
        )
        let endpoint = AdminAPIEndpoint.updateStore(request: dto)
        return provider.request(with: endpoint, interceptor: tokenInterceptor)
    }

    func deleteStore(id: Int64) -> Completable {
        let endpoint = AdminAPIEndpoint.deleteStore(id: id)
        return provider.request(with: endpoint, interceptor: tokenInterceptor)
    }

    // MARK: - Notice Methods
    func createNotice(params: CreateNoticeParams) -> Completable {
        let dto = CreateNoticeRequestDTO(
            title: params.title,
            content: params.content,
            imageUrlList: params.imageUrlList
        )
        let endpoint = AdminAPIEndpoint.createNotice(request: dto)
        return provider.request(with: endpoint, interceptor: tokenInterceptor)
    }

    func updateNotice(params: UpdateNoticeParams) -> Completable {
        let dto = UpdateNoticeRequestDTO(
            title: params.title,
            content: params.content,
            imageUrlList: params.imageUrlList,
            imagesToDelete: params.imagesToDelete
        )
        let endpoint = AdminAPIEndpoint.updateNotice(id: params.id, request: dto)
        return provider.request(with: endpoint, interceptor: tokenInterceptor)
    }

    func deleteNotice(id: Int64) -> Completable {
        let endpoint = AdminAPIEndpoint.deleteNotice(id: id)
        return provider.request(with: endpoint, interceptor: tokenInterceptor)
    }
}

// Helper extension - keeping this for utility purposes
extension GetAdminPopUpStoreDetailResponseDTO {
   static var empty: GetAdminPopUpStoreDetailResponseDTO {
       return GetAdminPopUpStoreDetailResponseDTO(
           id: 0,
           name: "",
           categoryId: 0,
           categoryName: "",
           desc: "",
           address: "",
           startDate: "",
           endDate: "",
           createUserId: "",
           createDateTime: "",
           mainImageUrl: "",
           bannerYn: false,
           imageList: [],
           latitude: 0.0,
           longitude: 0.0,
           markerTitle: "",
           markerSnippet: ""
       )
   }
}
