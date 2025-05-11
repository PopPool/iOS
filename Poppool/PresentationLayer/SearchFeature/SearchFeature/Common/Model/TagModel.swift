import Foundation

public struct TagModel: Hashable {
    var title: String?
    var id: Int? = nil
    var isSelected: Bool = false
    var isCancelable: Bool = true

    func selectionToggledItem() -> TagModel {
        let toggledSelection = !isSelected
        return TagModel(title: self.title, id: self.id, isSelected: toggledSelection, isCancelable: self.isCancelable)
    }

    func cancelableItem() -> TagModel {
        return TagModel(title: self.title, id: self.id, isSelected: self.isSelected, isCancelable: true)
    }
}
