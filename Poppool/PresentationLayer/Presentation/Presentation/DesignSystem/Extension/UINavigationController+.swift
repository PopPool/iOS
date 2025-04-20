//
//  UINavigationController+.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/7/25.
//

import UIKit

extension UINavigationController {
    func popViewController(animated: Bool, completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
        }
        self.popViewController(animated: animated)
        CATransaction.commit()
    }
}
