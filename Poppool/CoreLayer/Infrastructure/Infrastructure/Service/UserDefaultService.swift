//
//  UserDefaultService.swift
//  MomsVillage
//
//  Created by SeoJunYoung on 9/2/24.
//

import Foundation

import RxSwift

public final class UserDefaultService {

    public init() { }

    /// Userdefault 데이터 저장 메서드
    /// - Parameters:
    ///   - key: 저장하는 데이터의 키 값 i.e) 유저 id 등
    ///   - value: 저장하는 데이터 값 i.e) access token 등
    ///   - to: 로컬 데이터베이스 타입 - DatabaseType
    /// - Returns: 별도 안내 없음
    public func save(key: String, value: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    /// Userdefault 데이터 저장 메서드
    /// - Parameters:
    ///   - key: 저장하는 데이터의 키 값 i.e) 유저 id 등
    ///   - value: 저장하는 데이터 값 i.e) access token 등
    ///   - to: 로컬 데이터베이스 타입 - DatabaseType
    /// - Returns: 별도 안내 없음
    public func save(key: String, value: [String]) {
        UserDefaults.standard.set(value, forKey: key)
    }

    /// Userdefault 데이터 발견 메서드
    /// - Parameters:
    ///   - key: 찾는 데이터의 키 값 i.e) 유저 id 등
    ///   - from: 로컬 데이터베이스 타입 - DatabaseType
    /// - Returns: 찾은 데이터 - String 타입
    public func fetch(key: String) -> String? {
        if let token = UserDefaults.standard.string(forKey: key) {
            return token
        }
        return nil
    }

    /// Userdefault 데이터 발견 메서드
    /// - Parameters:
    ///   - key: 찾는 데이터의 키 값 i.e) 유저 id 등
    ///   - from: 로컬 데이터베이스 타입 - DatabaseType
    /// - Returns: 찾은 데이터 - String 타입
    public func fetchArray(key: String) -> [String]? {
        if let token = UserDefaults.standard.array(forKey: key) as? [String] {
            return token
        }
        return nil
    }

    /// Userdefault 데이터 삭제 메서드
    /// - Parameters:
    ///   - key: 삭제하는 데이터의 키 값 i.e) 유저 id 등
    ///   - from: 로컬 데이터베이스 타입 - DatabaseType
    /// - Returns: 별도 안내 없음
    public func delete(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

// MARK: - Key base
extension UserDefaultService {
    public enum Key: String, CaseIterable {
        case searchKeyword = "searchList"
        case userID = "userID"
        case socialType = "socialType"
        case lastLogin = "lastLogin"
    }

    /// Userdefault 데이터 저장 메서드
    /// - Parameters:
    ///   - key: 저장하는 데이터의 키 값 i.e) 유저 id 등
    ///   - value: 저장하는 데이터 값 i.e) access token 등
    ///   - to: 로컬 데이터베이스 타입 - DatabaseType
    /// - Returns: 별도 안내 없음
    public func save(keyType: Key, value: String) {
        UserDefaults.standard.set(value, forKey: keyType.rawValue)
    }

    /// Userdefault 데이터 저장 메서드
    /// - Parameters:
    ///   - key: 저장하는 데이터의 키 값 i.e) 유저 id 등
    ///   - value: 저장하는 데이터 값 i.e) access token 등
    ///   - to: 로컬 데이터베이스 타입 - DatabaseType
    /// - Returns: 별도 안내 없음
    public func save(keyType: Key, value: [String]) {
        UserDefaults.standard.set(value, forKey: keyType.rawValue)
    }

    /// Userdefault 데이터 발견 메서드
    /// - Parameters:
    ///   - key: 찾는 데이터의 키 값 i.e) 유저 id 등
    ///   - from: 로컬 데이터베이스 타입 - DatabaseType
    /// - Returns: 찾은 데이터 - String 타입
    public func fetch(keyType: Key) -> String? {
        if let token = UserDefaults.standard.string(forKey: keyType.rawValue) {
            return token
        }
        return nil
    }

    /// Userdefault 데이터 발견 메서드
    /// - Parameters:
    ///   - key: 찾는 데이터의 키 값 i.e) 유저 id 등
    ///   - from: 로컬 데이터베이스 타입 - DatabaseType
    /// - Returns: 찾은 데이터 - String 타입
    public func fetchArray(keyType: Key) -> [String]? {
        if let token = UserDefaults.standard.array(forKey: keyType.rawValue) as? [String] {
            return token
        }
        return nil
    }

    /// Userdefault 데이터 삭제 메서드
    /// - Parameters:
    ///   - key: 삭제하는 데이터의 키 값 i.e) 유저 id 등
    ///   - from: 로컬 데이터베이스 타입 - DatabaseType
    /// - Returns: 별도 안내 없음
    public func delete(keyType: Key) {
        UserDefaults.standard.removeObject(forKey: keyType.rawValue)
    }
}
