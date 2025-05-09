import UIKit

import Infrastructure

private struct PPModalConstants {
    static let animationDuration: TimeInterval = 0.2
    static let presentAnimationOptions: UIView.AnimationOptions = .curveEaseOut
    static let dismissAnimationOptions: UIView.AnimationOptions = .curveEaseIn
}

// modal의 subView와 상태를 들고있는 매니저
private class PPModalManager {
    weak var presentingVC: UIViewController?
    weak var presentedViewController: (UIViewController & PPModalPresentable)?
    var dimmingView: UIView?
    var containerView: UIView?

    init(presenting: UIViewController) {
        self.presentingVC = presenting
    }
}

extension UIViewController {
    // MARK: - Storage
    private struct PPModalStorage {
        static var managers: [ObjectIdentifier: PPModalManager] = [:]
    }

    private var pp_manager: PPModalManager {
        let id = ObjectIdentifier(self)

        if let modalManager = PPModalStorage.managers[id] {
            return modalManager
        }

        let modalManager = PPModalManager(presenting: self)
        PPModalStorage.managers[id] = modalManager

        return modalManager
    }

    // MARK: - Present as Bottom Sheet
    /// view controller를 bottom-sheet modal처럼 present 해줍니다
    public func PPPresent(_ viewController: UIViewController & PPModalPresentable, animated: Bool = true) {
        let manager = pp_manager
        manager.presentedViewController = viewController

        // presentingView에 dimming을 조절
        let dimView = UIView(frame: view.bounds)
        dimView.backgroundColor = viewController.backgroundColor
        dimView.alpha = 0
        dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(dimView)
        manager.dimmingView = dimView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePPTap(_:)))
        dimView.addGestureRecognizer(tapGesture)

        // 높이를 결정. 값이 주워진다면 해당 값을 쓰고, 없다면 view의 기본 frame을 씀
        let height = viewController.modalHeight ?? viewController.view.frame.height
        let container = UIView(frame: CGRect(
            x: 0,
            y: view.bounds.height,
            width: view.bounds.width,
            height: height
        ))
        container.backgroundColor = .clear
        container.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        view.addSubview(container)
        manager.containerView = container

        // Embed child
        addChild(viewController)
        viewController.view.frame = container.bounds
        viewController.view.layer.cornerRadius = viewController.cornerRadius
        viewController.view.clipsToBounds = true
        container.addSubview(viewController.view)
        viewController.didMove(toParent: self)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePPPan(_:)))
        container.addGestureRecognizer(pan)

        // Animate in
        let animateIn = {
            dimView.alpha = 1
            container.frame.origin.y = self.view.bounds.height - height
        }
        if animated {
            UIView.animate(
                withDuration: PPModalConstants.animationDuration,
                delay: 0,
                options: PPModalConstants.presentAnimationOptions,
                animations: animateIn,
                completion: nil
            )
        } else {
            animateIn()
        }
    }

    @objc private func handlePPTap(_ gesture: UITapGestureRecognizer) {
        PPDismiss(animated: true)
    }

    // MARK: - Dismiss
    /// bottom-sheet modal을 Dismiss 합니다.
    func PPDismiss(animated: Bool = true) {
        guard let manager = PPModalStorage.managers[ObjectIdentifier(self)],
              let container = manager.containerView,
              let dimView = manager.dimmingView else { return }

        let finish = {
            if let vc = manager.presentedViewController {
                vc.willMove(toParent: nil)
                vc.view.removeFromSuperview()
                vc.removeFromParent()
            }
            dimView.removeFromSuperview()
            container.removeFromSuperview()
            PPModalStorage.managers.removeValue(forKey: ObjectIdentifier(self))
        }

        let animateOut = {
            container.frame.origin.y = self.view.bounds.height
            dimView.alpha = 0
        }
        if animated {
            UIView.animate(
                withDuration: PPModalConstants.animationDuration,
                delay: 0,
                options: PPModalConstants.dismissAnimationOptions,
                animations: animateOut,
                completion: { _ in finish() }
            )
        } else {
            animateOut()
            finish()
        }
    }

    // MARK: - Pan Gesture Handler
    @objc private func handlePPPan(_ pan: UIPanGestureRecognizer) {
        guard let manager = PPModalStorage.managers[ObjectIdentifier(self)],
              let container = manager.containerView,
              let dimView = manager.dimmingView,
              let vc = manager.presentedViewController else { return }

        let translation = pan.translation(in: container)
        let velocity = pan.velocity(in: container)
        let height = vc.modalHeight ?? vc.view.frame.height
        let threshold: CGFloat = 100

        switch pan.state {
        case .changed:
            let minY = view.bounds.height - height
            let newY = max(minY, container.frame.origin.y + translation.y)
            container.frame.origin.y = newY
            let progress = 1 - ((newY - minY) / height)
            dimView.alpha = progress
            pan.setTranslation(.zero, in: container)

        case .ended:
            let minY = view.bounds.height - height
            let shouldDismiss = velocity.y > threshold || container.frame.origin.y > minY + height / 2
            let animate = {
                if shouldDismiss {
                    container.frame.origin.y = self.view.bounds.height
                    dimView.alpha = 0
                } else {
                    container.frame.origin.y = minY
                    dimView.alpha = 1
                }
            }
            UIView.animate(
                withDuration: PPModalConstants.animationDuration,
                delay: 0,
                options: PPModalConstants.presentAnimationOptions,
                animations: animate,
                completion: { _ in if shouldDismiss { self.PPDismiss(animated: false) } }
            )
        default:
            break
        }
    }
}

// Convenience dismiss inside presented VC
public extension PPModalPresentable where Self: UIViewController {
    func dismissModal(animated: Bool = true) {
        parent?.PPDismiss(animated: animated)
    }
}
