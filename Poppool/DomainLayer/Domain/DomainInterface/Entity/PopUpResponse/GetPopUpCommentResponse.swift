import Foundation

public struct GetPopUpCommentResponse {
    public init(commentList: [GetPopUpDetailCommentResponse]) {
        self.commentList = commentList
    }
    
    public let commentList: [GetPopUpDetailCommentResponse]
}
