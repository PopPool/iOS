import Foundation

import RxSwift

protocol UserAPIRepository {
    func postBookmarkPopUp(request: PostBookmarkPopUpRequestDTO) -> Completable
    func deleteBookmarkPopUp(request: PostBookmarkPopUpRequestDTO) -> Completable
    func postCommentLike(request: CommentLikeRequestDTO) -> Completable
    func deleteCommentLike(request: CommentLikeRequestDTO) -> Completable
    func postUserBlock(request: PostUserBlockRequestDTO) -> Completable
    func deleteUserBlock(request: PostUserBlockRequestDTO) -> Completable
    func getOtherUserCommentList(request: GetOtherUserCommentListRequestDTO) -> Observable<GetOtherUserCommentedPopUpListResponseDTO>
    func getMyPage() -> Observable<GetMyPageResponseDTO>
    func postLogout() -> Completable
    func getWithdrawlList() -> Observable<GetWithdrawlListResponseDTO>
    func postWithdrawl(request: PostWithdrawlListRequestDTO) -> Completable
    func getMyProfile() -> Observable<GetMyProfileResponseDTO>
    func putUserTailoredInfo(request: PutUserTailoredInfoRequestDTO) -> Completable
    func putUserCategory(request: PutUserCategoryRequestDTO) -> Completable
    func putUserProfile(request: PutUserProfileRequestDTO) -> Completable
    func getMyCommentedPopUp(request: SortedRequestDTO) -> Observable<GetMyCommentedPopUpResponseDTO>
    func getBlockUserList(request: GetBlockUserListRequestDTO) -> Observable<GetBlockUserListResponseDTO>
    func getNoticeList() -> Observable<GetNoticeListResponseDTO>
    func getNoticeDetail(noticeID: Int64) -> Observable<GetNoticeDetailResponseDTO>
    func getRecentPopUp(request: SortedRequestDTO) -> Observable<GetRecentPopUpResponseDTO>
    func getBookmarkPopUp(request: SortedRequestDTO) -> Observable<GetRecentPopUpResponseDTO>
}
