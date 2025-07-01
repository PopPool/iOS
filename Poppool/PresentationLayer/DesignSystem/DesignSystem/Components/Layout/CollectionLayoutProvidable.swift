import UIKit

public protocol CollectionLayoutProvidable {
    func makeLayout() -> NSCollectionLayoutSection
}
