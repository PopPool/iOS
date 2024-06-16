//
//  KeyChainRepositoryImpl.swift
//  PopPool
//
//  Created by Porori on 6/13/24.
//

import Foundation
import Security
import RxSwift

// 추후 폴더링 변경
enum KeychainError: Error {
    case dataConversionError(String)
    case duplicateItem(String)
    case unhandledError(status: OSStatus)
    case noValueFound(String)
    case noData(String)
}

final class KeyChainRepositoryImpl: KeyChainRepository {
        
    func create(service: String, account: String, value: String) -> Completable {
        return Completable.create { complete in
            
            // allowLossyConversion은 인코딩 과정에서 손실이 되는 것을 허용할 것인지 설정
            guard let convertValue = value.data(using: .utf8, allowLossyConversion: false) else {
                complete(.error(KeychainError.dataConversionError("데이터를 변환하는데 실패했습니다.")))
                return Disposables.create()
            }
            
            // 1. query작성
            let keyChainQuery: NSDictionary = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecValueData: convertValue
            ]
            
            // 2. Delete
            // KeyChain은 Key값에 중복이 생기면 저장할 수 없기때문에 먼저 Delete
            SecItemDelete(keyChainQuery)
            
            // 3. Create
            let status = SecItemAdd(keyChainQuery, nil)
            if status == errSecSuccess {
                complete(.completed)
            } else {
                complete(.error(KeychainError.unhandledError(status: status)))
            }
            return Disposables.create()
        }
    }
    
    func fetch(service: String, account: String) -> Single<String> {
        return Single.create { singleData in
            
            // 1. query작성
            let keyChainQuery: NSDictionary = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecReturnData: kCFBooleanTrue, // CFData타입으로 불러오라는 의미
                kSecMatchLimit: kSecMatchLimitOne // 중복되는 경우 하나의 값만 가져오라는 의미
            ]
            // CFData타입 -> AnyObject로 받고, Data로 타입변환해서 사용하면 됨
            
            // 2. Read
            var dataTypeRef: AnyObject?
            let status = SecItemCopyMatching(keyChainQuery, &dataTypeRef)
            
            // 3. Result
            
            // Keychain 내부에 검색한 데이터 상태(존재 여부)를 확인합니다
            if status == errSecItemNotFound {
                singleData(.failure(KeychainError.noValueFound("저장된 키 값이 없습니다.")))
            } else if status != errSecSuccess {
                singleData(.failure(KeychainError.unhandledError(status: status)))
            } else {
                if let data = dataTypeRef as? Data {
                    if let value = String(data: data, encoding: .utf8) {
                        singleData(.success(value))
                    } else {
                        singleData(.failure(KeychainError.dataConversionError("String Type으로 Convert 실패")))
                    }
                } else {
                    singleData(.failure(KeychainError.dataConversionError("Data Type으로 Convert 실패")))
                }
            }
            
            return Disposables.create()
        }
    }
    
    func delete(service: String, account: String) -> Completable {
        
        return Completable.create { complete in
            
            // 1. query작성
            let keyChainQuery: NSDictionary = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: account
            ]
            
            // 2. Delete
            let status = SecItemDelete(keyChainQuery)
            
            if status == errSecSuccess {
                complete(.completed)
            } else {
                complete(.error(KeychainError.unhandledError(status: status)))
            }
            
            return Disposables.create()
        }
    }
}
