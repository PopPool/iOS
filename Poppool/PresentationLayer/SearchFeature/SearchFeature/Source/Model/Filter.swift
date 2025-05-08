import Foundation

/// 필터 옵션 상태를 공유하기 위한 싱글톤 객체
final class Filter: NSCopying, Equatable {
    func copy(with zone: NSZone? = nil) -> Any {
        return Filter(
            status: self.status,
            sort: self.sort
        )
    }

    static func == (lhs: Filter, rhs: Filter) -> Bool { return (lhs.status == rhs.status) && (lhs.sort == rhs.sort) }

    static let shared = Filter(status: .open, sort: .newest)

    var status: PopupStatus = .open
    var sort: PopupSort = .newest

    private init(status: PopupStatus, sort: PopupSort) {
        self.status = status
        self.sort = sort
    }

    var title: String {  [status.title, sort.title].joined(separator: "・") }
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
enum PopupSort: CaseIterable {
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
