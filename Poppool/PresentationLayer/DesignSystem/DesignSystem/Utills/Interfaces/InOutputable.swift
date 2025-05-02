import UIKit

public protocol InOutputable: Inputable, Outputable { }

public protocol Inputable: Hashable {
    associatedtype Input
    func injection(with input: Input)
}

public protocol Outputable {
    associatedtype Output
}
