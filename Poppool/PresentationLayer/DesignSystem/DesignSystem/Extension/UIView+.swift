import UIKit

public extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.3 // 애니메이션 지속 시간
        animation.values = [-3, 3, -1, 1, 0] // 흔들림 범위
        layer.add(animation, forKey: "shake")
    }
}
