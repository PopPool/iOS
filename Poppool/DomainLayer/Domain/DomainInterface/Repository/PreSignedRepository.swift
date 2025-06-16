import UIKit

import RxSwift

public protocol PreSignedRepository {
    func tryUpload(presignedURLRequest: [(filePath: String, image: UIImage)]) -> Single<Void>
    func tryDelete(objectKeyList: [String]) -> Completable
    func fullImageURL(from filePath: String) -> URL?
}
