import NMapsMap
import RxSwift
import RxCocoa

class NMFMapViewDelegateProxy: DelegateProxy<NMFMapView, NMFMapViewDelegate>, DelegateProxyType, NMFMapViewDelegate {

    public weak private(set) var mapView: NMFMapView?

    // Rx 이벤트를 위한 subject 추가
    let didChangePositionSubject = PublishSubject<Void>()
    let idleAtPositionSubject = PublishSubject<Void>()

    init(mapView: NMFMapView) {
        self.mapView = mapView
        super.init(parentObject: mapView, delegateProxy: NMFMapViewDelegateProxy.self)
    }

    static func registerKnownImplementations() {
        self.register { NMFMapViewDelegateProxy(mapView: $0) }
    }

    static func currentDelegate(for object: NMFMapView) -> NMFMapViewDelegate? {
        return object.delegate
    }

    static func setCurrentDelegate(_ delegate: NMFMapViewDelegate?, to object: NMFMapView) {
        object.delegate = delegate
    }

    // 네이버맵의 Delegate 메서드를 Rx로 전달
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        didChangePositionSubject.onNext(())
        _forwardToDelegate?.mapView?(mapView, cameraDidChangeByReason: reason, animated: animated)
    }

    func mapViewIdle(_ mapView: NMFMapView) {
        idleAtPositionSubject.onNext(())
        forwardToDelegate()?.mapViewIdle?(mapView)
    }
}

extension Reactive where Base: NMFMapView {
    var delegate: DelegateProxy<NMFMapView, NMFMapViewDelegate> {
        return NMFMapViewDelegateProxy.proxy(for: base)
    }

    var didChangePosition: Observable<Void> {
        let proxy = NMFMapViewDelegateProxy.proxy(for: base)
        return proxy.didChangePositionSubject.asObservable()
    }

    var idleAtPosition: Observable<Void> {
        let proxy = NMFMapViewDelegateProxy.proxy(for: base)
        return proxy.idleAtPositionSubject.asObservable()
    }
}
