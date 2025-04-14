import Foundation

import RxSwift

final class PopUpAPIUseCaseImpl: PopUpAPIUseCase {

    private let repository: PopUpAPIRepository

    init(repository: PopUpAPIRepository) {
        self.repository = repository
    }

    func getSearchBottomPopUpList(isOpen: Bool, categories: [Int64], page: Int32?, size: Int32, sort: String?) -> Observable<GetSearchBottomPopUpListResponse> {
        var categoryString: String?
        if !categories.isEmpty {
            categoryString = categories.map { String($0) + "," }.reduce("", +)
        }
        let request = GetSearchPopUpListRequestDTO(categories: categoryString, page: page, size: size, sortCode: sort)
        if isOpen {
            return repository.getOpenPopUpList(request: request).map { $0.toDomain() }
        } else {
            return repository.getClosePopUpList(request: request).map { $0.toDomain() }
        }
    }

    func getSearchPopUpList(query: String?) -> Observable<GetSearchPopUpListResponse> {
        return repository.getSearchPopUpList(request: .init(query: query)).map { $0.toDomain() }
    }

    func getPopUpDetail(commentType: String?, popUpStoredId: Int64, isViewCount: Bool? = true) -> Observable<GetPopUpDetailResponse> {
        return repository.getPopUpDetail(request: .init(commentType: commentType, popUpStoreId: popUpStoredId, viewCountYn: isViewCount)).map { $0.toDomain() }
    }

    func getPopUpComment(commentType: String?, page: Int32?, size: Int32?, sort: String?, popUpStoreId: Int64) -> Observable<GetPopUpCommentResponse> {
        let request: GetPopUpCommentRequestDTO = .init(commentType: commentType, page: page, size: size, sort: sort, popUpStoreId: popUpStoreId)
        return repository.getPopUpComment(request: request).map { $0.toDomain() }
    }
}
