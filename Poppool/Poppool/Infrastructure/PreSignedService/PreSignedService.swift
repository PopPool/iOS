//
//  PreSignedService.swift
//  PopPool
//
//  Created by SeoJunYoung on 9/5/24.
//

import Foundation
import UIKit

import RxSwift
import RxCocoa
import Alamofire

class ImageCache {
    static let shared = NSCache<NSString, UIImage>()
}

class PreSignedService {

    struct PresignedURLRequest {
        var filePath: String
        var image: UIImage
    }

    let tokenInterceptor = TokenInterceptor()
    
    let provider = ProviderImpl()
    
    let disposeBag = DisposeBag()

    func tryDelete(targetPaths: PresignedURLRequestDTO) -> Completable {
        let endPoint = PreSignedAPIEndPoint.presigned_delete(request: targetPaths)
        return provider.request(with: endPoint, interceptor: tokenInterceptor)
    }

    func tryUpload(datas: [PresignedURLRequest]) -> Single<Void> {
        Logger.log(message: "tryUpload 호출됨 - 요청 데이터 수: \(datas.count)", category: .debug)

        return Single.create { [weak self] observer in
            Logger.log(message: "tryUpload 내부 흐름 시작", category: .debug)

            guard let self = self else {
                Logger.log(message: "self가 nil입니다. 작업을 중단합니다.", category: .error)
                return Disposables.create()
            }

            // 1. 업로드 링크 요청
            self.getUploadLinks(request: .init(objectKeyList: datas.map { $0.filePath }))
                .subscribe { response in
                    Logger.log(message: "getUploadLinks 성공: \(response.preSignedUrlList)", category: .debug)

                    let responseList = response.preSignedUrlList
                    let inputList = datas

                    // 2. 업로드 준비
                    let requestList = zip(responseList, inputList).compactMap { zipResponse in
                        let urlResponse = zipResponse.0
                        let inputResponse = zipResponse.1
                        Logger.log(message: "업로드 준비 - URL: \(urlResponse.preSignedUrl)", category: .debug)
                        return self.uploadFromS3(url: urlResponse.preSignedUrl, image: inputResponse.image)
                    }

                    // 3. 병렬 업로드 실행
                    Single.zip(requestList)
                        .subscribe(onSuccess: { _ in
                            Logger.log(message: "모든 이미지 업로드 성공", category: .info)
                            observer(.success(()))
                        }, onFailure: { error in
                            Logger.log(message: "이미지 업로드 실패: \(error.localizedDescription)", category: .error)
                            observer(.failure(error))
                        })
                        .disposed(by: self.disposeBag)

                } onError: { error in
                    Logger.log(message: "getUploadLinks 실패: \(error.localizedDescription)", category: .error)
                    observer(.failure(error))
                }
                .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }


    func tryDownload(filePaths: [String]) -> Single<[UIImage]> {

        return Single.create { [weak self] observer in
             guard let self = self else {
                 return Disposables.create()
             }

             // 순서를 유지하기 위한 매핑 구조
             var imageMap: [String: UIImage] = [:]
             var uncachedFilePaths: [String] = []

             // 캐시에서 이미지를 검색
             for filePath in filePaths {
                 if let cachedImage = ImageCache.shared.object(forKey: filePath as NSString) {
                     imageMap[filePath] = cachedImage
                 } else {
                     uncachedFilePaths.append(filePath)
                 }
             }

             // 캐시에 없는 이미지를 다운로드
             if uncachedFilePaths.isEmpty {
                 let sortedImages = filePaths.compactMap { imageMap[$0] } // 원래 순서대로 정렬
                 observer(.success(sortedImages))
                 return Disposables.create()
             }

             self.getDownloadLinks(request: .init(objectKeyList: uncachedFilePaths))
                 .subscribe { response in
                     let responseList = response.preSignedUrlList
                     let requestList = responseList.compactMap { self.downloadFromS3(url: $0.preSignedUrl) }

                     // 병렬로 이미지 다운로드
                     Single.zip(requestList)
                         .map { dataList -> [UIImage] in
                             for (index, data) in dataList.enumerated() {
                                 guard let image = UIImage(data: data) else { continue }
                                 let filePath = uncachedFilePaths[index]
                                 imageMap[filePath] = image
                                 // 다운로드된 이미지를 캐시에 저장
                                 ImageCache.shared.setObject(image, forKey: filePath as NSString)
                             }

                             // 원래 순서대로 이미지를 정렬
                             return filePaths.compactMap { imageMap[$0] }
                         }
                         .subscribe(onSuccess: { sortedImages in
                             Logger.log(message: "All images downloaded successfully", category: .info)
                             observer(.success(sortedImages))
                         }, onFailure: { error in
                             Logger.log(message: "Image download failed: \(error.localizedDescription)", category: .error)
                             observer(.failure(error))
                         })
                         .disposed(by: self.disposeBag)

                 } onError: { error in
                     Logger.log(message: "getDownloadLinks Fail: \(error.localizedDescription)", category: .error)
                     observer(.failure(error))
                 }
                 .disposed(by: disposeBag)

             return Disposables.create()
         }
    }
}


private extension PreSignedService {

