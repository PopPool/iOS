import UIKit

import DomainInterface

import RxSwift

public final class PreSignedUseCaseImpl: PreSignedUseCase {
    private let repository: PreSignedRepository

    init(repository: PreSignedRepository) {
        self.repository = repository
    }

    public func tryUpload(presignedURLRequest: [(filePath: String, image: UIImage)]) -> Single<Void> {
        return repository.tryUpload(presignedURLRequest: presignedURLRequest)
    }
    public func tryDelete(objectKeyList: [String]) -> Completable {
        return repository.tryDelete(objectKeyList: objectKeyList)
    }
    public func fullImageURL(from filePath: String) -> URL? {
        repository.fullImageURL(from: filePath)
    }
}
