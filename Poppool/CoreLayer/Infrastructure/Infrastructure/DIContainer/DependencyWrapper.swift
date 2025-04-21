import Foundation

/// 의존성 자동 주입을 위한 프로퍼티 래퍼
///
/// 사용하는 곳에서 `@Dependency`만 붙이면 등록된 구현체가 자동으로 주입됩니다.
///
/// Swift의 프로퍼티 래퍼 특성상 `var`로 선언해야 하지만, 실제 인스턴스는 외부에서 변경할 수 없도록 `private(set)`으로 보호되어 불변성을 유지합니다.
///
/// 사용 예시:
/// ```swift
/// class MyViewModel {
///     @Dependency var sample: SampleProtocol
///
///     func run() {
///         sample.doSomething()
///     }
/// }
/// ```
@propertyWrapper
public final class Dependency<T> {
    /// DIContainer에서 꺼내온 실제 인스턴스
    public private(set) var wrappedValue: T

    /// DIContainer로부터 자동으로 인스턴스를 꺼내와 초기화합니다.
    public init() {
        self.wrappedValue = DIContainer.resolve(T.self)
    }
}
