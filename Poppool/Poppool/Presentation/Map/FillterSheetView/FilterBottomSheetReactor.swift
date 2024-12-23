import ReactorKit
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
        case updateSubRegions([String])
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
        self.initialState = State(
            activeSegment: 0,
            selectedLocationIndex: nil,
            selectedSubRegions: [],
            selectedCategories: [],
            locations: [
                Location(main: "서울", sub: [
                    "강남/역삼/선릉", "건대/군자/구의", "강북/목동/신촌",
                    "명동/을지로/종로", "방이", "복촌/삼정",
                    "상수/대치", "상수/현정/광원"
                ]),
                Location(main: "경기", sub: ["수원시", "성남시", "용인시","용인시용인시","용인시","용인시"]),
                Location(main: "인천", sub: ["부평", "송도"]),
                Location(main: "부산", sub: [
                    "해운대", "광안리", "사상구",
                    "사하구", "북구", "남구"
                ]),
                Location(main: "제주", sub: ["제주시", "서귀포시"]),
                Location(main: "광주", sub: ["동구", "서구", "남구", "북구", "광산구"])
            ],
            categories: [
                "게임", "라이프스타일", "반려동물", "뷰티",
                "스포츠", "애니메이션", "엔터테이먼트",
                "여행","예술","음식/요리","키즈",
                "패션"
            ]
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
            } else { // 카테고리 탭에서 저장
                return Observable.just(.updateSavedCategories(currentState.selectedCategories))
            }


        case .selectLocation(let index):
            print("Select Location Index: \(index)")
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
            newState.selectedLocationIndex = nil
            newState.selectedSubRegions = []
            newState.selectedCategories = []

        case .applyFilters(let selectedOptions):
            print("필터 적용: \(newState.selectedSubRegions + newState.selectedCategories)")

        case .updateSelectedLocation(let index):
            newState.selectedLocationIndex = index
            let location = newState.locations[index]

            // 새로운 지역의 "전체" 키 생성
            let allKey = "\(location.main)전체"

            // 기존 선택한 서브 지역 유지 (다른 지역 포함)
            let previousSelections = newState.selectedSubRegions

            // 새로운 지역 선택 시 기존 선택된 옵션 그대로 유지
            newState.selectedSubRegions = previousSelections

            // 기존 선택된 옵션에 "전체"가 포함되지 않은 상태 유지
            newState.selectedSubRegions.removeAll { $0 == allKey }



        case .updateSubRegions(let subRegions):
            print("서브지역 업: \(subRegions)")

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
                    // "전체"를 선택한 경우
                    if newState.selectedSubRegions.contains(allKey) {
                        // "전체"가 이미 선택된 경우: 선택 해제
                        newState.selectedSubRegions.removeAll { $0 == allKey }
                    } else {
                        // "전체"를 활성화하고 다른 모든 옵션 제거
                        newState.selectedSubRegions = [allKey]
                    }
                } else {
                    // 개별 구/동 옵션 토글
                    if newState.selectedSubRegions.contains(subRegion) {
                        // 이미 선택된 구/동이면 비활성화
                        newState.selectedSubRegions.removeAll { $0 == subRegion }
                    } else {
                        // 새로운 구/동 추가
                        newState.selectedSubRegions.append(subRegion)
                    }

                    // "전체" 비활성화
                    newState.selectedSubRegions.removeAll { $0 == allKey }

                    // 모든 서브 지역이 선택되었으면 "전체" 활성화
                    if Set(newState.selectedSubRegions).count == location.sub.count {
                        newState.selectedSubRegions = [allKey]
                    }
                }

                print("현재 선택된 옵션: \(newState.selectedSubRegions)")
            }







        case .toggleCategorySelection(let category):
            if newState.selectedCategories.contains(category) {
                newState.selectedCategories.removeAll { $0 == category }
            } else {
                newState.selectedCategories.append(category)
            }

        case .toggleAllSubRegions:
            if let index = newState.selectedLocationIndex {
                let location = newState.locations[index]
                let allKey = "\(location.main)전체"

                if newState.selectedSubRegions.contains(allKey) {
                    // 전체 선택 해제
                    newState.selectedSubRegions.removeAll()
                } else {
                    // 전체 선택
                    newState.selectedSubRegions = location.sub + [allKey]
                }
            }

          }
          return newState
      }
}
