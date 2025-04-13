////
////  PopUpStoreRegisterReactor.swift
////  Poppool
////
////  Created by 김기현 on 1/14/25.
////
//
// import Foundation
// import ReactorKit
// import RxSwift
// import UIKit
//
// final class PopUpStoreRegisterReactor: Reactor {
//
//    // MARK: - Action
//    enum Action {
//        /// 화면 최초 로드
//        case viewDidLoad
//
//        /// 사용자 입력값 갱신
//        case updateName(String)
//        case updateDesc(String)
//        case updateCategory(String)
//        case updateAddress(String)
//        case updateLatitude(String)   // 문자열 -> Double 변환
//        case updateLongitude(String)
//        case updateMarkerTitle(String)
//        case updateMarkerSnippet(String)
//        case updateStartDate(Date)
//        case updateEndDate(Date)
//        case updateStartTime(Date)
//        case updateEndTime(Date)
//
//        /// 이미지 관련
//        case addImage(ExtendedImage)      // 개별 이미지 추가
//        case removeImage(Int)             // 특정 인덱스 이미지 삭제
//        case toggleMainImage(Int)         // 대표이미지 토글
//
//        /// "저장/등록" 버튼 탭
//        case tapRegister
//    }
//
//    // MARK: - Mutation
//    enum Mutation {
//        /// 폼 데이터 갱신
//        case setName(String)
//        case setDesc(String)
//        case setCategory(String)
//        case setAddress(String)
//        case setLatitude(Double)
//        case setLongitude(Double)
//        case setMarkerTitle(String)
//        case setMarkerSnippet(String)
//        case setStartDate(Date?)
//        case setEndDate(Date?)
//        case setStartTime(Date?)
//        case setEndTime(Date?)
//
//        /// 이미지 변경
//        case addImage(ExtendedImage)
//        case removeImageAt(Int)
//        case toggleMain(Int)
//
//        /// 등록 성공 여부
//        case setRegistered(Bool)
//    }
//
//    // MARK: - State
//    struct State {
//        // 폼 입력값
//        var name: String = ""
//        var desc: String = ""
//        var category: String = "게임"
//        var address: String = ""
//        var latitude: Double = 0
//        var longitude: Double = 0
//        var markerTitle: String = ""
//        var markerSnippet: String = ""
//        var startDate: Date?
//        var endDate: Date?
//        var startTime: Date?
//        var endTime: Date?
//        
//
//        // 이미지 목록
//        var images: [ExtendedImage] = []
//
//        // 최종 등록 여부
//        var isRegistered: Bool = false
//    }
//
//    // ReactorKit 필수
//    let initialState: State = State()
//
//    // 주입받는 의존성
//    private let adminUseCase: AdminUseCase
//
//    // disposeBag (mutate 안에서는 ReactorKit이 관리)
//    private let disposeBagInternal = DisposeBag()
//
//    // MARK: - Init
//    init(adminUseCase: AdminUseCase) {
//        self.adminUseCase = adminUseCase
//    }
//
//    // MARK: - mutate
//    func mutate(action: Action) -> Observable<Mutation> {
//        switch action {
//
//        case .viewDidLoad:
//            return .empty()
//
//        // 텍스트 입력 업데이트
//        case let .updateName(name):
//            return .just(.setName(name))
//
//        case let .updateDesc(desc):
//            return .just(.setDesc(desc))
//
//        case let .updateCategory(cat):
//            return .just(.setCategory(cat))
//
//        case let .updateAddress(addr):
//            return .just(.setAddress(addr))
//
//        case let .updateLatitude(latString):
//            // 문자 -> Double 변환
//            let lat = Double(latString) ?? 0
//            return .just(.setLatitude(lat))
//
//        case let .updateLongitude(lonString):
//            let lon = Double(lonString) ?? 0
//            return .just(.setLongitude(lon))
//
//        case let .updateMarkerTitle(title):
//            return .just(.setMarkerTitle(title))
//
//        case let .updateMarkerSnippet(snippet):
//            return .just(.setMarkerSnippet(snippet))
//
//        case let .updateStartDate(date):
//            return .just(.setStartDate(date))
//
//        case let .updateEndDate(date):
//            return .just(.setEndDate(date))
//
//        case let .updateStartTime(time):
//            return .just(.setStartTime(time))
//
//        case let .updateEndTime(time):
//            return .just(.setEndTime(time))
//
//        // 이미지 관련
//        case let .addImage(img):
//            return .just(.addImage(img))
//
//        case let .removeImage(index):
//            return .just(.removeImageAt(index))
//
//        case let .toggleMainImage(index):
//            return .just(.toggleMain(index))
//
//        // "저장" 액션
//        case .tapRegister:
//            return doRegister()
//        }
//    }
//
//    // MARK: - reduce
//    func reduce(state: State, mutation: Mutation) -> State {
//        var newState = state
//
//        switch mutation {
//        case let .setName(name):
//            newState.name = name
//
//        case let .setDesc(desc):
//            newState.desc = desc
//
//        case let .setCategory(cat):
//            newState.category = cat
//
//        case let .setAddress(addr):
//            newState.address = addr
//
//        case let .setLatitude(lat):
//            newState.latitude = lat
//
//        case let .setLongitude(lon):
//            newState.longitude = lon
//
//        case let .setMarkerTitle(title):
//            newState.markerTitle = title
//
//        case let .setMarkerSnippet(snippet):
//            newState.markerSnippet = snippet
//
//        case let .setStartDate(date):
//            newState.startDate = date
//
//        case let .setEndDate(date):
//            newState.endDate = date
//
//        case let .setStartTime(time):
//            newState.startTime = time
//
//        case let .setEndTime(time):
//            newState.endTime = time
//
//        // 이미지
//        case let .addImage(img):
//            newState.images.append(img)
//
//        case let .removeImageAt(index):
//            if index >= 0 && index < newState.images.count {
//                newState.images.remove(at: index)
//            }
//
//        case let .toggleMain(idx):
//            // 모든 이미지 isMain=false 후 idx만 true
//            for i in 0..<newState.images.count {
//                newState.images[i].isMain = (i == idx)
//            }
//
//        // 등록 성공
//        case let .setRegistered(success):
//            newState.isRegistered = success
//        }
//
//        return newState
//    }
//
//    // MARK: - Custom Method: doRegister
//    /// 실제 등록 로직
//    private func doRegister() -> Observable<Mutation> {
//        // 1) 폼 유효성 검사
//        guard validateForm() else {
//            // 유효성 실패시엔 Mutation 없이 .empty() (혹은 에러 Mutation)
//            return .empty()
//        }
//
//        // 2) 대표 vs 서브 이미지
//        let mainImg = currentState.images.first(where: { $0.isMain })
//            ?? currentState.images.first!
//        let mainUrl = mainImg.filePath
//        let subImages = currentState.images
//            .filter { $0.filePath != mainUrl }
//            .map { $0.filePath }
//
//        // 3) 날짜/시간 -> 문자열 변환
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        let startDateStr = currentState.startDate.map { dateFormatter.string(from: $0) } ?? "2025-01-01"
//        let endDateStr   = currentState.endDate.map { dateFormatter.string(from: $0) } ?? "2025-12-31"
//
//        // 4) DTO
//        let request = CreatePopUpStoreRequestDTO(
//            name: currentState.name,
//            categoryId: convertCategoryToId(currentState.category),
//            desc: currentState.desc,
//            address: currentState.address,
//            startDate: startDateStr,
//            endDate: endDateStr,
//            mainImageUrl: mainUrl,
//            bannerYn: false,
//            imageUrlList: subImages,
//            latitude: currentState.latitude,
//            longitude: currentState.longitude,
//            markerTitle: currentState.markerTitle,
//            markerSnippet: currentState.markerSnippet,
//            startDateBeforeEndDate: true
//        )
//
//        // 5) 서버 호출 -> 결과에 따라 Mutation
//        return adminUseCase.createStore(request: request)
//            .map { _ in Mutation.setRegistered(true) }
//            .catch { error in
//                // 에러 시 로깅/별도 처리
//                return .empty()
//            }
//            .asObservable()
//    }
//
//    // MARK: - validateForm()
//    private func validateForm() -> Bool {
//        // 간단 예시
//        if currentState.name.isEmpty { return false }
//        if currentState.desc.isEmpty { return false }
//        if currentState.address.isEmpty { return false }
//        if currentState.latitude == 0 && currentState.longitude == 0 { return false }
//        if currentState.markerTitle.isEmpty || currentState.markerSnippet.isEmpty { return false }
//        // 이미지 >=1, 대표 1장
//        if currentState.images.isEmpty { return false }
//        if !currentState.images.contains(where: { $0.isMain }) { return false }
//        return true
//    }
//
//    /// 예시: 카테고리 문자열 -> ID 변환 (임의 로직)
//    private func convertCategoryToId(_ cat: String) -> Int64 {
//        switch cat {
//        case "게임": return 101
//        case "라이프스타일": return 102
//        default: return 100
//        }
//    }
// }
