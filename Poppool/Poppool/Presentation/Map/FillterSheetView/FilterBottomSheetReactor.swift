import ReactorKit
import Foundation
import RxSwift

struct Location: Equatable {
    let main: String
    let sub: [String]
}

final class FilterBottomSheetReactor: Reactor {

    // MARK: - Action
    enum Action {
        case segmentChanged(Int)
        case resetFilters
        case applyFilters([String])
        case selectLocation(Int)
        case toggleSubRegion(String)
        case toggleCategory(String)
        case toggleAllSubRegions
    }

    // MARK: - Mutation
    enum Mutation {
        case setActiveSegment(Int)
        case resetFilters
        case applyFilters([String])
        case updateSelectedLocation(Int)
        case toggleSubRegionSelection(String)
        case toggleCategorySelection(String)
        case toggleAllSubRegions
        case updateSavedSubRegions([String])
        case updateSavedCategories([String])
        case forceSaveEnabled(Bool)
    }

    // MARK: - State
    struct State {
        var activeSegment: Int
        var selectedLocationIndex: Int?
        var selectedSubRegions: [String]
        var selectedCategories: [String]
        var locations: [Location]
        var categories: [String]
        var savedSubRegions: [String] = []
        var savedCategories: [String] = []
        var forceSaveEnabled: Bool = false

        var isSaveEnabled: Bool {
            return forceSaveEnabled || !selectedSubRegions.isEmpty || !selectedCategories.isEmpty
        }
    }

    var initialState: State

    // MARK: - Init
    init(savedSubRegions: [String] = [], savedCategories: [String] = []) {
        let initialLocations: [Location] = [
            Location(
                main: "서울",
                sub: [
                    "도봉/노원","강북/중랑","동대문/성북","중구/종로","성동/광진",
                    "송파/강동","동작/관악","서초/강남","은평/서대문/마포",
                    "영등포/구로","용산","양천/강서/금천"
                ]
            ),
            Location(
                main: "경기",
                sub: [
                    "포천/연천","동두천/양주/의정부","구리/남양주/가평",
                    "파주/고양/김포","용인/화성/수원","군포/의왕",
                    "과천/안양","부천/광명","시흥/안산",
                    "안성/평택/오산","성남/하남/광주","이천/여주/양평"
                ]
            ),
            Location(main: "인천", sub: ["부평", "송도"]),
            Location(
                main: "부산",
                sub: [
                    "중구","서구","동구","영도구","부산진구",
                    "동래구","남구","북구","해운대구","사하구",
                    "금정구","강서구","연제구","수영구","사상구",
                    "기장군"
                ]
            ),
            Location(main: "제주", sub: ["제주시", "서귀포시"]),
            Location(main: "광주", sub: ["동구", "서구", "남구", "북구", "광산구"]),
            Location(
                main: "대전",
                sub: ["동구", "중구", "서구", "유성구", "대덕구"]
            ),
            Location(
                main: "대구",
                sub: ["중구", "동구", "서구", "남구", "북구", "수성구", "달서구", "달성군"]
            ),
            Location(
                main: "울산",
                sub: ["중구", "남구", "동구", "북구", "울주군"]
            ),
            Location(main: "전북", sub: [""]),
            Location(main: "전남", sub: [""]),
            Location(main: "경북", sub: [""]),
            Location(main: "경남", sub: [""]),
            Location(main: "충남", sub: [""]),
            Location(main: "충북", sub: [""]),
            Location(main: "강원", sub: [""])
        ]

        self.initialState = State(
            activeSegment: 0,
            selectedLocationIndex: nil,
            selectedSubRegions: savedSubRegions,
            selectedCategories: savedCategories,
            locations: initialLocations,
            categories: [
                "게임", "라이프스타일", "반려동물", "뷰티", "스포츠",
                "애니메이션", "엔터테인먼트", "여행", "예술", "음식/요리",
                "키즈", "패션"
            ],
            savedSubRegions: savedSubRegions,
            savedCategories: savedCategories,
            forceSaveEnabled: false
        )

        if let location = savedSubRegions.first?.split(separator: "/").first.map(String.init),
           let index = initialLocations.firstIndex(where: { $0.main == location }) {
            self.initialState.selectedLocationIndex = index
        }
    }

    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .segmentChanged(let index):
            return Observable.just(.setActiveSegment(index))

