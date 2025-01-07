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
        
        return Single.create { [weak self] observer in
            guard let self = self else {
                return Disposables.create()
            }
            
            getUploadLinks(request: .init(objectKeyList: datas.map { $0.filePath } ))
                .subscribe { response in
                    let responseList = response.preSignedUrlList
                    let inputList = datas
                    let requestList = zip(responseList, inputList).compactMap { zipResponse in
                        let urlResponse = zipResponse.0
                        let inputResponse = zipResponse.1
                        return self.uploadFromS3(url: urlResponse.preSignedUrl, image: inputResponse.image)
                    }
                    Single.zip(requestList)
                        .subscribe(onSuccess: { _ in
                            print("All images uploaded successfully")
                            observer(.success(()))
                        }, onFailure: { error in
                            print("Image upload failed: \(error.localizedDescription)")
                            observer(.failure(error))
                        })
                        .disposed(by: self.disposeBag)
                } onError: { error in
                    print("getUploadLinks Fail: \(error.localizedDescription)")
                    observer(.failure(error))
                }
                .disposed(by: disposeBag)
            return Disposables.create()
        }
    }
    
    func tryDownload(filePaths: [String]) -> Single<[UIImage]> {
        
        return Single.create { [weak self] observer in
             guard let self = self else {
                 return Disposables.create()
             }

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
               let url = URL(string: url)
            {
                // Content-Type 헤더 설정
                let headers: HTTPHeaders = [
                    "Content-Type": "image/jpeg"
                ]

                AF.upload(imageData, to: url, method: .put, headers: headers)
                    .response { response in
                        switch response.result {
                        case .success:
                            print("success")
                            single(.success(()))
                        case .failure(let error):
                            print("failure")
                            single(.failure(error))
                        }
                    }
                return Disposables.create()
            } else {
                single(.failure(NSError(domain: "InvalidDataOrURL", code: -1, userInfo: nil)))
                return Disposables.create()
            }
        }
    }
    
    func downloadFromS3(url: String) -> Single<Data> {
        return Single.create { single in
            if let url = URL(string: url) {
                let request = AF.request(url).responseData { response in
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
            } else {
                single(.failure(NSError(domain: "InvalidDataOrURL", code: -1, userInfo: nil)))
                return Disposables.create()
            }
        }
    }
    
    func getUploadLinks(request: PresignedURLRequestDTO) -> Observable<PreSignedURLResponseDTO> {
        let provider = ProviderImpl()
        let endPoint = PreSignedAPIEndPoint.presigned_upload(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor)
    }
    
    func getDownloadLinks(request: PresignedURLRequestDTO) -> Observable<PreSignedURLResponseDTO> {
        let provider = ProviderImpl()
        let endPoint = PreSignedAPIEndPoint.presigned_download(request: request)
        return provider.requestData(with: endPoint, interceptor: tokenInterceptor)
    }
}
