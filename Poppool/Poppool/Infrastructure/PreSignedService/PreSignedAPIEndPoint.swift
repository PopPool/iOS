//
//  PreSignedAPIEndPoint.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/29/24.
//

import Foundation

struct PreSignedAPIEndPoint {
    static func presigned_upload(request: PresignedURLRequestDTO) -> Endpoint<PreSignedURLResponseDTO> {
        Logger.log(message: "Presigned URL 생성 - Request: \(request)", category: .debug)
        return Endpoint(
            baseURL: KeyPath.popPoolBaseURL,
            path: "/files/upload-preSignedUrl",
            method: .post,
            bodyParameters: request
        )
    }

    static func presigned_download(request: PresignedURLRequestDTO) -> Endpoint<PreSignedURLResponseDTO> {
        Logger.log(message: "Presigned Download URL 생성 - Request: \(request)", category: .debug)
        return Endpoint(
            baseURL: KeyPath.popPoolBaseURL,
            path: "/files/download-preSignedUrl",
            method: .post,
            bodyParameters: request
        )
    }

    static func presigned_delete(request: PresignedURLRequestDTO) -> RequestEndpoint {
        Logger.log(message: "Presigned Delete 생성 - Request: \(request)", category: .debug)
        return RequestEndpoint(
            baseURL: KeyPath.popPoolBaseURL,
            path: "/files/delete",
            method: .post,
            bodyParameters: request
        )
    }
}
