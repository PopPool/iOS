import NMapsMap
import UIKit

protocol MarkerStyling {
    func applyStyle(
        to marker: NMFMarker,
        selected: Bool,
        isCluster: Bool,
        count: Int,
        regionName: String
    )
}

struct DefaultMarkerStyler: MarkerStyling {
    func applyStyle(
        to marker: NMFMarker,
        selected: Bool,
        isCluster: Bool,
        count: Int,
        regionName: String
    ) {
        // MapMarker 인스턴스 생성
        let markerView = MapMarker()

        // 마커 뷰에 속성 주입
        markerView.injection(with: MapMarker.Input(
            isSelected: selected,
            isCluster: isCluster,
            regionName: regionName,
            count: count,
            isMultiMarker: count > 1
        ))

        markerView.backgroundColor = .clear

        // 레이아웃 업데이트
        markerView.layoutIfNeeded()
        let fittingSize = markerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        markerView.frame = CGRect(origin: .zero, size: fittingSize)

        if let markerImage = convertViewToImage(markerView) {
            marker.iconImage = NMFOverlayImage(image: markerImage)

            marker.width = fittingSize.width
            marker.height = fittingSize.height
        } else {
            if selected {
                marker.iconImage = NMFOverlayImage(name: "TapMarker")
                marker.width = 44
                marker.height = 44
            } else if isCluster {
                marker.iconImage = NMFOverlayImage(name: "cluster_marker")
                marker.width = 36
                marker.height = 36
            } else {
                marker.iconImage = NMFOverlayImage(name: "Marker")
                marker.width = 32
                marker.height = 32
            }
        }

        marker.captionText = ""

        // 마커 앵커 설정
        marker.anchor = CGPoint(x: 0.5, y: 1.0)
    }

    private func convertViewToImage(_ view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        view.layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

struct FullScreenMarkerStyler: MarkerStyling {
    func applyStyle(
        to marker: NMFMarker,
        selected: Bool,
        isCluster: Bool,
        count: Int,
        regionName: String
    ) {
        let markerView = MapMarker()
        markerView.injection(with: MapMarker.Input(
            isSelected: true,
            isCluster: isCluster,
            regionName: regionName,
            count: count,
            isMultiMarker: count > 1
        ))

        markerView.backgroundColor = .clear
        let fittingSize = markerView.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
        let scale: CGFloat = 1.2
        markerView.frame = CGRect(origin: .zero, size: CGSize(width: fittingSize.width * scale, height: fittingSize.height * scale))
        markerView.layoutIfNeeded()

        if let markerImage = convertViewToImage(markerView) {
            marker.iconImage = NMFOverlayImage(image: markerImage)
            marker.width = fittingSize.width * scale
            marker.height = fittingSize.height * scale
        } else {
            marker.iconImage = NMFOverlayImage(name: "TapMarker")
            marker.width = 44
            marker.height = 44
        }

        marker.captionText = ""
        marker.anchor = CGPoint(x: 0.5, y: 1.0)
    }

    private func convertViewToImage(_ view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        view.layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