    func uploadFromS3(url: String, image: UIImage) -> Single<Void> {
        return Single.create { single in
            if let imageData = image.jpegData(compressionQuality: 0),
               let url = URL(string: url) {
                Logger.log(message: "S3 업로드 요청 URL: \(url.absoluteString)", category: .debug)

                let headers: HTTPHeaders = [
                    "Content-Type": "image/jpeg"
                ]

                AF.upload(imageData, to: url, method: .put, headers: headers)
                    .response { response in
                        Logger.log(message: "S3 업로드 응답 상태: \(response.response?.statusCode ?? -1)", category: .debug)
                        switch response.result {
                        case .success:
                            Logger.log(message: "S3 업로드 성공 - URL: \(url.absoluteString)", category: .info)
                            single(.success(()))
                        case .failure(let error):
                            Logger.log(message: "S3 업로드 실패: \(error.localizedDescription)", category: .error)
                            single(.failure(error))
                        }
                    }
                return Disposables.create()
            } else {
                Logger.log(message: "S3 업로드 실패 - 잘못된 URL 또는 데이터", category: .error)
                single(.failure(NSError(domain: "InvalidDataOrURL", code: -1, userInfo: nil)))
                return Disposables.create()
            }
        }
    }

    func downloadFromS3(url: String) -> Single<Data> {
        return Single.create { [weak self] single in
            guard let self = self,
                  let fullURL = self.fullImageURL(from: url) else {
                single(.failure(NSError(domain: "InvalidDataOrURL", code: -1, userInfo: nil)))
                return Disposables.create()
            }
            let request = AF.request(fullURL).responseData { response in
                switch response.result {
                case .success(let data):
                    single(.success(data))
                case .failure(let error):
                    single(.failure(error))
                }
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }



    func getUploadLinks(request: PresignedURLRequestDTO) -> Observable<PreSignedURLResponseDTO> {
        Logger.log(message: "Presigned URL 생성 요청 데이터: \(request)", category: .debug)
        let provider = ProviderImpl()
        let endPoint = PreSignedAPIEndPoint.presigned_upload(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor)
            .do(onNext: { response in
                Logger.log(message: "Presigned URL 응답 데이터: \(response.preSignedUrlList)", category: .debug)
            }, onError: { error in
                Logger.log(message: "Presigned URL 요청 실패: \(error.localizedDescription)", category: .error)
            })
    }

    func getDownloadLinks(request: PresignedURLRequestDTO) -> Observable<PreSignedURLResponseDTO> {
        let provider = ProviderImpl()
        let endPoint = PreSignedAPIEndPoint.presigned_download(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor)
    }
}
extension PreSignedService {
    func deleteImage(filePath: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Logger.log(message: "이미지 삭제 시작 - 경로: \(filePath)", category: .debug)

        let request = PresignedURLRequestDTO(objectKeyList: [filePath])

        tryDelete(targetPaths: request)
            .subscribe(
                onCompleted: {
                    Logger.log(message: "이미지 삭제 성공: \(filePath)", category: .debug)
                    completion(.success(()))
                },
                onError: { error in
                    Logger.log(message: "이미지 삭제 실패: \(error.localizedDescription)", category: .error)
                    completion(.failure(error))
                }
            )
            .disposed(by: disposeBag)
    }

    func deleteImage(filePath: String) -> Single<Void> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                return Disposables.create()
            }

            let request = PresignedURLRequestDTO(objectKeyList: [filePath])

            self.tryDelete(targetPaths: request)
                .subscribe(
                    onCompleted: {
                        observer(.success(()))
                    },
                    onError: { error in
                        observer(.failure(error))
                    }
                )
                .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    // 여러 이미지 한번에 삭제
    func deleteImages(filePaths: [String]) -> Single<Void> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                return Disposables.create()
            }

            let request = PresignedURLRequestDTO(objectKeyList: filePaths)

            self.tryDelete(targetPaths: request)
                .subscribe(
                    onCompleted: {
                        observer(.success(()))
                    },
                    onError: { error in
                        observer(.failure(error))
                    }
                )
                .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }
    func fullImageURL(from filePath: String) -> URL? {
        let baseURL = Secrets.popPoolS3BaseURL

        // URL 인코딩 처리를 더 엄격하게
        guard let encodedPath = filePath
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?
            .replacingOccurrences(of: "+", with: "%2B") else {
            Logger.log(message: "URL 인코딩 실패: \(filePath)", category: .error)
            return nil
        }

        let fullString = baseURL + encodedPath
        Logger.log(message: "생성된 URL: \(fullString)", category: .debug)

        return URL(string: fullString)
    }

}

