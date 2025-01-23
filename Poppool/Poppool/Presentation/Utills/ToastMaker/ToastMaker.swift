//
//  ToastMaker.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/25/24.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class ToastMaker {
    
    // MARK: - Properties
    
    /// 현재 디바이스 최상단 Window를 지정
    static var window: UIWindow? {
        return UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }
    }
    
    /// 최상단의 ViewController를 가져오는 메서드
    private static func topViewController(
        _ rootViewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
    ) -> UIViewController? {
        if let navigationController = rootViewController as? UINavigationController {
            return topViewController(navigationController.visibleViewController)
        }
        if let tabBarController = rootViewController as? UITabBarController {
            return topViewController(tabBarController.selectedViewController)
        }
        if let presentedViewController = rootViewController?.presentedViewController {
            return topViewController(presentedViewController)
        }
        return rootViewController
    }
    
    private static var currentToast: ToastView?
    private static var currentBookMarkToast: BookMarkToastView?
    private static var disposeBag = DisposeBag()
}

extension ToastMaker {
    
    // MARK: - Method
    
    /// 토스트 메시지를 생성하는 메서드
    /// - Parameter message: 토스트 메세지에 담길 String 타입
    static func createToast(message: String) {
        
        currentToast?.removeFromSuperview()
        currentToast = nil
        let toastMSG = ToastView(message: message)
        guard let window = window else { return }
        window.addSubview(toastMSG)
        currentToast = toastMSG
        
        toastMSG.snp.makeConstraints { make in
            make.bottom.equalTo(window.snp.bottom).inset(120)
            make.centerX.equalTo(window.snp.centerX)
        }
        
        UIView.animate(
            withDuration: 0.3,
            delay: 4,
            options: .curveEaseOut
        ) {
            toastMSG.alpha = 0
        } completion: { _ in
            toastMSG.removeFromSuperview()
            if currentToast == toastMSG { currentToast = nil }
        }
    }
    
    /// 토스트 메시지를 생성하는 메서드
    /// - Parameter message: 토스트 메세지에 담길 String 타입
    static func createBookMarkToast(isBookMark: Bool) {
        
        currentBookMarkToast?.removeFromSuperview()
        currentBookMarkToast = nil
        disposeBag = DisposeBag()
        guard let currentVC = topViewController() else { return }
        let toastMSG = BookMarkToastView(isBookMark: isBookMark)
        currentVC.view.addSubview(toastMSG)
        currentBookMarkToast = toastMSG
        toastMSG.moveButton.rx.tap
            .withUnretained(currentVC)
            .subscribe(onNext: { (owner, _) in
                let nextController = MyPageBookmarkController()
                nextController.reactor = MyPageBookmarkReactor()
                owner.navigationController?.pushViewController(nextController, animated: true)
            })
            .disposed(by: disposeBag)
        
        if isBookMark {
            toastMSG.snp.makeConstraints { make in
                make.bottom.equalTo(currentVC.view.snp.bottom).inset(120)
                make.leading.trailing.equalToSuperview().inset(20)
            }
        } else {
            toastMSG.snp.makeConstraints { make in
                make.bottom.equalTo(currentVC.view.snp.bottom).inset(120)
                make.centerX.equalTo(currentVC.view.snp.centerX)
            }
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            UIView.animate(
                withDuration: 0.3, delay: 0,
                options: .curveEaseOut
            ) {
                toastMSG.alpha = 0
            } completion: { _ in
                toastMSG.removeFromSuperview()
                if currentBookMarkToast == toastMSG { currentBookMarkToast = nil }
                disposeBag = DisposeBag()
            }
        }
        
    }
}
