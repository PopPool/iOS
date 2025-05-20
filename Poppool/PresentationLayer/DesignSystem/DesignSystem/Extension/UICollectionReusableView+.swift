import UIKit

public extension UICollectionReusableView {
    static var identifiers: String {
        return String(describing: self)
    }
}
