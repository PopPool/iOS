import Foundation

open class BaseCoordinator: Coordinator {
    public var children = [Coordinator]()
    open func start() { fatalError("\(#file), \(#function) Error") }

    public init() { }

    func add(child: Coordinator) { children.append(child) }
    func remove(child: Coordinator) { children.removeAll { $0 === child} }
}
