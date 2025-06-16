import UIKit

import DesignSystem

public protocol FilterSelectorFactory {
    func make() -> BaseViewController & PPModalPresentable
}
