import UIKit

// Protocol that presented view controllers must conform to
public protocol PPModalPresentable: AnyObject {
    /// The height of the modal view. If nil, falls back to the view's own height.
    var modalHeight: CGFloat? { get }
    /// The background dimming color behind the modal view
    var backgroundColor: UIColor { get }
    /// The corner radius for the modal's top corners
    var cornerRadius: CGFloat { get }
}
