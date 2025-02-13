import ReactorKit
import Foundation
import RxSwift

struct Location: Equatable {
    let main: String
    let sub: [String]
}

final class FilterBottomSheetReactor: Reactor {
    enum Action {
        case segmentChanged(Int)
        case resetFilters
        case applyFilters([String])
        case selectLocation(Int)
        case toggleSubRegion(String)
        case toggleCategory(String)
        case toggleAllSubRegions
    }

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
    }

    struct State {
        var activeSegment: Int
        var selectedLocationIndex: Int?
        var selectedSubRegions: [String]
        var selectedCategories: [String]
        var locations: [Location]
        var categories: [String]
        var savedSubRegions: [String] = []
        var savedCategories: [String] = []
        var isSaveEnabled: Bool {
            return !selectedSubRegions.isEmpty || !selectedCategories.isEmpty
        }
    }

    let initialState: State

    init() {
        let initialLocations: [Location] = [
            Location(
                main: "서울",
                sub: [
                    "도봉/노원","강북/중랑",
                    "동대문/성북",
                    "중구/종로",
                    "성동/광진",
                    "송파/강동",
                    "동작/관악",
                    "서초/강남",
                    "은평/서대문/마포",
                    "영등포/구로",
                    "용산",
                    "양천/강서/금천"
                ]
            ),
            Location(
                main: "경기",
                sub: [
                    "포천/연천","동두천/양주/의정부",
                    "구리/남양주/가평",
                    "파주/고양/김포",
                    "용인/화성/수원",
                    "군포/의왕","과천/안양",
                    "부천/광명","시흥/안산",
                    "안성/평택/오산",
                    "성남/하남/광주","이천/여주/양평"
                ]
            ),
            Location(main: "인천", sub: ["부평", "송도"]),
            Location(main: "부산", sub: ["해운대", "광안리", "사상구", "사하구", "북구", "남구"]),
            Location(main: "제주", sub: ["제주시", "서귀포시"]),
            Location(main: "광주", sub: ["동구", "서구", "남구", "북구", "광산구"])
        ]

        self.initialState = State(
            activeSegment: 0,
            selectedLocationIndex: nil,
            selectedSubRegions: [],
            selectedCategories: [],
            locations: initialLocations, // 초기 locations 설정
            categories: ["게임", "라이프스타일", "반려동물", "뷰티", "스포츠", "애니메이션", "엔터테인먼트", "여행", "예술", "음식/요리", "키즈", "패션"]
        )
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .segmentChanged(let index):
            return Observable.just(.setActiveSegment(index))
        case .resetFilters:
            return Observable.just(.resetFilters)
        case .applyFilters:
            let activeSegment = currentState.activeSegment
            if activeSegment == 0 {
                return Observable.just(.updateSavedSubRegions(currentState.selectedSubRegions))
            } else {
                return Observable.just(.updateSavedCategories(currentState.selectedCategories))
            }
        case .selectLocation(let index):
            return Observable.just(.updateSelectedLocation(index))
        case .toggleCategory(let category):
            return Observable.just(.toggleCategorySelection(category))
        case .toggleSubRegion(let subRegion):
            return Observable.just(.toggleSubRegionSelection(subRegion))
        case .toggleAllSubRegions:
            return Observable.just(.toggleAllSubRegions)
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setActiveSegment(let index):
            newState.activeSegment = index
        case .resetFilters:
            let currentIndex = newState.selectedLocationIndex

            // 선택 상태만 초기화
            newState.selectedSubRegions = []
            newState.selectedCategories = []

            // 이전 선택된 index 복원하여 이벤트 핸들러 유지
            newState.selectedLocationIndex = currentIndex

            return newState

        case .applyFilters:
            print("필터 적용: \(newState.selectedSubRegions + newState.selectedCategories)")
        case .updateSelectedLocation(let index):
            newState.selectedLocationIndex = index
            let selectedLocation = newState.locations[index]
            // 현재 선택된 지역의 전체만 남기고 모두 초기화
            newState.selectedSubRegions = ["\(selectedLocation.main)전체"]

            break
        case .updateSavedSubRegions(let subRegions):
            newState.savedSubRegions = subRegions
            newState.selectedSubRegions = []
        case .updateSavedCategories(let categories):
            newState.savedCategories = categories
            newState.selectedCategories = []
        case .toggleSubRegionSelection(let subRegion):
            if let selectedIndex = newState.selectedLocationIndex {
                let location = newState.locations[selectedIndex]
                let allKey = "\(location.main)전체"

                if subRegion == allKey {
                    // 전체 버튼 토글
                    newState.selectedSubRegions = newState.selectedSubRegions.contains(allKey) ? [] : [allKey]
                } else {
                    // 서브 지역 선택 시 무조건 전체 버튼은 해제
                    newState.selectedSubRegions.removeAll { $0 == allKey }

                    // 서브 지역 토글
                    if newState.selectedSubRegions.contains(subRegion) {
                        newState.selectedSubRegions.removeAll { $0 == subRegion }
                    } else {
                        newState.selectedSubRegions.append(subRegion)
                    }

                    // 모든 서브 지역이 선택된 경우에만 전체로 변경
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

                if newState.selectedSubRegions.contains(allKey) {
                    newState.selectedSubRegions = []
                } else {
                    newState.selectedSubRegions = [allKey]
                }
            }
        }
        return newState
    }
}


extension Array where Element: Equatable {
    mutating func toggleElement(_ element: Element) {
        if let index = firstIndex(of: element) {
            remove(at: index)
        } else {
            append(element)
        }
    }
}
