import Foundation

import Infrastructure

struct PreSignedAPIEndPoint {
    static func presigned_upload(request: PresignedURLRequestDTO) -> Endpoint<PreSignedURLResponseDTO> {
        Logger.log("Presigned URL 생성 - Request: \(request)", category: .debug)
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/files/upload-preSignedUrl",
            method: .post,
            bodyParameters: request
        )
    }

    static func presigned_download(request: PresignedURLRequestDTO) -> Endpoint<PreSignedURLResponseDTO> {
        Logger.log("Presigned Download URL 생성 - Request: \(request)", category: .debug)
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/files/download-preSignedUrl",
            method: .post,
            bodyParameters: request
        )
    }

    static func presigned_delete(request: PresignedURLRequestDTO) -> RequestEndpoint {
        Logger.log("Presigned Delete 생성 - Request: \(request)", category: .debug)
        return RequestEndpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/files/delete",
            method: .post,
            bodyParameters: request
        )
    }
}
