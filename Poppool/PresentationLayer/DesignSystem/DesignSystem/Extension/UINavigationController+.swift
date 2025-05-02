import UIKit

public extension UINavigationController {
    func popViewController(animated: Bool, completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
        }
        self.popViewController(animated: animated)
        CATransaction.commit()
    }
}
