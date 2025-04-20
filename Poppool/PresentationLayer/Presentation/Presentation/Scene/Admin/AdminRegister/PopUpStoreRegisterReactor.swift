import UIKit
import CoreLocation

import Infrastructure
import DomainInterface

import ReactorKit
import RxCocoa
import RxSwift

final class PopUpStoreRegisterReactor: Reactor {

    // MARK: - Properties
    private let adminUseCase: AdminUseCase
    private let preSignedUseCase: PreSignedUseCase
    private let isEditMode: Bool
    private let editingStoreId: Int64?

    private var disposeBag = DisposeBag()

    init(
        adminUseCase: AdminUseCase,
        preSignedUseCase: PreSignedUseCase,
        editingStore: AdminStore? = nil
    ) {
        self.adminUseCase = adminUseCase
        self.preSignedUseCase = preSignedUseCase
        self.isEditMode = editingStore != nil
        self.editingStoreId = editingStore?.id

        // 초기 상태 설정
        let initialState = State(isEditMode: self.isEditMode)
        self.initialState = initialState
    }

    // MARK: - Action
    enum Action {
        // 폼 데이터 업데이트
        case updateName(String)
        case updateAddress(String)
        case updateLat(String)
        case updateLon(String)
        case updateDescription(String)
        case selectCategory(String)
        case updateMarkerTitle(String)
        case updateMarkerSnippet(String)

        // 날짜/시간 관련
        case selectDateRange(start: Date, end: Date)
        case selectTimeRange(start: Date, end: Date)

        // 이미지 관련
        case addImages([ExtendedImage])
        case removeImage(Int)
        case removeAllImages
        case toggleMainImage(Int)
        case markImageDeleted(String, Int64)

        // 네트워크 관련
        case loadStoreDetail(Int64)
        case geocodeAddress(String)
        case save

        // 기타
        case clearError
        case dismissSuccess
    }

    // MARK: - Mutation
    enum Mutation {
        // 폼 데이터 설정
        case setName(String)
        case setAddress(String)
        case setLat(String)
        case setLon(String)
        case setDescription(String)
        case setCategory(String)
        case setMarkerTitle(String)
        case setMarkerSnippet(String)

        // 날짜/시간 설정
        case setDateRange(start: Date, end: Date)
        case setTimeRange(start: Date, end: Date)

        // 이미지 관리
        case setImages([ExtendedImage])
        case addImages([ExtendedImage])
        case removeImage(Int)
        case removeAllImages
        case toggleMainImage(Int)
        case addDeletedImage(id: Int64, path: String)

        // 기존 스토어 데이터 설정
        case setStoreDetail(AdminStoreDetail)
        case setOriginalImageIds([String: Int64])

        // UI 상태 관리
        case setLoading(Bool)
        case setSaveEnabled(Bool)
        case setSuccess(Bool)
        case setError(String?)
    }

    // MARK: - State
    struct State {
        // 폼 데이터
        var name: String = ""
        var address: String = ""
        var lat: String = ""
        var lon: String = ""
        var description: String = ""
        var category: String = ""
        var categoryId: Int64 = 0
        var markerTitle: String = "마커 제목"
        var markerSnippet: String = "마커 설명"

        // 날짜 및 시간
        var selectedStartDate: Date?
        var selectedEndDate: Date?
        var selectedStartTime: Date?
        var selectedEndTime: Date?

        // 이미지 관련
        var images: [ExtendedImage] = []
        var originalImageIds: [String: Int64] = [:]
        var deletedImageIds: [Int64] = []
        var deletedImagePaths: [String] = []

        // UI 상태
        var isLoading: Bool = false
        var isSaveEnabled: Bool = false
        var isSuccess: Bool = false
        var errorMessage: String?

        // 모드 구분
        var isEditMode: Bool

        init(isEditMode: Bool = false) {
            self.isEditMode = isEditMode
        }
    }

    let initialState: State

    // MARK: - Mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            // 폼 데이터 업데이트 액션
        case let .updateName(name):
            return .just(.setName(name))

        case let .updateAddress(address):
            return .just(.setAddress(address))

        case let .updateLat(lat):
            return .just(.setLat(lat))

        case let .updateLon(lon):
            return .just(.setLon(lon))

        case let .updateDescription(desc):
            return .just(.setDescription(desc))

        case let .selectCategory(category):
            return .just(.setCategory(category))

        case let .updateMarkerTitle(title):
            return .just(.setMarkerTitle(title))

