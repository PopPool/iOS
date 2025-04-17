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
        if isOpen {
            return repository.getOpenPopUpList(categories: categoryString, page: page, size: size, sort: nil, query: nil, sortCode: sort)
        } else {
            return repository.getClosePopUpList(categories: categoryString, page: page, size: size, sort: nil, query: nil, sortCode: sort)
        }
    }

    func getSearchPopUpList(query: String?) -> Observable<GetSearchPopUpListResponse> {
        return repository.getSearchPopUpList(categories: nil, page: nil, size: nil, sort: nil, query: query, sortCode: nil)
    }

    func getPopUpDetail(commentType: String?, popUpStoredId: Int64, isViewCount: Bool? = true) -> Observable<GetPopUpDetailResponse> {
        return repository.getPopUpDetail(commentType: commentType, popUpStoreId: popUpStoredId, viewCountYn: isViewCount)
    }

    func getPopUpComment(commentType: String?, page: Int32?, size: Int32?, sort: String?, popUpStoreId: Int64) -> Observable<GetPopUpCommentResponse> {
        let request: GetPopUpCommentRequestDTO = .init(commentType: commentType, page: page, size: size, sort: sort, popUpStoreId: popUpStoreId)
        return repository.getPopUpComment(commentType: commentType, page: page, size: size, sort: sort, popUpStoreId: popUpStoreId)
    }
}
