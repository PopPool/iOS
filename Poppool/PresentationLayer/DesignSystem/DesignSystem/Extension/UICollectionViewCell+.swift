import UIKit

public extension UICollectionViewCell {
    public static var identifiers: String {
        return String(describing: self)
    }
}
