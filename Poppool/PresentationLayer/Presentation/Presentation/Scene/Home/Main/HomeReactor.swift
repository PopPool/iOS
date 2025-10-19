import UIKit

import DesignSystem
import DomainInterface
import Infrastructure
import SearchFeatureInterface

import ReactorKit
import RxCocoa
import RxSwift

final class HomeReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case changeHeaderState(isDarkMode: Bool)
        case detailButtonTapped(controller: BaseViewController, indexPath: IndexPath)
        case bookMarkButtonTapped(indexPath: IndexPath)
        case searchButtonTapped(controller: BaseViewController)
        case collectionViewCellTapped(controller: BaseViewController, indexPath: IndexPath)
        case bannerCellTapped(controller: BaseViewController, row: Int)
        case changeIndicatorColor(controller: BaseViewController, row: Int)
    }

    enum Mutation {
        case loadView
        case setHedaerState(isDarkMode: Bool)
        case moveToDetailScene(controller: BaseViewController, indexPath: IndexPath)
        case reloadView(indexPath: IndexPath)
        case moveToSearchScene(controller: BaseViewController)
        case skip
    }

    struct State {
        var sections: [any Sectionable] = []
        var headerIsDarkMode: Bool = true
        var isReloadView: Bool = false
    }

    // MARK: - properties

    var initialState: State

    var disposeBag = DisposeBag()

    private let homeAPIUseCase: HomeAPIUseCase
    private let userAPIUseCase: UserAPIUseCase
    private let userDefaultService = UserDefaultService()

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
    private var isLoign: Bool = false
    private var loginImageBannerSection = ImageBannerSection(inputDataList: [])
    private var curationTitleSection = HomeTitleSection(inputDataList: [])
    private var curationSection = HomeCardSection(inputDataList: [])
    private var popularTitleSection = HomeTitleSection(inputDataList: [
        .init(blueText: "팝풀이", topSubText: "들은 지금 이런", bottomText: "팝업에 가장 관심있어요", backgroundColor: .g700, textColor: .w100)
    ])
    private var popularSection = HomePopularCardSection(
        inputDataList: [],
        decorationItems: [
            SectionDecorationItem(
                elementKind: "BackgroundView",
                reusableView: SectionBackGroundDecorationView(),
                viewInput: .init(backgroundColor: .g700)
            )
        ]
    )
    private var newTitleSection = HomeTitleSection(inputDataList: [.init(blueText: "제일 먼저", topSubText: "피드 올리는", bottomText: "신규 오픈 팝업")])
    private var newSection = HomeCardSection(inputDataList: [])
    private var spaceClear48Section = SpacingSection(inputDataList: [.init(spacing: 48)])
    private var spaceClear40Section = SpacingSection(inputDataList: [.init(spacing: 40)])
    private var spaceClear28Section = SpacingSection(inputDataList: [.init(spacing: 28)])
    private var spaceClear24Section = SpacingSection(inputDataList: [.init(spacing: 24)])
    private var spaceGray40Section = SpacingSection(inputDataList: [.init(spacing: 40, backgroundColor: .g700)])
    private var spaceGray28Section = SpacingSection(inputDataList: [.init(spacing: 28, backgroundColor: .g700)])
    private var spaceGray24Section = SpacingSection(inputDataList: [.init(spacing: 24, backgroundColor: .g700)])

    // MARK: - init
    init(
        userAPIUseCase: UserAPIUseCase,
        homeAPIUseCase: HomeAPIUseCase
    ) {
        self.userAPIUseCase = userAPIUseCase
        self.homeAPIUseCase = homeAPIUseCase
        self.initialState = State()
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .changeIndicatorColor(let controller, let row):
            return Observable.just(.skip)
        case .viewWillAppear:
            return homeAPIUseCase.fetchHome(page: 0, size: 6, sort: "viewCount,desc")
                .withUnretained(self)
                .map { (owner, response) in
                    owner.setBannerSection(response: response)
                    owner.setCurationTitleSection(response: response)
                    owner.setCurationSection(response: response)
                    owner.setPopularSection(response: response)
                    owner.setNewSection(response: response)
                    owner.isLoign = response.loginYn
                    return .loadView
                }
        case .changeHeaderState(let isDarkMode):
            return Observable.just(.setHedaerState(isDarkMode: isDarkMode))
        case .detailButtonTapped(let controller, let indexPath):
            return Observable.just(.moveToDetailScene(controller: controller, indexPath: indexPath))
        case .bookMarkButtonTapped(let indexPath):
            let popUpData = getPopUpData(indexPath: indexPath)
            ToastMaker.createBookMarkToast(isBookMark: !popUpData.isBookmark)
            if popUpData.isBookmark {
                return userAPIUseCase.deleteBookmarkPopUp(popUpID: popUpData.id)
                    .andThen(Observable.just(.reloadView(indexPath: indexPath)))
            } else {
                return userAPIUseCase.postBookmarkPopUp(popUpID: popUpData.id)
                    .andThen(Observable.just(.reloadView(indexPath: indexPath)))
            }
        case .searchButtonTapped(let controller):
            return Observable.just(.moveToSearchScene(controller: controller))
        case .collectionViewCellTapped(let controller, let indexPath):
            return Observable.just(.moveToDetailScene(controller: controller, indexPath: indexPath))
        case .bannerCellTapped(let controller, let row):
            return Observable.just(.moveToDetailScene(controller: controller, indexPath: IndexPath(row: row, section: 0)))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.isReloadView = false
        switch mutation {
        case .moveToSearchScene(let controller):
            @Dependency var factory: PopupSearchFactory
            controller.navigationController?.pushViewController(factory.make(), animated: true)
        case .loadView:
            newState.isReloadView = true
            newState.sections = getSection()
        case .setHedaerState(let isDarkMode):
            newState.headerIsDarkMode = isDarkMode
        case .moveToDetailScene(let controller, let indexPath):
            getDetailController(indexPath: indexPath, currentController: controller)
        case .reloadView(let indexPath):
            if isLoign {
                switch indexPath.section {
                case 4:
                    curationSection.inputDataList[indexPath.row].isBookmark.toggle()
                default:
                    newSection.inputDataList[indexPath.row].isBookmark.toggle()
                }
            } else {
                switch indexPath.section {
                default:
                    newSection.inputDataList[indexPath.row].isBookmark.toggle()
                }
            }
            newState.isReloadView = true
            newState.sections = getSection()
        case .skip:
            break
        }
        return newState
    }

    func getSection() -> [any Sectionable] {

        if isLoign {
            return [
                loginImageBannerSection,
                spaceClear40Section,
                curationTitleSection,
                spaceClear24Section,
                curationSection,
                spaceClear40Section,
                spaceGray28Section,
                popularTitleSection,
                spaceGray24Section,
                popularSection,
                spaceGray28Section,
                spaceClear48Section
            ] + getNewSection()
        } else {
            return [
                loginImageBannerSection,
                spaceGray40Section,
                popularTitleSection,
                spaceGray24Section,
                popularSection,
                spaceGray28Section,
                spaceClear48Section
            ] + getNewSection()
        }

    }

    func getNewSection() -> [any Sectionable] {
        if newSection.isEmpty {
            return []
        } else {
            return [
                newTitleSection,
                spaceClear24Section,
                newSection,
                spaceClear48Section
            ]
        }
    }

    func setBannerSection(response: GetHomeInfoResponse) {
        let imagePaths = response.bannerPopUpStoreList.map { $0.mainImageUrl }
        let idList = response.bannerPopUpStoreList.map { $0.id }
        loginImageBannerSection.inputDataList = imagePaths.isEmpty ? [] : [.init(imagePaths: imagePaths, idList: idList)]
    }

    func setCurationTitleSection(response: GetHomeInfoResponse) {
        curationTitleSection.inputDataList = [.init(blueText: response.nickname, topSubText: "님을 위한", bottomText: "맞춤 팝업 큐레이션")]
    }

    func setCurationSection(response: GetHomeInfoResponse) {
        let islogin = response.loginYn
        curationSection.inputDataList = response.customPopUpStoreList.map({ response in
            return .init(
                imagePath: response.mainImageUrl,
                id: response.id,
                category: response.category,
                title: response.name,
                address: response.address,
                startDate: response.startDate,
                endDate: response.endDate,
                isBookmark: response.bookmarkYn,
                isLogin: islogin
            )
        })
    }

    func setPopularSection(response: GetHomeInfoResponse) {
        popularSection.inputDataList = response.popularPopUpStoreList.map({ response in
            return .init(
                imagePath: response.mainImageUrl,
                endDate: response.endDate,
                category: response.category,
                title: response.name,
                id: response.id,
                address: response.address
            )
        })
    }

    func setNewSection(response: GetHomeInfoResponse) {
        let islogin = response.loginYn
        newSection.inputDataList = response.newPopUpStoreList.map({ response in
            return .init(
                imagePath: response.mainImageUrl,
                id: response.id,
                category: response.category,
                title: response.name,
                address: response.address,
                startDate: response.startDate,
                endDate: response.endDate,
                isBookmark: response.bookmarkYn,
                isLogin: islogin
            )
        })
    }

    func getDetailController(indexPath: IndexPath, currentController: BaseViewController) {
        if isLoign {
            switch indexPath.section {
            case 0:
                if let id = loginImageBannerSection.inputDataList.first?.idList[indexPath.row - 1] {
                    let controller = DetailController()
                    controller.reactor = DetailReactor(
                        popUpID: id,
                        userAPIUseCase: userAPIUseCase,
                        popUpAPIUseCase: DIContainer.resolve(PopUpAPIUseCase.self),
                        commentAPIUseCase: DIContainer.resolve(CommentAPIUseCase.self),
                        preSignedUseCase: DIContainer.resolve(PreSignedUseCase.self)
                    )
                    currentController.navigationController?.pushViewController(controller, animated: true)
                }
            case 2:
                let controller = HomeListController()
                controller.reactor = HomeListReactor(
                    popUpType: .curation,
                    userAPIUseCase: userAPIUseCase,
                    homeAPIUseCase: homeAPIUseCase
                )
                currentController.navigationController?.pushViewController(controller, animated: true)
            case 4:
                let id = curationSection.inputDataList[indexPath.row].id
                let controller = DetailController()
                controller.reactor = DetailReactor(
                    popUpID: id,
                    userAPIUseCase: userAPIUseCase,
                    popUpAPIUseCase: DIContainer.resolve(PopUpAPIUseCase.self),
                    commentAPIUseCase: DIContainer.resolve(CommentAPIUseCase.self),
                    preSignedUseCase: DIContainer.resolve(PreSignedUseCase.self)
                )
                currentController.navigationController?.pushViewController(controller, animated: true)
            case 7:
                let controller = HomeListController()
                controller.reactor = HomeListReactor(
                    popUpType: .popular,
                    userAPIUseCase: userAPIUseCase,
                    homeAPIUseCase: homeAPIUseCase
                )
                currentController.navigationController?.pushViewController(controller, animated: true)
            case 9:
                let id = popularSection.inputDataList[indexPath.row].id
                let controller = DetailController()
                controller.reactor = DetailReactor(
                    popUpID: id,
                    userAPIUseCase: userAPIUseCase,
                    popUpAPIUseCase: DIContainer.resolve(PopUpAPIUseCase.self),
                    commentAPIUseCase: DIContainer.resolve(CommentAPIUseCase.self),
                    preSignedUseCase: DIContainer.resolve(PreSignedUseCase.self)
                )
                currentController.navigationController?.pushViewController(controller, animated: true)
            case 12:
                let controller = HomeListController()
                controller.reactor = HomeListReactor(
                    popUpType: .new,
                    userAPIUseCase: userAPIUseCase,
                    homeAPIUseCase: homeAPIUseCase
                )
                currentController.navigationController?.pushViewController(controller, animated: true)
            case 14:
                let id = newSection.inputDataList[indexPath.row].id
                let controller = DetailController()
                controller.reactor = DetailReactor(
                    popUpID: id,
                    userAPIUseCase: userAPIUseCase,
                    popUpAPIUseCase: DIContainer.resolve(PopUpAPIUseCase.self),
                    commentAPIUseCase: DIContainer.resolve(CommentAPIUseCase.self),
                    preSignedUseCase: DIContainer.resolve(PreSignedUseCase.self)
                )
                currentController.navigationController?.pushViewController(controller, animated: true)
            default:
                break
            }
        } else {
            switch indexPath.section {
            case 0:
				if indexPath.row == 0,
				   let id = loginImageBannerSection.inputDataList.first?.idList[indexPath.row] {
					moveToDetail(id: id)
				} else if indexPath.row != 0,
				   let id = loginImageBannerSection.inputDataList.first?.idList[indexPath.row - 1] {
					moveToDetail(id: id)
                }

				func moveToDetail(id: Int64) {
					let controller = DetailController()
					controller.reactor = DetailReactor(
						popUpID: id,
						userAPIUseCase: userAPIUseCase,
						popUpAPIUseCase: DIContainer.resolve(PopUpAPIUseCase.self),
						commentAPIUseCase: DIContainer.resolve(CommentAPIUseCase.self),
						preSignedUseCase: DIContainer.resolve(PreSignedUseCase.self)
					)
					currentController.navigationController?.pushViewController(controller, animated: true)
				}

            case 2:
                let controller = HomeListController()
                controller.reactor = HomeListReactor(
                    popUpType: .popular,
                    userAPIUseCase: userAPIUseCase,
                    homeAPIUseCase: homeAPIUseCase
                )
                currentController.navigationController?.pushViewController(controller, animated: true)
            case 4:
                let id = popularSection.inputDataList[indexPath.row].id
                let controller = DetailController()
                controller.reactor = DetailReactor(
                    popUpID: id,
                    userAPIUseCase: userAPIUseCase,
                    popUpAPIUseCase: DIContainer.resolve(PopUpAPIUseCase.self),
                    commentAPIUseCase: DIContainer.resolve(CommentAPIUseCase.self),
                    preSignedUseCase: DIContainer.resolve(PreSignedUseCase.self)
                )
                currentController.navigationController?.pushViewController(controller, animated: true)
            case 7:
                let controller = HomeListController()
                controller.reactor = HomeListReactor(
                    popUpType: .new,
                    userAPIUseCase: userAPIUseCase,
                    homeAPIUseCase: homeAPIUseCase
                )
                currentController.navigationController?.pushViewController(controller, animated: true)
            case 9:
                let id = newSection.inputDataList[indexPath.row].id
                let controller = DetailController()
                controller.reactor = DetailReactor(
                    popUpID: id,
                    userAPIUseCase: userAPIUseCase,
                    popUpAPIUseCase: DIContainer.resolve(PopUpAPIUseCase.self),
                    commentAPIUseCase: DIContainer.resolve(CommentAPIUseCase.self),
                    preSignedUseCase: DIContainer.resolve(PreSignedUseCase.self)
                )
                currentController.navigationController?.pushViewController(controller, animated: true)
            default:
                break
            }
        }
    }

    func getPopUpData(indexPath: IndexPath) -> HomeCardSectionCell.Input {
        if isLoign {
            switch indexPath.section {
            case 4:
                return curationSection.inputDataList[indexPath.row]
            default:
                return newSection.inputDataList[indexPath.row]
            }
        } else {
            switch indexPath.section {
            default:
                return newSection.inputDataList[indexPath.row]
            }
        }
    }
}
