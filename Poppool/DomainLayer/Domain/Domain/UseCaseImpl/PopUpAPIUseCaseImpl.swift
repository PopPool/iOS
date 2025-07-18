import Foundation

import DomainInterface

import RxSwift

public final class PopUpAPIUseCaseImpl: PopUpAPIUseCase {

    private let repository: PopUpAPIRepository

    public init(repository: PopUpAPIRepository) {
        self.repository = repository
    }

    public func getSearchBottomPopUpList(isOpen: Bool, categories: [Int], page: Int32?, size: Int32, sort: String?) -> Observable<GetSearchBottomPopUpListResponse> {
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

    public func getSearchPopUpList(query: String?) -> Observable<GetSearchPopUpListResponse> {
        return repository.getSearchPopUpList(categories: nil, page: nil, size: nil, sort: nil, query: query, sortCode: nil)
    }

    public func getPopUpDetail(commentType: String?, popUpStoredId: Int64, isViewCount: Bool? = true) -> Observable<GetPopUpDetailResponse> {
        return repository.getPopUpDetail(commentType: commentType, popUpStoreId: popUpStoredId, viewCountYn: isViewCount)
    }

    public func getPopUpComment(commentType: String?, page: Int32?, size: Int32?, sort: String?, popUpStoreId: Int64) -> Observable<GetPopUpCommentResponse> {
        return repository.getPopUpComment(commentType: commentType, page: page, size: size, sort: sort, popUpStoreId: popUpStoreId)
    }
}