        case .resetFilters:
            return Observable.concat([
                Observable.just(.resetFilters),
                Observable.just(.forceSaveEnabled(true))
            ])

        case .applyFilters:
            let activeSegment = currentState.activeSegment
            if activeSegment == 0 {
                return Observable.just(.updateSavedSubRegions(currentState.selectedSubRegions))
            } else {
                return Observable.just(.updateSavedCategories(currentState.selectedCategories))
            }

        case .selectLocation(let index):
            return Observable.just(.updateSelectedLocation(index))

        case .toggleSubRegion(let subRegion):
            return Observable.concat([
                Observable.just(.toggleSubRegionSelection(subRegion)),
                Observable.just(.forceSaveEnabled(false))
            ])

        case .toggleCategory(let category):
            return Observable.concat([
                Observable.just(.toggleCategorySelection(category)),
                Observable.just(.forceSaveEnabled(false))
            ])

        case .toggleAllSubRegions:
            return Observable.concat([
                Observable.just(.toggleAllSubRegions),
                Observable.just(.forceSaveEnabled(false))
            ])
        }
    }

    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setActiveSegment(let index):
            newState.activeSegment = index

        case .resetFilters:
            newState.selectedSubRegions = []
            newState.selectedCategories = []
            newState.savedSubRegions = []
            newState.savedCategories = []
            // 여기서 forceSaveEnabled는 나중에 setForceSaveEnabled가 적용됨
            break

        case .applyFilters(let combined):
            print("필터 적용: \(newState.selectedSubRegions + newState.selectedCategories)")

        case .updateSelectedLocation(let index):
            newState.selectedLocationIndex = index
            let selectedLocation = newState.locations[index]
            newState.selectedSubRegions = ["\(selectedLocation.main)전체"]

        case .updateSavedSubRegions(let subRegions):
            newState.savedSubRegions = subRegions
            newState.selectedSubRegions = subRegions

        case .updateSavedCategories(let categories):
            newState.savedCategories = categories
            newState.selectedCategories = categories

        case .toggleSubRegionSelection(let subRegion):
            if let selectedIndex = newState.selectedLocationIndex {
                let location = newState.locations[selectedIndex]
                let allKey = "\(location.main)전체"
                if subRegion == allKey {
                    newState.selectedSubRegions = newState.selectedSubRegions.contains(allKey) ? [] : [allKey]
                } else {
                    newState.selectedSubRegions.removeAll { $0 == allKey }
                    if newState.selectedSubRegions.contains(subRegion) {
                        newState.selectedSubRegions.removeAll { $0 == subRegion }
                    } else {
                        newState.selectedSubRegions.append(subRegion)
                    }
                    if Set(newState.selectedSubRegions).isSuperset(of: location.sub) {
                        newState.selectedSubRegions = [allKey]
                    }
                }
            }

        case .toggleCategorySelection(let category):
            newState.selectedCategories.toggleElement(category)

        case .toggleAllSubRegions:
            if let selectedIndex = newState.selectedLocationIndex {
                let location = newState.locations[selectedIndex]
                let allKey = "\(location.main)전체"
                newState.selectedSubRegions = newState.selectedSubRegions.contains(allKey) ? [] : [allKey]
            }

        case .forceSaveEnabled(let enabled):
            newState.forceSaveEnabled = enabled
        }
        return newState
    }
}

// MARK: - Array Extension
extension Array where Element: Equatable {
    mutating func toggleElement(_ element: Element) {
        if let index = firstIndex(of: element) {
            remove(at: index)
        } else {
            append(element)
        }
    }
}
