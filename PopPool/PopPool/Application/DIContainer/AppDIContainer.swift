//
//  AppDIContainer.swift
//  PopPool
//
//  Created by SeoJunYoung on 6/1/24.
//

import Foundation

protocol DIContainer {
    
    /// 특정 타입에 대한 컴포넌트를 등록합니다.
    /// - Parameters:
    ///   - type: 컴포넌트를 등록할 타입.
    ///   - component: 등록할 컴포넌트 인스턴스.
    func register<T>(type: T.Type, component: AnyObject)
    
    /// 특정 타입에 대한 컴포넌트를 등록합니다.
    /// - Parameters:
    ///   - type: 컴포넌트를 등록할 타입.
    ///   - identifier: 식별자
    ///   - component: 등록할 컴포넌트 인스턴스.
    func register<T>(type: T.Type, identifier: String, component: AnyObject)
    
    /// 특정 타입에 대한 컴포넌트를 반환합니다.
    /// - Parameter type: 반환할 컴포넌트의 타입.
    /// - Returns: 반환된 컴포넌트 인스턴스.
    func resolve<T>(type: T.Type) -> T
    
    /// 특정 타입에 대한 컴포넌트를 반환합니다.
    /// - Parameter type: 반환할 컴포넌트의 타입.
    /// - identifier: 식별자
    /// - Returns: 반환된 컴포넌트 인스턴스.
    func resolve<T>(type: T.Type, identifier: String) -> T
}

final class AppDIContainer: DIContainer {

    // AppDIContainer의 싱글톤 인스턴스
    static let shared = AppDIContainer()
    
    // 인스턴스 생성을 방지하기 위한 private 초기화 함수
    private init() {}
    
    // Default 문자열
    private var defaultString: String = "Default"
    
    // 등록된 서비스를 저장할 딕셔너리
    private var services: [String: [String : AnyObject] ] = [:]
    
    func register<T>(type: T.Type, component: AnyObject) {
        let key = "\(type)"
        services[key] = [defaultString : component]
    }
    
    func register<T>(type: T.Type, identifier: String, component: AnyObject) {
        let key = "\(type)"
        if services[key] == nil {
            services[key] = [identifier : component]
        } else {
            services[key]![identifier] = component
        }
    }
    
    func resolve<T>(type: T.Type) -> T {
        let key = "\(type)"
        let subvalue = services[key]!
        return subvalue[defaultString] as! T
    }

    func resolve<T>(type: T.Type, identifier: String) -> T {
        let key = "\(type)"
        let subvalue = services[key]!
        return subvalue[identifier] as! T
    }
}

extension AppDelegate {
    /// DI 컨테이너 인스턴스를 등록합니다.
    func registerDIContainer() {
        let container = AppDIContainer.shared
        
        container.register(
            type: Provider.self,
            component: ProviderImpl()
        )
        
        container.register(
            type: AuthRepository.self,
            component: AuthRepositoryImpl(provider: container.resolve(type: Provider.self))
        )
        
        container.register(
            type: FetchSocialCredentialUseCase.self,
            identifier: SocialTYPE.apple.rawValue,
            component: FetchSocialCredentialUseCaseImpl(service: AppleAuthServiceImpl())
        )
        
        container.register(
            type: FetchSocialCredentialUseCase.self,
            identifier: SocialTYPE.kakao.rawValue,
            component: FetchSocialCredentialUseCaseImpl(service: KakaoAuthServiceImpl())
        )
        
        container.register(
            type: TryLoginUseCase.self,
            component: TryLoginUseCaseImpl(repository: container.resolve(type: AuthRepository.self))
        )
    }
}
