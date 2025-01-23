import RxSwift
import RxCocoa
import GoogleMaps

class GMSMapViewDelegateProxy: DelegateProxy<GMSMapView, GMSMapViewDelegate>, DelegateProxyType, GMSMapViewDelegate {

    public private(set) weak var mapView: GMSMapView?
    let didChangePositionSubject = PublishSubject<Void>()
    let idleAtPositionSubject = PublishSubject<Void>()

    init(mapView: GMSMapView) {
        self.mapView = mapView
        super.init(parentObject: mapView, delegateProxy: GMSMapViewDelegateProxy.self)
    }

    static func registerKnownImplementations() {
        self.register { mapView in
            GMSMapViewDelegateProxy(mapView: mapView)
        }
    }

    static func currentDelegate(for object: GMSMapView) -> GMSMapViewDelegate? {
        return object.delegate
    }

    static func setCurrentDelegate(_ delegate: GMSMapViewDelegate?, to object: GMSMapView) {
        object.delegate = delegate
    }

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        didChangePositionSubject.onNext(())
        self.forwardToDelegate()?.mapView?(mapView, didChange: position)
    }

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        idleAtPositionSubject.onNext(())
        self.forwardToDelegate()?.mapView?(mapView, idleAt: position)
    }
}
