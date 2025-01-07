

import ReactorKit
import RxSwift
import Foundation
import UIKit

/// 팝업스토어 등록/수정/삭제 화면의 Reactor
final class PopUpStoreRegisterReactor: Reactor {

    // MARK: - Action
    enum Action {
        // 기본 UI 이벤트
        case tapBack
        case tapMore          // "더보기" 버튼 → BottomSheet
        case tapDelete        // BottomSheet "삭제하기" 터치
        case tapSave          // 저장 버튼

        // 필드 입력
        case updateName(String)
        case updateCategory(String)
        case updateAddress(String)
        case updateLatitude(String)
        case updateLongitude(String)
        case updateMarkerName(String)
        case updateMarkerSnippet(String)
        case updateDescription(String)

        // 이미지 관련 (간단 예시)
        case addImage         // 새 이미지 추가
        case removeImage(Int) // 인덱스로 삭제
        case removeAllImages
        case checkRepresentativeImage(Int) // 대표이미지 체크

        // 날짜/시간 Picker 완료
        case pickedPeriod(Date, Date)
        case pickedTime(Date, Date)
    }

    // MARK: - Mutation
    enum Mutation {
        case setBack          // 뒤로가기
        case setShowMore      // 더보기 시트 표시
        case setDelete        // 삭제 실행
        case setSaved         // 저장 완료

        // 필드 업데이트
        case setName(String)
        case setCategory(String)
        case setAddress(String)
        case setLatitude(String)
        case setLongitude(String)
        case setMarkerName(String)
        case setMarkerSnippet(String)
        case setDescription(String)

        // 이미지 업데이트
        case addImage(UIImage)
        case removeImage(Int)
        case removeAllImages
        case checkRepresentativeImage(Int)

        // 날짜/시간
        case setPeriod(Date, Date)
        case setTime(Date, Date)
    }

    // MARK: - State
    struct State {
        // (0) 계정ID → View단에서 그냥 표시
        // (3) 팝업스토어 이미지 (대표이미지)
        var selectedImages: [UIImage] = [] // 간단히 UIImage 배열로 예시
        var repImageIndex: Int? = nil      // 대표이미지 인덱스 (3-1)

        // (4) 이름
        var name: String = ""
        // (5) 이미지 >= 1 필수
        // (6) 카테고리
        var category: String = "게임" // 디폴트
        // (7) 위치
        var address: String = ""
        // (7-1) 위도/경도
        var latitude: String = ""
        var longitude: String = ""
        // (8) 마커명
        var markerName: String = ""
        // (9) 스니펫
        var markerSnippet: String = ""
        // (10) 기간
        var startDate: Date?
        var endDate: Date?
        // (11) 시간
        var startTime: Date?
        var endTime: Date?
        // (12) 작성자
        var writerId: String = "김채연님" // 수정 시 변경될 수도
        // (13) 작성시간
        var writtenTime: String = "" // "2025-01-08 12:30"
        // (14) 상태값
        var status: String = "진행"  // chip
        // (15) 설명
        var desc: String = ""
        // (16) 저장버튼 활성/비활성
        var canSave: Bool = false

        // 플래그/이벤트
        var showMoreSheet: Bool = false   // 2-1. 더보기 시트
        var needToPop: Bool = false       // setBack
        var didDelete: Bool = false       // 삭제 완료 → 토스트
        var didSave: Bool = false         // 저장 완료 → 토스트
    }

    // MARK: - Properties
    let initialState: State

    private let useCase: AdminUseCase // or something
    private let popUpStoreId: Int64?  // nil이면 "등록", 값 있으면 "수정"