        case let .updateMarkerSnippet(snippet):
            return .just(.setMarkerSnippet(snippet))

            // 날짜/시간 관련 액션
        case let .selectDateRange(start, end):
            return .just(.setDateRange(start: start, end: end))

        case let .selectTimeRange(start, end):
            return .just(.setTimeRange(start: start, end: end))

            // 이미지 관련 액션
        case let .addImages(newImages):
            return .just(.addImages(newImages))

        case let .removeImage(index):
            return .just(.removeImage(index))

        case .removeAllImages:
            return .just(.removeAllImages)

        case let .toggleMainImage(index):
            return .just(.toggleMainImage(index))

        case let .markImageDeleted(path, id):
            return .just(.addDeletedImage(id: id, path: path))

            // 주소 지오코딩
        case let .geocodeAddress(address):
            return geocodeAddress(address: address)
                .flatMap { location -> Observable<Mutation> in
                    guard let location = location else {
                        return .just(.setError("주소를 찾을 수 없습니다."))
                    }

                    let latMutation = Mutation.setLat(String(format: "%.6f", location.coordinate.latitude))
                    let lonMutation = Mutation.setLon(String(format: "%.6f", location.coordinate.longitude))

                    return .concat([
                        .just(latMutation),
                        .just(lonMutation)
                    ])
                }

            // 스토어 상세 정보 로드 (수정 모드)
        case let .loadStoreDetail(storeId):
            return Observable.concat([
                .just(.setLoading(true)),
                loadStoreDetail(storeId: storeId)
                    .catch { error in .just(.setError(error.localizedDescription)) },
                .just(.setLoading(false))
            ])

            // 저장 액션
        case .save:
            return Observable.concat([
                .just(.setLoading(true)),
                saveStore()
                    .catch { error in .just(.setError(error.localizedDescription)) },
                .just(.setLoading(false))
            ])

            // 오류 초기화
        case .clearError:
            return .just(.setError(nil))

