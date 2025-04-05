import NMapsMap
import RxCocoa
import RxSwift

/// NMFMapViewDelegateProxy는 NMFMapView의 delegate 이벤트를 RxSwift Observable로 변환하는 역할
class NMFMapViewDelegateProxy: DelegateProxy<NMFMapView, NMFMapViewDelegate>, DelegateProxyType, NMFMapViewDelegate {

    // MARK: - Properties

    /// 연결된 NMFMapView 인스턴스 (약한 참조)
    public weak private(set) var mapView: NMFMapView?

    /// 카메라 위치 변경 이벤트를 전달하기 위한 Rx Subject
    let didChangePositionSubject = PublishSubject<Void>()

    /// 맵이 idle 상태가 되었을 때 이벤트를 전달하기 위한 Rx Subject
    let idleAtPositionSubject = PublishSubject<Void>()

    // MARK: - Initializer

    /// NMFMapViewDelegateProxy 초기화 메서드
    /// - Parameter mapView: 이벤트를 받아올 NMFMapView 인스턴스
    init(mapView: NMFMapView) {
        self.mapView = mapView
        super.init(parentObject: mapView, delegateProxy: NMFMapViewDelegateProxy.self)
    }

    // MARK: - DelegateProxyType Implementation

    /// Rx에서 사용하기 위한 구현 등록
    static func registerKnownImplementations() {
        self.register { NMFMapViewDelegateProxy(mapView: $0) }
    }

    /// 지정된 NMFMapView의 현재 delegate를 반환
    /// - Parameter object: NMFMapView 인스턴스
    /// - Returns: 해당 mapView의 delegate
    static func currentDelegate(for object: NMFMapView) -> NMFMapViewDelegate? {
        return object.delegate
    }

    /// 지정된 NMFMapView에 delegate를 설정
    /// - Parameters:
    ///   - delegate: 설정할 delegate
    ///   - object: NMFMapView 인스턴스
    static func setCurrentDelegate(_ delegate: NMFMapViewDelegate?, to object: NMFMapView) {
        object.delegate = delegate
    }

    // MARK: - NMFMapViewDelegate Methods

    /// 카메라 위치가 변경될 때 호출되는 메서드.
    /// - Parameters:
    ///   - mapView: 이벤트가 발생한 NMFMapView
    ///   - reason: 카메라 변경 사유
    ///   - animated: 애니메이션 여부
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        didChangePositionSubject.onNext(())
        // 기존 delegate로 이벤트 전달 (옵셔널 체이닝)
        _forwardToDelegate?.mapView?(mapView, cameraDidChangeByReason: reason, animated: animated)
    }

    /// 맵뷰가 idle 상태가 되었을 때 호출되는 메서드.
    /// Rx Subject를 통해 idle 이벤트를 전달하고, 기존 delegate에게 까지
    /// - Parameter mapView: idle 상태가 된 NMFMapView
    func mapViewIdle(_ mapView: NMFMapView) {
        idleAtPositionSubject.onNext(())
        // 기존 delegate로 idle 이벤트 전달
        forwardToDelegate()?.mapViewIdle?(mapView)
    }
}

/// NMFMapView의 Reactive 확장
extension Reactive where Base: NMFMapView {

    /// NMFMapViewDelegateProxy를 반환하여 delegate 이벤트를 처리할 수 있도록
    var delegate: DelegateProxy<NMFMapView, NMFMapViewDelegate> {
        return NMFMapViewDelegateProxy.proxy(for: base)
    }

    /// mapView의 카메라 위치 변경 이벤트를 Observable로
    var didChangePosition: Observable<Void> {
        let proxy = NMFMapViewDelegateProxy.proxy(for: base)
        return proxy.didChangePositionSubject.asObservable()
    }

    /// mapView가 idle 상태가 되었을 때의 이벤트를 Observable로
    var idleAtPosition: Observable<Void> {
        let proxy = NMFMapViewDelegateProxy.proxy(for: base)
        return proxy.idleAtPositionSubject.asObservable()
    }
}
