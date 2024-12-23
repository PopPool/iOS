
import FloatingPanel
import UIKit

class StoreListPanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .half

    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 94, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.6, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: -100, edge: .bottom, referenceGuide: .safeArea) // 완전히 내림
        ]
    }

    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        return 0.0
    }

    func shouldMove(for proposedTargetState: FloatingPanelState) -> Bool {
        return true
    }

    var cornerRadius: CGFloat { return 0 } 

    func surfaceLayout(for size: CGSize) -> NSCollectionLayoutDimension {
        return .fractionalWidth(1.0)
    }
}
