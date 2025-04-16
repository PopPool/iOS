import Foundation

/// 의존성 주입 컨테이너
///
/// 이 컨테이너는 타입 기반으로 의존성을 등록하고 어디서든 안전하게 꺼내 쓸 수 있도록 도와줍니다.
///
/// 앱 시작 시점에 필요한 구현체를 `register(_:_: )`를 통해 등록하고,
/// 이후에는 `resolve(_:)` 메서드를 통해 원하는 타입의 인스턴스를 꺼낼 수 있습니다.
///
/// ## 등록 예시
/// ```swift
/// DIContainer.register(SampleProtocol.self) {
///     SampleImpl()
/// }
/// ```
///
/// ## 사용 예시
/// ```swift
/// // DIContainer의 resolve 메서드를 사용하는 방식
/// let sample: SampleProtocol = DIContainer.resolve(SampleProtocol.self)
/// ```
public final class DIContainer {
    private static let container = DIContainer()
    
    private var registrations: [ObjectIdentifier: () -> Any] = [:]
    
    private let resolveQueue = DispatchQueue(label: "resolveQueue")
    
    private init() {}
    
    /// 의존성을 등록합니다.
    /// - Parameters:
    ///   - type: 등록할 프로토콜 또는 클래스 타입
    ///   - implementation: 해당 타입에 대응되는 구현체를 생성하는 클로저
    public static func register<T>(
        _ type: T.Type,
        _ implementation: @escaping () -> T
    ) {
        container.register(type, implementation)
    }
    
    /// 의존성을 꺼내옵니다.
    /// - Parameter type: 요청할 타입
    /// - Returns: 등록된 타입의 인스턴스
    public static func resolve<T>(_ type: T.Type) -> T {
        return container.resolve(type)
    }
    
    private func register<T>(
        _ type: T.Type,
        _ implementation: @escaping () -> T
    ) {
        let key = ObjectIdentifier(type)
        registrations[key] = { implementation() }
    }
    
    private func resolve<T>(_ type: T.Type) -> T {
        let key = ObjectIdentifier(type)

        return resolveQueue.sync {
            guard let registration = registrations[key],
                  let instance = registration() as? T
            else { fatalError("\(type) does not registered") }
            
            return instance
        }
    }
}
