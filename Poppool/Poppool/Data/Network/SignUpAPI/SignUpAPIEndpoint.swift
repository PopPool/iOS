//
//  SignUpAPIEndpoint.swift
//  Poppool
//
//  Created by Porori on 11/25/24.
//

import Foundation

struct SignUpAPIEndpoint {
    
    /// 닉네임 중복을 확인합니다.
    /// - Parameter request: 닉네임 체크 요청 DTO
    /// - Returns: Endpoint<Bool>
    static func signUp_checkNickName(with request: CheckNickNameRequestDTO) -> Endpoint<Bool> {
        return Endpoint(
            baseURL: KeyPath.popPoolBaseURL,
            path: "/signup/check-nickname",
            method: .get,
            queryParameters: request
        )
    }
    
    /// 관심사 목록을 가져옵니다.
    /// - Returns: Endpoint<GetInterestListResponseDTO>
    static func signUp_getCategoryList() -> Endpoint<GetCategoryListResponseDTO> {
        return Endpoint(
            baseURL: KeyPath.popPoolBaseURL,
            path: "/signup/categories",
            method: .get
        )
    }
    
    /// 회원가입을 시도합니다.
    /// - Parameter request: 회원가입 요청 DTO
    /// - Returns: RequestEndpoint
    static func signUp_trySignUp(with request: SignUpRequestDTO) -> RequestEndpoint {
        return RequestEndpoint(
            baseURL: KeyPath.popPoolBaseURL,
            path: "/signup",
            method: .post,
            bodyParameters: request
        )
    }
}
