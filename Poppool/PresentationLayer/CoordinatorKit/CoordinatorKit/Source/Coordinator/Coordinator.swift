import Foundation

public protocol Coordinator: AnyObject {
    var children: [Coordinator] { get set }
    func start()
}
