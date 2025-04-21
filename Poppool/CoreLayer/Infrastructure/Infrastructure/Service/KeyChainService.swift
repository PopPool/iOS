import Foundation
import Security

import RxSwift

public final class KeyChainService {

    // KeyChain에서 발생할 수 있는 오류를 정의
    enum KeyChainError: Error {
        case noValueFound(message: String) // 해당 키에 대해 값을 찾을 수 없을 때 발생
        case unhandledError(status: OSStatus) // 예상치 못한 OSStatus 오류가 발생했을 때 발생
        case dataConversionError(message: String) // 데이터 변환 중 오류가 발생했을 때 발생
    }

    // KeyChain 서비스 이름
    private let service = "keyChain"

    public init() { }

    /// KeyChain에서 특정 타입의 토큰을 가져오는 메서드
    /// - Parameter type: 가져오려는 토큰의 타입 (`accessToken` 또는 `refreshToken`)
    /// - Returns: 가져온 토큰을 담은 `Single<String>`
    public func fetchToken(type: TokenType) -> Result<String, Error> {
        // 1. query 작성
        let keyChainQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: self.service,
            kSecAttrAccount: type.rawValue,
            kSecReturnData: true,  // CFData 타입으로 불러오라는 의미
            kSecMatchLimit: kSecMatchLimitOne // 중복되는 경우 하나의 값만 가져오라는 의미
        ]

        // 2. Read
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(keyChainQuery, &dataTypeRef)

        // 3. Result
        if status == errSecItemNotFound {
            return .failure(KeyChainError.noValueFound(message: "No value found for the specified key."))
        } else if status != errSecSuccess {
            return .failure(KeyChainError.unhandledError(status: status))
        } else {
            if let data = dataTypeRef as? Data {
                if let value = String(data: data, encoding: .utf8) {
                    Logger.log(
                        message: "Successfully fetched \(type.rawValue) from KeyChain: \(value)",
                        category: .info,
                        fileName: #file,
                        line: #line
                    )
                    return .success(value)
                } else {
                    return .failure(KeyChainError.dataConversionError(message: "Failed to convert data to String."))
                }
            } else {
                return .failure(KeyChainError.dataConversionError(message: "Failed to convert data to Data type."))
            }
        }
    }

    /// KeyChain에 특정 타입의 토큰을 저장하는 메서드
    /// - Parameter type: 저장하려는 토큰의 타입 (`accessToken` 또는 `refreshToken`)
    /// - Parameter value: 저장할 토큰의 값
    /// - Returns: 완료 시 `Completable`
    public func saveToken(type: TokenType, value: String) -> Result<Void, Error> {
        // allowLossyConversion은 인코딩 과정에서 손실이 되는 것을 허용할 것인지 설정
        guard let convertValue = value.data(using: .utf8, allowLossyConversion: false) else {
            return .failure(KeyChainError.dataConversionError(message: "Failed to convert value to Data."))
        }

        // 1. query 작성
        let keyChainQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: self.service,
            kSecAttrAccount: type.rawValue,
            kSecValueData: convertValue
        ]

        // 2. Delete
        // KeyChain은 Key값에 중복이 생기면 저장할 수 없기 때문에 먼저 Delete
        SecItemDelete(keyChainQuery)

        // 3. Create
        let status = SecItemAdd(keyChainQuery, nil)
        if status == errSecSuccess {
            Logger.log(
                message: "Successfully saved \(type.rawValue) to KeyChain: \(value)",
                category: .info,
                fileName: #file,
                line: #line
            )
            return .success(())
        } else {
            return .failure(KeyChainError.unhandledError(status: status))
        }
    }

    /// KeyChain에서 특정 타입의 토큰을 삭제하는 메서드
    /// - Parameter type: 삭제하려는 토큰의 타입 (`accessToken` 또는 `refreshToken`)
    /// - Returns: 완료 시 `Completable`
    public func deleteToken(type: TokenType) -> Result<Void, Error> {
        // 1. query 작성
        let keyChainQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: self.service,
            kSecAttrAccount: type.rawValue
        ]

        // 2. Delete
        let status = SecItemDelete(keyChainQuery)

        if status == errSecSuccess {
            Logger.log(
                message: "Successfully deleted \(type.rawValue) from KeyChain",
                category: .info,
                fileName: #file,
                line: #line
            )
            return .success(())
        } else {
            return .failure(KeyChainError.unhandledError(status: status))
        }
    }
}

public enum TokenType: String {
    case accessToken // 액세스 토큰
    case refreshToken // 리프레시 토큰
}
