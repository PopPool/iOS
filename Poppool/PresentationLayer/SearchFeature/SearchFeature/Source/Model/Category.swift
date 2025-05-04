import Foundation

public final class Category: NSCopying, Equatable {
    public static func == (lhs: Category, rhs: Category) -> Bool { return lhs === rhs }

    var items: [TagCollectionViewCell.Input]

    init(items: [TagCollectionViewCell.Input] = []) {
        self.items = items
    }

    func contains(id: Int) -> Bool {
        items.contains { $0.id == id }
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        return Category(items: self.items)
    }

    func toggleItemSelection(by categoryID: Int) {
        guard let index = items.firstIndex(where: { $0.id == categoryID }) else { return }
        items[index].isSelected.toggle()
    }

    func turnOffAllItemSelection() {
        for index in items.indices { items[index].isSelected = false }
    }
}
