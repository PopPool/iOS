import UIKit

import DomainInterface

import RxSwift

public final class PreSignedRepositoryImpl: PreSignedRepository {

    private let service = PreSignedService()

    public init() { }

    public func tryUpload(presignedURLRequest: [(filePath: String, image: UIImage)]) -> Single<Void> {
        return service.tryUpload(datas: presignedURLRequest.map {
            PreSignedService.PresignedURLRequest(
                filePath: $0.filePath,
                image: $0.image
            )
        })
    }
    
    public func tryDelete(objectKeyList: [String]) -> Completable {
        return service.tryDelete(
            targetPaths: PresignedURLRequestDTO(objectKeyList: objectKeyList)
        )
    }
    
    public func fullImageURL(from filePath: String) -> URL? {
        return service.fullImageURL(from: filePath)
    }
}
