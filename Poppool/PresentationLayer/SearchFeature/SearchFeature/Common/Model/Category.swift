import Foundation

import RxSwift

final class Category: NSCopying, Equatable {
    func copy(with zone: NSZone? = nil) -> Any {
        return Category(items: self.items)
    }

    static func == (lhs: Category, rhs: Category) -> Bool { return lhs === rhs }

    static let shared = Category()
    static let valueChanged = PublishSubject<Void>()

    /// 선택된 아이템들만 들어가는 인스턴스
    private var _items: [TagModel]
    var items: [TagModel] {
        get { _items }
        set { _items = newValue.isEmpty ? [Category.defaultItem] : newValue }
    }

    private static let defaultItem = TagModel(title: "카테고리", isSelected: false, isCancelable: false)

    private init(items: [TagModel] = [Category.defaultItem]) {
        self._items = items.isEmpty ? [Category.defaultItem] : items
    }
}

// MARK: - Functions
extension Category {

    func contains(id: Int) -> Bool {
        items.contains { $0.id == id }
    }

    func toggleItemSelection(by categoryID: Int) {
        guard let index = items.firstIndex(where: { $0.id == categoryID }) else { return }
        items[index].isSelected.toggle()
    }

    func turnOffAllItemSelection() {
        for index in items.indices { items[index].isSelected = false }
    }

    func resetItems() {
        items = [Category.defaultItem]
    }

    func getSelectedCategoryIDs() -> [Int] {
        return items.filter { $0.isSelected == true }.compactMap { $0.id }
    }

    func getCancelableCategoryItems() -> [TagModel] {
        if items == [Category.defaultItem] { return items } else { return items.filter { $0.isSelected == true }.map { $0.cancelableItem() } }
    }

    func removeItem(by categoryID: Int) {
        items.removeAll { $0.id == categoryID }
    }
}
