import Foundation

/// 필터 옵션 상태를 공유하기 위한 싱글톤 객체
final class FilterOption: NSCopying, Equatable {
    func copy(with zone: NSZone? = nil) -> Any {
        return FilterOption(
            status: self.status,
            sortOption: self.sortOption
        )
    }

    static func == (lhs: FilterOption, rhs: FilterOption) -> Bool { return lhs === rhs }

    static let shared = FilterOption(status: .open, sortOption: .newest)

    var status: PopupStatus
    var sortOption: PopupSortOption

    private init(status: PopupStatus, sortOption: PopupSortOption) {
        self.status = status
        self.sortOption = sortOption
    }

    var title: String {  [status.title, sortOption.title].joined(separator: "・") }
}

/// 팝업 상점이 현재 열려 있는지 또는 닫혀 있는지 여부를 나타냅니다
enum PopupStatus: CaseIterable {
    case open
    case closed

    /// UI 용 문자열 표시 (예 : 세그먼트 제목)
    var title: String {
        switch self {
        case .open: return "오픈"
        case .closed: return "종료"
        }
    }

    /// API 요청에 포함 할 값
    var requestValue: Bool {
        switch self {
        case .open: return true
        case .closed: return false
        }
    }

    /// UISegmentedControl과 같은 UI 구성 요소의 색인
    var index: Int {
        return Self.allCases.firstIndex(of: self)!
    }
}

/// 팝업 검색 결과를위한 정렬 옵션을 나타냅니다
enum PopupSortOption: CaseIterable {
    case newest
    case popularity

    /// UI 용 문자열 표시 (예 : 세그먼트 제목)
    var title: String {
        switch self {
        case .newest: return "신규순"
        case .popularity: return "인기순"
        }
    }

    /// API 요청에 포함 할 값
    var requestValue: String {
        switch self {
        case .newest: return "NEWEST"
        case .popularity: return "MOST_VIEWED,MOST_COMMENTED,MOST_BOOKMARKED"
        }
    }

    /// UISegmentedControl과 같은 UI 구성 요소의 색인
    var index: Int {
        return Self.allCases.firstIndex(of: self)!
    }
}
