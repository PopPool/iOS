import ReactorKit
import RxSwift
import CoreLocation

final class MapReactor: Reactor {
   // MARK: - Reactor
   enum Action {
       case viewDidLoad
       case searchTapped(String)
       case locationButtonTapped
       case listButtonTapped
       case filterTapped(FilterType?)   
       case filterUpdated(FilterType, [String])
       case clearFilters(FilterType)
       case updateBothFilters(locations: [String], categories: [String])  // 새로 추가

   }

   enum Mutation {
       case setSearchResult(MapPopUpStore?)
       case setActiveFilter(FilterType?)
       case setLocationFilters([String])
       case setCategoryFilters([String])
       case updateLocationDisplay(String)
       case updateCategoryDisplay(String)
       case clearLocationFilters
       case clearCategoryFilters
       case updateBothFilters(locations: [String], categories: [String])  // 새로 추가
       case setToastMessage(String)        // 토스트 메시지


   }

   struct State {
       var searchResult: MapPopUpStore? = nil
       var toastMessage: String? = nil
       var activeFilterType: FilterType?
       var selectedLocationFilters: [String] = []
       var selectedCategoryFilters: [String] = []
       var locationDisplayText: String = "지역선택"
       var categoryDisplayText: String = "카테고리"
   }

   let initialState: State
   private let useCase: MapUseCase

   init(useCase: MapUseCase) {
       self.useCase = useCase
       self.initialState = State()
   }

   func mutate(action: Action) -> Observable<Mutation> {
       switch action {
       case let .searchTapped(query):
             return useCase.searchStores(query: query, categories: [])
                 .flatMap { results -> Observable<Mutation> in
                     if let firstResult = results.first {
                         return .just(.setSearchResult(firstResult))
                     } else {
                         return .just(.setToastMessage("검색 결과가 없습니다."))
                     }
                 }
       case let .filterTapped(filterType):
           return .just(.setActiveFilter(filterType))

       case let .filterUpdated(type, values):
           switch type {
           case .location:
               let displayText = formatDisplayText(values, defaultText: "지역선택")
               return .concat([
                   .just(.setLocationFilters(values)),
                   .just(.updateLocationDisplay(displayText))
               ])
           case .category:
               let displayText = formatDisplayText(values, defaultText: "카테고리")
               return .concat([
                   .just(.setCategoryFilters(values)),
                   .just(.updateCategoryDisplay(displayText))
               ])
           }
       case let .updateBothFilters(locations, categories):
               print("[DEBUG] 📝 Updating both filters - Locations: \(locations), Categories: \(categories)")
               return .concat([
                   .just(.updateBothFilters(locations: locations, categories: categories)),
                   .just(.updateLocationDisplay(formatDisplayText(locations, defaultText: "지역선택"))),
                   .just(.updateCategoryDisplay(formatDisplayText(categories, defaultText: "카테고리")))
               ])


       case let .clearFilters(type):
           switch type {
           case .location:
               return .concat([
                   .just(.clearLocationFilters),
                   .just(.updateLocationDisplay("지역선택"))
               ])
           case .category:
               return .concat([
                   .just(.clearCategoryFilters),
                   .just(.updateCategoryDisplay("카테고리"))
               ])
           }

       default:
           return .empty()
       }
   }

   private func formatDisplayText(_ values: [String], defaultText: String) -> String {
       guard !values.isEmpty else { return defaultText }
       return values.count > 1 ? "\(values[0]) 외 \(values.count - 1)개" : values[0]
   }

   func reduce(state: State, mutation: Mutation) -> State {
       var newState = state

       
       switch mutation {
       case let .setSearchResult(result):
              newState.searchResult = result
       case let .setToastMessage(message):
           newState.toastMessage = message
    
       case let .setActiveFilter(filterType):
           newState.activeFilterType = filterType
           print("[DEBUG] 🎯 Active Filter Changed: \(String(describing: filterType))")

       case let .setLocationFilters(filters):
           newState.selectedLocationFilters = filters
           print("Updating selectedLocationFilters to: \(filters)")

       case let .setCategoryFilters(filters):
           newState.selectedCategoryFilters = filters
           print("[DEBUG] 🔄 Category Filters Updated: \(filters)")

       case let .updateLocationDisplay(text):
           newState.locationDisplayText = text

       case let .updateCategoryDisplay(text):
           newState.categoryDisplayText = text

       case .clearLocationFilters:
           newState.selectedLocationFilters = []

       case .clearCategoryFilters:
           newState.selectedCategoryFilters = []
       case let .updateBothFilters(locations, categories):
           print("[DEBUG] 💾 Reducing both filters update")
           print("[DEBUG] 📍 Previous state - Locations: \(newState.selectedLocationFilters)")
           print("[DEBUG] 🏷️ Previous state - Categories: \(newState.selectedCategoryFilters)")

           newState.selectedLocationFilters = locations
           newState.selectedCategoryFilters = categories

           print("[DEBUG] ✅ Updated state - Locations: \(newState.selectedLocationFilters)")
           print("[DEBUG] ✅ Updated state - Categories: \(newState.selectedCategoryFilters)")

           return newState
       }

       

       return newState
   }
}
