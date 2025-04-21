import UIKit

import DomainInterface
import Infrastructure

import ReactorKit
import RxCocoa
import RxSwift

final class SearchResultReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case returnSearch(text: String)
        case bookmarkButtonTapped(indexPath: IndexPath)
        case cellTapped(controller: BaseViewController, indexPath: IndexPath)
    }

    enum Mutation {
        case loadView
        case emptyView
        case moveToDetailScene(controller: BaseViewController, indexPath: IndexPath)
    }

    struct State {
        var sections: [any Sectionable] = []
        var isEmptyResult: Bool = false
    }

    // MARK: - properties

    var initialState: State
    var disposeBag = DisposeBag()
    private var popUpAPIUseCase: PopUpAPIUseCase
    private let userAPIUseCase: UserAPIUseCase
    lazy var compositionalLayout: UICollectionViewCompositionalLayout = {
        UICollectionViewCompositionalLayout { [weak self] section, env in
            guard let self = self else {
                return NSCollectionLayoutSection(group: NSCollectionLayoutGroup(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)
                    ))
                )
            }
            return getSection()[section].getSection(section: section, env: env)
        }
    }()

    private var titleSection = SearchTitleSection(inputDataList: [.init(title: "포함된 팝업", buttonTitle: nil)])
    private var searchCountSection = SearchResultCountSection(inputDataList: [.init(count: 65)])
    private var searchListSection = HomeCardGridSection(inputDataList: [])
    private let spacing24Section = SpacingSection(inputDataList: [.init(spacing: 24)])
    private let spacing16Section = SpacingSection(inputDataList: [.init(spacing: 16)])
    private let spacing64Section = SpacingSection(inputDataList: [.init(spacing: 64)])

    // MARK: - init
    init(
        userAPIUseCase: UserAPIUseCase,
        popUpAPIUseCase: PopUpAPIUseCase
    ) {
        self.userAPIUseCase = userAPIUseCase
        self.popUpAPIUseCase = popUpAPIUseCase
        self.initialState = State()
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .cellTapped(let controller, let indexPath):
            return Observable.just(.moveToDetailScene(controller: controller, indexPath: indexPath))
        case .returnSearch(let text):
            if hasFinalConsonant(text) {
                titleSection.inputDataList = [.init(title: "\(text)이 포함된 팝업")]
            } else {
                titleSection.inputDataList = [.init(title: "\(text)가 포함된 팝업")]
            }
            return popUpAPIUseCase.getSearchPopUpList(query: text)
                .withUnretained(self)
                .map { (owner, response) in
                    owner.searchCountSection.inputDataList = [.init(count: response.popUpStoreList.count)]
                    let isLogin = response.loginYn
                    owner.searchListSection.inputDataList = response.popUpStoreList.map({ response in
                        return .init(
                            imagePath: response.mainImageUrl,
                            id: response.id,
                            category: response.category,
                            title: response.name,
                            address: response.address,
                            startDate: response.startDate,
                            endDate: response.endDate,
                            isBookmark: response.bookmarkYn,
                            isLogin: isLogin
                        )
                    })
                    return .loadView
                }
                .catch { _ in
                    return Observable.just(.emptyView)
                }
        case .bookmarkButtonTapped(let indexPath):
            let data = searchListSection.inputDataList[indexPath.row]
            let isBookmark = data.isBookmark
            let id = data.id
            searchListSection.inputDataList[indexPath.row].isBookmark.toggle()
            ToastMaker.createBookMarkToast(isBookMark: !isBookmark)
            if isBookmark {
                return userAPIUseCase.deleteBookmarkPopUp(popUpID: id)
                    .andThen(Observable.just(.loadView))
            } else {
                return userAPIUseCase.postBookmarkPopUp(popUpID: id)
                    .andThen(Observable.just(.loadView))
            }
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .loadView:
            newState.isEmptyResult = searchListSection.isEmpty
            newState.sections = getSection()
        case .emptyView:
            newState.isEmptyResult = true
        case .moveToDetailScene(let controller, let indexPath):
            let nextController = DetailController()
            nextController.reactor = DetailReactor(
                popUpID: searchListSection.inputDataList[indexPath.row].id,
                userAPIUseCase: userAPIUseCase,
                popUpAPIUseCase: popUpAPIUseCase,
                commentAPIUseCase: DIContainer.resolve(CommentAPIUseCase.self),
                preSignedUseCase: DIContainer.resolve(PreSignedUseCase.self)
            )
            controller.navigationController?.pushViewController(nextController, animated: true)
        }
        return newState
    }

    func getSection() -> [any Sectionable] {
        return [
            spacing24Section,
            titleSection,
            searchCountSection,
            spacing16Section,
            searchListSection,
            spacing64Section
        ]
    }
    func hasFinalConsonant(_ text: String) -> Bool {
        guard let lastCharacter = text.last else { return false }

        let unicodeValue = Int(lastCharacter.unicodeScalars.first!.value)

        // 한글 유니코드 범위 체크
        let base = 0xAC00
        let last = 0xD7A3
        guard base...last ~= unicodeValue else { return false }

        // 종성 인덱스 계산 (받침이 있으면 1 이상)
        let finalConsonantIndex = (unicodeValue - base) % 28
        return finalConsonantIndex != 0
    }
}
