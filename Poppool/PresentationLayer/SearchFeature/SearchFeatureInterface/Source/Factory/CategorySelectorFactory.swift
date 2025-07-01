import UIKit

import DesignSystem

public protocol CategorySelectorFactory {
    func make() -> BaseViewController & PPModalPresentable
}
