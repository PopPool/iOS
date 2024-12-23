//
//  StoreListPanelLayout.swift
//  Poppool
//
//  Created by 김기현 on 12/20/24.
//

import FloatingPanel
import UIKit

class StoreListPanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .half

    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            // 스택뷰 (검색바 + 필터칩) 바로 아래에 맞춰서 올라오도록 설정
            .full: FloatingPanelLayoutAnchor(absoluteInset: 90, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.6, edge: .bottom, referenceGuide: .safeArea)
        ]
    }




    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        return 0.0
    }

    // 스크롤 뷰와의 상호작용 방지
    func shouldMove(for proposedTargetState: FloatingPanelState) -> Bool {
        return true
    }

    // 패널의 모서리 둥글기 설정
    var cornerRadius: CGFloat { return 0 }  // 페이지처럼 보이도록 모서리 둥글기 제거

    // 화면 전체를 덮도록 surface 레이아웃 설정
    func surfaceLayout(for size: CGSize) -> NSCollectionLayoutDimension {
        return .fractionalWidth(1.0)
    }
}