            // 성공 상태 초기화
        case .dismissSuccess:
            return .just(.setSuccess(false))
        }
    }

    // MARK: - Transform
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return mutation
            .map { mutation -> [Mutation] in
                // 특정 mutation이 발생한 경우 상태에 따라 추가 mutation을 발생시킴
                var mutations: [Mutation] = [mutation]

                if case .setLoading(true) = mutation {
                    mutations.append(.setError(nil))
                }

                return mutations
            }
            .flatMap { Observable.from($0) }
    }

    // MARK: - Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
            // 폼 데이터 설정
        case let .setName(name):
            newState.name = name

        case let .setAddress(address):
            newState.address = address

        case let .setLat(lat):
            newState.lat = lat

        case let .setLon(lon):
            newState.lon = lon

        case let .setDescription(desc):
            newState.description = desc

        case let .setCategory(category):
            newState.category = category
            newState.categoryId = Int64(getCategoryId(from: category))

        case let .setMarkerTitle(title):
            newState.markerTitle = title

        case let .setMarkerSnippet(snippet):
            newState.markerSnippet = snippet

            // 날짜/시간 설정
        case let .setDateRange(start, end):
            newState.selectedStartDate = start
            newState.selectedEndDate = end

        case let .setTimeRange(start, end):
            newState.selectedStartTime = start
            newState.selectedEndTime = end

            // 이미지 관련
        case let .setImages(images):
            newState.images = images

        case let .addImages(newImages):
            newState.images.append(contentsOf: newImages)

            // 이미지가 이제 있고 대표 이미지가 없으면 첫 번째를 대표로 설정
            if !newState.images.isEmpty && !newState.images.contains(where: { $0.isMain }) {
                newState.images[0].isMain = true
            }

        case let .removeImage(index):
            if index < newState.images.count {
                let wasMainImage = newState.images[index].isMain
                let removedImagePath = newState.images[index].filePath

                // 기존 이미지인 경우 삭제 목록에 추가
                if let imageId = newState.originalImageIds[removedImagePath] {
                    if !newState.deletedImageIds.contains(imageId) {
                        newState.deletedImageIds.append(imageId)
                        newState.deletedImagePaths.append(removedImagePath)
                    }
                }

                // 이미지 배열에서 제거
                newState.images.remove(at: index)

                // 대표 이미지가 삭제되었고 다른 이미지가 있으면 첫 번째를 대표로 설정
                if wasMainImage && !newState.images.isEmpty {
                    newState.images[0].isMain = true
                }
            }

        case .removeAllImages:
            // 기존 이미지인 경우 모두 삭제 목록에 추가
            for image in newState.images {
                if let imageId = newState.originalImageIds[image.filePath] {
                    if !newState.deletedImageIds.contains(imageId) {
                        newState.deletedImageIds.append(imageId)
                        newState.deletedImagePaths.append(image.filePath)
                    }
                }
            }

            newState.images.removeAll()

        case let .toggleMainImage(index):
            if index < newState.images.count {
                for i in 0..<newState.images.count {
                    newState.images[i].isMain = (i == index)
                }
            }

        case let .addDeletedImage(id, path):
            if !newState.deletedImageIds.contains(id) {
                newState.deletedImageIds.append(id)
                newState.deletedImagePaths.append(path)
            }

            // 기존 스토어 데이터 설정
        case let .setStoreDetail(storeDetail):
            // 폼 데이터 채우기
            newState.name = storeDetail.name
            newState.category = storeDetail.categoryName
            newState.categoryId = storeDetail.categoryId
            newState.address = storeDetail.address
            newState.lat = String(storeDetail.latitude)
            newState.lon = String(storeDetail.longitude)
            newState.description = storeDetail.description

            // 날짜 파싱
            let isoFormatter = ISO8601DateFormatter()
            if let startDate = isoFormatter.date(from: storeDetail.startDate),
               let endDate = isoFormatter.date(from: storeDetail.endDate) {
                newState.selectedStartDate = startDate
                newState.selectedEndDate = endDate
            }

        case let .setOriginalImageIds(imageIds):
            newState.originalImageIds = imageIds

            // UI 상태 관리
        case let .setLoading(isLoading):
            newState.isLoading = isLoading

        case let .setSuccess(isSuccess):
            newState.isSuccess = isSuccess

        case let .setError(message):
            newState.errorMessage = message

        case let .setSaveEnabled(enabled):
            newState.isSaveEnabled = enabled
        }

        // 폼 유효성 검사 및 저장 버튼 활성화 상태 업데이트
        let isFormValid = validateForm(state: newState)
        newState.isSaveEnabled = isFormValid

        return newState
    }

    // MARK: - Helper Methods

    // 폼 유효성 검사
    private func validateForm(state: State) -> Bool {
        Logger.log(message: "폼 유효성 검사 시작", category: .debug)

        // 이름 필드 검사
        guard !state.name.isEmpty else {
            Logger.log(message: "유효성 검사 실패: 이름 비어있음", category: .debug)
            return false
        }

        // 주소 필드 검사
        guard !state.address.isEmpty else {
            Logger.log(message: "유효성 검사 실패: 주소 비어있음", category: .debug)
            return false
        }

        // 위도/경도 필드 검사
        guard !state.lat.isEmpty else {
            Logger.log(message: "유효성 검사 실패: 위도 비어있음", category: .debug)
            return false
        }

        guard !state.lon.isEmpty else {
            Logger.log(message: "유효성 검사 실패: 경도 비어있음", category: .debug)
            return false
        }

        // 설명 필드 검사
        guard !state.description.isEmpty else {
            Logger.log(message: "유효성 검사 실패: 설명 비어있음", category: .debug)
            return false
        }

        // 카테고리 필드 검사
        guard !state.category.isEmpty else {
            Logger.log(message: "유효성 검사 실패: 카테고리 비어있음", category: .debug)
            return false
        }

        // 이미지 검사
        guard !state.images.isEmpty else {
            Logger.log(message: "유효성 검사 실패: 이미지 없음", category: .debug)
            return false
        }

        // 대표 이미지 검사
        guard state.images.contains(where: { $0.isMain }) else {
            Logger.log(message: "유효성 검사 실패: 대표 이미지 없음", category: .debug)
            return false
        }

        // 날짜 검사
        guard state.selectedStartDate != nil else {
            Logger.log(message: "유효성 검사 실패: 시작 날짜 없음", category: .debug)
            return false
        }

        guard state.selectedEndDate != nil else {
            Logger.log(message: "유효성 검사 실패: 종료 날짜 없음", category: .debug)
            return false
        }

        // 위도/경도 유효성 검사
        guard let latVal = Double(state.lat),
              let lonVal = Double(state.lon) else {
            Logger.log(message: "유효성 검사 실패: 위도/경도 형식 오류", category: .debug)
            return false
        }

        // 위도/경도 값이 유효한지 검사
        guard latVal != 0 || lonVal != 0 else {
            Logger.log(message: "유효성 검사 실패: 위도/경도 값이 모두 0", category: .debug)
            return false
        }

        // 날짜 순서 검사
        if let startDate = state.selectedStartDate,
           let endDate = state.selectedEndDate,
           startDate > endDate {
            Logger.log(message: "유효성 검사 실패: 시작일이 종료일보다 늦음", category: .debug)
            return false
        }

        Logger.log(message: "유효성 검사 성공", category: .debug)
        return true
    }

    // 주소 지오코딩
    private func geocodeAddress(address: String) -> Observable<CLLocation?> {
        Logger.log(message: "지오코딩 함수 호출: \(address)", category: .debug)

        return Observable.create { observer in
            let geocoder = CLGeocoder()
            let fullAddress = "\(address), Korea"

            geocoder.geocodeAddressString(
                fullAddress,
                in: nil,
                preferredLocale: Locale(identifier: "ko_KR")
            ) { placemarks, error in
                if let error = error {
                    Logger.log(message: "Geocoding error: \(error.localizedDescription)", category: .error)
                    observer.onNext(nil)
                    observer.onCompleted()
                    return
                }

                if let location = placemarks?.first?.location {
                    observer.onNext(location)
                } else {
                    observer.onNext(nil)
                }
                observer.onCompleted()
            }

            return Disposables.create()
        }
    }

    // S3에서 이미지 삭제
    private func deleteImagesFromS3(_ imagePaths: [String]) {
        guard !imagePaths.isEmpty else { return }

        preSignedUseCase.tryDelete(objectKeyList: imagePaths)
            .subscribe(
                onCompleted: {
                    Logger.log(message: "S3에서 모든 이미지 삭제 성공: \(imagePaths.count)개", category: .info)
                },
                onError: { error in
                    Logger.log(message: "S3에서 이미지 삭제 실패: \(error.localizedDescription)", category: .error)
                }
            )
        .disposed(by: disposeBag)
    }

    // 카테고리 ID 매핑
    private func getCategoryId(from title: String) -> Int {
        let cleanTitle = title.replacingOccurrences(of: " ▾", with: "")
        Logger.log(message: "카테고리 매핑 시작 - 타이틀: \(cleanTitle)", category: .debug)

        let categoryMap: [String: Int64] = [
            "패션": 1,
            "라이프스타일": 2,
            "뷰티": 3,
            "음식/요리": 4,
            "예술": 5,
            "반려동물": 6,
            "여행": 7,
            "엔터테인먼트": 8,
            "애니메이션": 9,
            "키즈": 10,
            "스포츠": 11,
            "게임": 12
        ]

        if let id = categoryMap[cleanTitle] {
            Logger.log(message: "카테고리 매핑 성공: \(cleanTitle) -> \(id)", category: .debug)
            return Int(id)
        } else {
            Logger.log(message: "카테고리 매핑 실패: \(cleanTitle)에 해당하는 ID를 찾을 수 없음", category: .error)
            return 1 // 기본값
        }
    }

    // 날짜 형식 변환
    private func getFormattedDate(from date: Date?) -> String {
        guard let date = date else { return "" }

        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"

        return formatter.string(from: date)
    }

    // 날짜 및 시간 결합
    private func createDateTime(date: Date?, time: Date?) -> Date? {
        guard let date = date else { return nil }

        if let time = time {
            let calendar = Calendar.current

            // 날짜 부분 추출
            var components = calendar.dateComponents([.year, .month, .day], from: date)

            // 시간 부분 추출
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)

            // 날짜와 시간 결합
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute
            components.second = 0
            components.timeZone = TimeZone(identifier: "Asia/Seoul")

            return calendar.date(from: components)
        }

        return date
    }

    // 날짜/시간 준비
    private func prepareDateTime(state: State) -> (startDate: String, endDate: String) {
        // 시작일/시간 결합
        let startDateTime = createDateTime(date: state.selectedStartDate, time: state.selectedStartTime)

        // 종료일/시간 결합
        let endDateTime = createDateTime(date: state.selectedEndDate, time: state.selectedEndTime)

        let startDate = getFormattedDate(from: startDateTime)
        let endDate = getFormattedDate(from: endDateTime)

        return (startDate: startDate, endDate: endDate)
    }

    // 스토어 상세 정보 로드
    private func loadStoreDetail(storeId: Int64) -> Observable<Mutation> {
        return adminUseCase.fetchStoreDetail(id: storeId)
            .flatMap { [weak self] storeDetail -> Observable<Mutation> in
                guard let self = self else { return .empty() }

                // 이미지 ID 매핑 초기화 및 설정
                var originalImageIds: [String: Int64] = [:]
                for image in storeDetail.images {
                    originalImageIds[image.imageUrl] = image.id
                }

                // 중복 및 삭제된 이미지 제외를 위한 집합
                var loadedImageUrls = Set<String>()
                let deletedIdSet = Set(self.currentState.deletedImageIds)

                // 이미지 로드 및 변환
                let mainImageUrl = storeDetail.mainImageUrl
                var loadedImages: [ExtendedImage] = []
                let dispatchGroup = DispatchGroup()

                let imageObservable = Observable<Mutation>.create { observer in
                    for imageData in storeDetail.images {
                        // 중복 이미지 건너뛰기
                        if loadedImageUrls.contains(imageData.imageUrl) {
                            continue
                        }

                        // 삭제된 이미지 건너뛰기
                        if deletedIdSet.contains(imageData.id) {
                            continue
                        }

                        loadedImageUrls.insert(imageData.imageUrl)

                        dispatchGroup.enter()

                        if let imageURL = self.preSignedUseCase.fullImageURL(from: imageData.imageUrl) {
                            URLSession.shared.dataTask(with: imageURL) { data, _, error in
                                defer { dispatchGroup.leave() }

                                if let error = error {
                                    Logger.log(message: "이미지 로드 오류: \(error.localizedDescription)", category: .error)
                                    return
                                }

                                guard let data = data,
                                      let image = UIImage(data: data) else {
                                    Logger.log(message: "이미지 변환 실패", category: .error)
                                    return
                                }

                                let isMain = (imageData.imageUrl == mainImageUrl)
                                let extendedImage = ExtendedImage(filePath: imageData.imageUrl, image: image, isMain: isMain)

                                DispatchQueue.main.async {
                                    loadedImages.append(extendedImage)
                                }
                            }.resume()
                        } else {
                            dispatchGroup.leave()
                        }
                    }

                    dispatchGroup.notify(queue: .main) {
                        if !loadedImages.isEmpty && !loadedImages.contains(where: { $0.isMain }) {
                            loadedImages[0].isMain = true
                        }

                        observer.onNext(.setImages(loadedImages))
                        observer.onNext(.setOriginalImageIds(originalImageIds))
                        observer.onCompleted()
                    }

                    return Disposables.create()
                }

                return Observable.concat([
                    .just(.setStoreDetail(storeDetail)),
                    imageObservable
                ])
            }
    }

    // 저장 액션 처리
    private func saveStore() -> Observable<Mutation> {
        let state = self.currentState

        // 유효성 검사
        if !validateForm(state: state) {
            return .just(.setError("필수 항목을 모두 입력해 주세요."))
        }

        if state.isEditMode {
            return updateStore()
        } else {
            return createStore()
        }
    }

    // 이미지 업로드
    private func uploadImages() -> Observable<[String]> {
        let uuid = UUID().uuidString
        let updatedImages = currentState.images.enumerated().map { index, image in
            let filePath = "PopUpImage/\(currentState.name)/\(uuid)/\(index).jpg"
            return ExtendedImage(
                filePath: filePath,
                image: image.image,
                isMain: image.isMain)
        }

        return preSignedUseCase.tryUpload(presignedURLRequest: updatedImages.map {
            return (filePath: $0.filePath, image: $0.image)
        })
        .asObservable() // Single을 Observable로 변환
        .map { _ in updatedImages.map { $0.filePath } }
    }

    // 신규 스토어 등록
    private func createStore() -> Observable<Mutation> {
        return uploadImages()
            .flatMap { [weak self] imagePaths -> Observable<Mutation> in
                guard let self = self else { return .empty() }

                let state = self.currentState
                let dates = self.prepareDateTime(state: state)

                // 메인 이미지 찾기
                let mainImage = imagePaths.first { path in
                    if let index = state.images.firstIndex(where: { $0.filePath == path }) {
                        return state.images[index].isMain
                    }
                    return false
                } ?? imagePaths.first ?? ""

                let params = CreateStoreParams(
                    name: state.name,
                    categoryId: state.categoryId,
                    desc: state.description,
                    address: state.address,
                    startDate: dates.startDate,
                    endDate: dates.endDate,
                    mainImageUrl: mainImage,
                    imageUrlList: imagePaths,
                    latitude: Double(state.lat) ?? 0,
                    longitude: Double(state.lon) ?? 0,
                    markerTitle: state.markerTitle,
                    markerSnippet: state.markerSnippet,
                    startDateBeforeEndDate: true
                )

                return self.adminUseCase.createStore(params: params)
                    .andThen(Observable.just(.setSuccess(true)))
            }
    }

    // 기존 스토어 수정
    private func updateStore() -> Observable<Mutation> {
        // 기존에 저장된 이미지는 재업로드하지 않고 그대로 사용
        // 새로 추가된 이미지만 업로드
        let state = self.currentState

        // 새로 추가된 이미지만 필터링
        let newImages = state.images.filter { image in
            return !state.originalImageIds.keys.contains(image.filePath)
        }

        // 새 이미지가 없으면 바로 스토어 정보 업데이트
        if newImages.isEmpty {
            return updateStoreInfo(nil)
        }

        // 새 이미지 업로드
        return uploadNewImages(newImages)
            .flatMap { [weak self] newImagePaths -> Observable<Mutation> in
                guard let self = self else { return .empty() }
                return self.updateStoreInfo(newImagePaths)
            }
    }

    // 새 이미지 업로드
    private func uploadNewImages(_ newImages: [ExtendedImage]) -> Observable<[String]> {
        let uuid = UUID().uuidString
        let updatedImages = newImages.enumerated().map { index, image in
            let filePath = "PopUpImage/\(currentState.name)/\(uuid)/\(index).jpg"
            return ExtendedImage(
                filePath: filePath,
                image: image.image,
                isMain: image.isMain)
        }

        return preSignedUseCase.tryUpload(presignedURLRequest: updatedImages.map {
            return (filePath: $0.filePath, image: $0.image)
        })
        .asObservable()
        .map { _ in updatedImages.map { $0.filePath } }
    }

    // 스토어 정보 업데이트
    private func updateStoreInfo(_ newImagePaths: [String]?) -> Observable<Mutation> {
        guard let storeId = editingStoreId else {
            return .just(.setError("스토어 ID가 없습니다."))
        }

        let state = self.currentState
        let dates = prepareDateTime(state: state)

        // 모든 이미지 경로 (기존 이미지 + 새 이미지)
        var allPaths: [String] = []

        // 삭제되지 않은 기존 이미지 경로 추가
        let deletedIdSet = Set(state.deletedImageIds)
        for (path, id) in state.originalImageIds {
            if !deletedIdSet.contains(id) {
                allPaths.append(path)
            }
        }

        // 새로 업로드된 이미지 경로 추가
        if let newPaths = newImagePaths {
            allPaths.append(contentsOf: newPaths)
        }

        // 메인 이미지 경로 결정
        let mainImage: String
        if let mainImg = state.images.first(where: { $0.isMain }) {
            if state.originalImageIds.keys.contains(mainImg.filePath) {
                // 기존 이미지가 메인
                mainImage = mainImg.filePath
            } else {
                // 새 이미지가 메인인 경우
                // 현재 이미지 배열에서의 위치 찾기
                let idx = state.images.firstIndex(where: { $0.filePath == mainImg.filePath }) ?? 0

                // 해당 위치가 새 이미지 배열 범위 내에 있는지 확인
                if let newPaths = newImagePaths, idx < newPaths.count {
                    mainImage = newPaths[idx]
                } else if !allPaths.isEmpty {
                    mainImage = allPaths[0]
                } else {
                    mainImage = ""
                }
            }
        } else if !allPaths.isEmpty {
            mainImage = allPaths[0]
        } else {
            mainImage = ""
        }

        let params = UpdateStoreParams(
            id: storeId,
            name: state.name,
            categoryId: state.categoryId,
            desc: state.description,
            address: state.address,
            startDate: dates.startDate,
            endDate: dates.endDate,
            mainImageUrl: mainImage,
            imageUrlList: allPaths,
            imagesToDelete: state.deletedImageIds,
            latitude: Double(state.lat) ?? 0,
            longitude: Double(state.lon) ?? 0,
            markerTitle: state.markerTitle,
            markerSnippet: state.markerSnippet,
            startDateBeforeEndDate: true
        )

        return self.adminUseCase.updateStore(params: params)
            .andThen(Observable.just(.setSuccess(true)))

    }
}
