import Foundation

final class Category: NSCopying, Equatable {
    static func == (lhs: Category, rhs: Category) -> Bool { return lhs === rhs }

    var items: [TagCollectionViewCell.Input]

    init(items: [TagCollectionViewCell.Input] = []) {
        self.items = items
    }

    func contains(id: Int64) -> Bool {
        items.contains { $0.id == id }
    }

    func copy(with zone: NSZone? = nil) -> Any {
        return Category(items: self.items)
    }

    func toggleItemSelection(by categoryID: Int64) {
        guard let index = items.firstIndex(where: { $0.id == categoryID }) else { return }
        items[index].isSelected.toggle()
    }

    func turnOffAllItemSelection() {
        for index in items.indices { items[index].isSelected = false }
    }
}
