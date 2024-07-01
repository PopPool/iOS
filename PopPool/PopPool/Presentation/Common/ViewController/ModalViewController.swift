//
//  ModalAlertCPNT.swift
//  PopPool
//
//  Created by Porori on 6/28/24.
//

import Foundation
import UIKit

// MARK: - Properties
class ModalViewController: UIViewController {
    // 모달 화면 뒷 배경
    private lazy var dimmedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    // 전체 콘텐츠를 감싸는 View
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 교체가 가능한 View
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    private let minimumHeight: CGFloat = 80 // autolayout 기준 - 고정된 값은 제외하도록!
    private let minimumPanHeight: CGFloat = 20
    private let maxDimAlpha: CGFloat = 0.8
}

// MARK: - Lifecycle
extension ModalViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpConstraint()
        setupGestures()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePresent()
    }
}

// MARK: - Methods
extension ModalViewController {
    private func setUpConstraint() {
        view.addSubview(dimmedView)
        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // ModalVC가 담을 콘텐츠 컨테이너
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.greaterThanOrEqualTo(view.snp.top).inset(minimumHeight)
        }
        
        // 각 ModalVC별로 담는 콘텐츠
        containerView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func setContent(content: UIView) {
        // dynamic height 값 설정 확인 이후
        // scrollView내 contentView를 심어놓는 구조로 변경 예정
        contentView.addSubview(content)
        content.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.layoutIfNeeded()
    }
    
    private func animatePresent() {
        dimmedView.alpha = 0
        
        containerView.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.containerView.transform = .identity
            self?.view.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.dimmedView.alpha = self.maxDimAlpha
        }
    }
    
    func dismissBottomSheet() {
        UIView.animate(withDuration: 0.2, animations: {  [weak self] in
            guard let self = self else { return }
            self.containerView.frame.origin.y = self.view.frame.height
        }, completion: {  [weak self] _ in
            self?.dismiss(animated: false)
        })
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapDimmedView))
        dimmedView.addGestureRecognizer(tapGesture)
        
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        contentView.addGestureRecognizer(dragGesture)
    }
    
    // 내려가는 gestureRecognizer 적용
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let transition = gesture.translation(in: view)
        let isDraggedDown = transition.y > 0
        guard isDraggedDown else { return }
        
        // gesture를 통해 발생하는 view의 y 좌표 값. 0을 기점으로 시작
        let changingHeight = transition.y
        
        // containerView의 상단까지 포함한 길이 값
        let currentY = self.view.frame.height - self.containerView.frame.height
        
        switch gesture.state {
        case .changed:
            // containerView가 존재하는 view에서의 y좌표 값
            self.containerView.frame.origin.y = currentY + changingHeight
        case .ended:
            if changingHeight >= minimumPanHeight {
                dismissBottomSheet()
            }
        default:
            break
        }
    }
    
    @objc func handleTapDimmedView() {
        self.dismissBottomSheet()
    }
}

extension UIViewController {
    func presentViewControllerModally(vc: UIViewController) {
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
    }
}
