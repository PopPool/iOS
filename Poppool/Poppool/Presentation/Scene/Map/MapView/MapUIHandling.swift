import UIKit
import NMapsMap
import SnapKit

/// 지도 UI 상태 및 애니메이션을 처리하는 프로토콜
protocol MapUIHandling: AnyObject {

    var mainView: MapView { get }
    var carouselView: MapPopupCarouselView { get }
    var modalState: ModalState { get set }
    var listViewTopConstraint: Constraint? { get }
    var filterContainerBottomY: CGFloat { get }


    func animateToState(_ state: ModalState)
    func adjustMapViewAlpha(for offset: CGFloat, minOffset: CGFloat, maxOffset: CGFloat)
    func updateMapViewAlpha(for offset: CGFloat, minOffset: CGFloat, maxOffset: CGFloat)
    func showNoMarkersToast()
    func setStoreCardHidden(_ hidden: Bool, animated: Bool)
    func updateMarkersForCluster(stores: [MapPopUpStore])
}

enum ModalState {
    case top
    case middle
    case bottom
}
