//import GoogleMaps
//
//class CustomClusterRenderer: GMUDefaultClusterRenderer {
//    override func willRenderMarker(_ marker: GMSMarker) {
//        super.willRenderMarker(marker)
//        // 클러스터일 경우 처리
//        if let cluster = marker.userData as? GMUCluster {
//            let customView = MapMarker()
//            // 예: 클러스터의 이름과 count를 injection
//            customView.injection(with: .init(isSelected: false, isCluster: true, regionName: cluster.clusterIdentifier, count: cluster.count))
//            // marker의 iconView에 적용
//            marker.iconView = customView
//        }
//    }
//}
