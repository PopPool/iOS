import UIKit

import DesignSystem

public protocol LoginFactory {
    func make(isSubLogin: Bool) -> BaseViewController
}
