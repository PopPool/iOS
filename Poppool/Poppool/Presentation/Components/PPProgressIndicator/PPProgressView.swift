//
//  PPProgressView.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/25/24.
//

import Foundation
import SnapKit
import UIKit

final class PPProgressView: UIView {

    /// CMTPProgressView Animation Type
    enum ProgressFillAnimation {
        case fromLeft
        case fromRight
    }

    // MARK: - Components
    private var selectedView: UIView = {
        let view = UIView()
        view.backgroundColor = . systemBlue // 수정 필요
        view.layer.cornerRadius = 1
        return view
    }()

    private var normalView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground // 수정 필요
        view.layer.cornerRadius = 1
        return view
    }()

    /// CMTPProgressView 초기화
    /// - Parameter isSelected: 선택 여부
    init(isSelected: Bool) {
        self.selectedView.isHidden = !isSelected
        super.init(frame: .zero)
        setUpConstraints()
        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SetUp
private extension PPProgressView {

    /// 뷰 설정
    func setUp() {
        self.clipsToBounds = true
    }

    /// 제약 조건 설정
    func setUpConstraints() {
        self.addSubview(normalView)
        self.addSubview(selectedView)

        self.snp.makeConstraints { make in
            make.height.equalTo(4)
        }
        normalView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(3)
        }
        selectedView.snp.makeConstraints { make in
            make.size.bottom.equalToSuperview()
            make.leading.equalToSuperview()
        }
    }
}

extension PPProgressView {

    /// 선택된 뷰를 채우는 애니메이션
    /// - Parameter option: 애니메이션 시작 방향
    func fillAnimation(option: ProgressFillAnimation) {
        let viewWitdh = self.frame.width
        switch option {
        case .fromLeft:
            self.addSubview(selectedView)
            selectedView.snp.remakeConstraints({ make in
                make.size.bottom.equalToSuperview()
                make.leading.equalToSuperview().inset(-viewWitdh)
            })
            self.layoutIfNeeded()
            self.selectedView.isHidden = false

            UIView.animate(withDuration: 0.2, animations: {
                self.selectedView.snp.updateConstraints { make in
                    make.leading.equalToSuperview()
                }
                self.layoutIfNeeded()
            })
        case .fromRight:
            self.addSubview(selectedView)
            selectedView.snp.remakeConstraints({ make in
                make.size.bottom.equalToSuperview()
                make.leading.equalToSuperview().inset(viewWitdh)
            })
            self.layoutIfNeeded()
            self.selectedView.isHidden = false

            UIView.animate(withDuration: 0.2, animations: {
                self.selectedView.snp.updateConstraints { make in
                    make.leading.equalToSuperview()
                }
                self.layoutIfNeeded()
            })
        }
    }

    /// 선택된 뷰를 사라지게 하는 애니메이션
    /// - Parameter option: 애니메이션 시작 방향
    func disappearAnimation(option: ProgressFillAnimation) {
        let viewWitdh = self.frame.width
        switch option {
        case .fromLeft:
            UIView.animate(withDuration: 0.2, animations: {
                self.selectedView.snp.updateConstraints { make in
                    make.leading.equalToSuperview().inset(viewWitdh)
                }
                self.layoutIfNeeded()
            }) { _ in
                self.selectedView.removeFromSuperview()
            }
        case .fromRight:
            UIView.animate(withDuration: 0.2, animations: {
                self.selectedView.snp.updateConstraints { make in
                    make.leading.equalToSuperview().inset(-viewWitdh)
                }
                self.layoutIfNeeded()
            }) { _ in
                self.selectedView.removeFromSuperview()
            }
        }
    }
}
