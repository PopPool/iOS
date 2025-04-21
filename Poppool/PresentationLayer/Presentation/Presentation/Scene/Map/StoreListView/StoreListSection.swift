import RxDataSources

struct StoreListSection {
//    var headerTitle: String  
    var items: [StoreItem]
}

extension StoreListSection: SectionModelType {
    typealias Item = StoreItem

    init(original: StoreListSection, items: [StoreItem]) {
        self = original
        self.items = items
    }
}