    // MARK: - Init
    init(useCase: AdminUseCase, popUpStoreId: Int64? = nil) {
        self.useCase = useCase
        self.popUpStoreId = popUpStoreId
        // 수정 모드면 useCase.fetchStoreDetail(...) 해서 initialState 만들어도 됨
        self.initialState = State(writerId: "김채연님", writtenTime: "2025-01-08 14:30")
    }

    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {

        case .tapBack:
            return .just(.setBack)

        case .tapMore:
            return .just(.setShowMore)

        case .tapDelete:
            // 실제 useCase.deleteStore(...) 후 성공 시 Mutation.setDelete
            // 간단 예시
            return .just(.setDelete)

        case .tapSave:
            // 필수값 체크 → [이미지≥1, 이름, 카테고리, 주소, desc 등]
            let st = currentState
            guard st.selectedImages.count >= 1,
                  !st.name.isEmpty,
                  !st.address.isEmpty,
                  !st.desc.isEmpty
            else {
                // 유효성 실패 → 저장불가
                return .empty()
            }
            // 실제 UseCase.createStore or updateStore
            // ...
            return .just(.setSaved)

        case let .updateName(name):
            return .just(.setName(name))

        case let .updateCategory(cat):
            return .just(.setCategory(cat))

        case let .updateAddress(addr):
            return .just(.setAddress(addr))

        case let .updateLatitude(lat):
            return .just(.setLatitude(lat))

        case let .updateLongitude(lon):
            return .just(.setLongitude(lon))

        case let .updateMarkerName(mn):
            return .just(.setMarkerName(mn))

        case let .updateMarkerSnippet(ms):
            return .just(.setMarkerSnippet(ms))

        case let .updateDescription(d):
            return .just(.setDescription(d))

        // 이미지
        case .addImage:
            // 임시로 UIImage(named: "dummy") 추가
            if let dummy = UIImage(named: "dummyImage") {
                return .just(.addImage(dummy))
            } else {
                return .empty()
            }

        case let .removeImage(idx):
            return .just(.removeImage(idx))

        case .removeAllImages:
            return .just(.removeAllImages)

        case let .checkRepresentativeImage(idx):
            return .just(.checkRepresentativeImage(idx))

        // 기간/시간
        case let .pickedPeriod(s, e):
            return .just(.setPeriod(s, e))

        case let .pickedTime(st, et):
            return .just(.setTime(st, et))
        }
    }

    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {

        case .setBack:
            newState.needToPop = true

        case .setShowMore:
            newState.showMoreSheet = true

        case .setDelete:
            // 삭제 완료
            newState.didDelete = true
            newState.needToPop = true

        case .setSaved:
            newState.didSave = true
            newState.needToPop = true

        case let .setName(name):
            newState.name = name

        case let .setCategory(cat):
            newState.category = cat

        case let .setAddress(addr):
            newState.address = addr

        case let .setLatitude(lat):
            newState.latitude = lat

        case let .setLongitude(lon):
            newState.longitude = lon

        case let .setMarkerName(mn):
            newState.markerName = mn

        case let .setMarkerSnippet(ms):
            newState.markerSnippet = ms

        case let .setDescription(desc):
            newState.desc = desc

        // 이미지
        case let .addImage(img):
            newState.selectedImages.append(img)
        case let .removeImage(idx):
            guard idx < newState.selectedImages.count else { break }
            newState.selectedImages.remove(at: idx)
            if let rep = newState.repImageIndex, rep == idx {
                newState.repImageIndex = nil
            } else if let rep = newState.repImageIndex, rep > idx {
                newState.repImageIndex = rep - 1
            }
        case .removeAllImages:
            newState.selectedImages.removeAll()
            newState.repImageIndex = nil
        case let .checkRepresentativeImage(idx):
            guard idx < newState.selectedImages.count else { break }
            newState.repImageIndex = idx

        case let .setPeriod(start, end):
            newState.startDate = start
            newState.endDate = end

        case let .setTime(st, et):
            newState.startTime = st
            newState.endTime = et
        }

        // 필수값 체크(이미지≥1, name, address, desc, ...)
        newState.canSave = ( !newState.name.isEmpty &&
                             !newState.address.isEmpty &&
                             !newState.desc.isEmpty &&
                             newState.selectedImages.count >= 1 )
        return newState
    }
}
