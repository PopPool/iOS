import UIKit

public protocol HeaderLayoutProvidable {
    func makeHeaderLayout(_ elementKind: String) -> NSCollectionLayoutBoundarySupplementaryItem
}
