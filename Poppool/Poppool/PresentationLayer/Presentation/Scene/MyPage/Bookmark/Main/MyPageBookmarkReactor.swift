//
//  MyPageBookmarkReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/14/25.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class MyPageBookmarkReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case changePage
        case backButtonTapped(controller: BaseViewController)
        case cellTapped(controller: BaseViewController, row: Int)
        case dropDownButtonTapped(controller: BaseViewController)
        case emptyButtonTapped(controller: BaseViewController)
        case bookMarkButtonTapped(row: Int)
    }

    enum Mutation {
        case loadView
        case skip
        case moveToRecentScene(controller: BaseViewController)
        case moveToDetailScene(controller: BaseViewController, row: Int)
        case presentModal(controller: BaseViewController)
        case moveToSuggestScene(controller: BaseViewController)
    }

    struct State {
        var sections: [any Sectionable] = []
        var isReloadView: Bool = false
        var isEmptyCase: Bool = false
        var count: Int32 = 0
        var buttonTitle: String?
    }

    // MARK: - properties

    var initialState: State
    var disposeBag = DisposeBag()
    private var isLoading: Bool = false
    private var totalPage: Int32 = 0
    private var totalElement: Int32 = 0
    private var currentPage: Int32 = 0
    private var size: Int32 = 10
    private var viewType: String = "크게보기"

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

    private var listSection = RecentPopUpSection(inputDataList: [])
    private var cardListSection = PopUpCardSection(inputDataList: [])
    private var spacing12Section = SpacingSection(inputDataList: [.init(spacing: 12)])
    private var spacing150Section = SpacingSection(inputDataList: [.init(spacing: 150)])

    // MARK: - init
    init(userAPIUseCase: UserAPIUseCase) {
        self.userAPIUseCase = userAPIUseCase
        self.initialState = State()
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            currentPage = 0
            return userAPIUseCase.getBookmarkPopUp(page: currentPage, size: size, sort: nil)
                .withUnretained(self)
                .map { (owner, response) in
                    owner.listSection.inputDataList = response.popUpInfoList.map {
                        .init(imagePath: $0.mainImageUrl,
                              date: $0.endDate,
                              title: $0.popUpStoreName,
                              id: $0.popUpStoreId,
                              isBookMark: true
                        )
                    }
                    owner.cardListSection.inputDataList = response.popUpInfoList.map {
                        .init(
                            imagePath: $0.mainImageUrl,
                            date: ($0.startDate ?? "") + " - " + ($0.endDate ?? ""),
                            title: $0.popUpStoreName,
                            id: $0.popUpStoreId,
                            address: $0.address,
                            isBookMark: true
                        )
                    }
                    owner.totalPage = response.totalPages
                    owner.totalElement = response.totalElements
                    return .loadView
                }
        case .changePage:
            if isLoading {
                return Observable.just(.skip)
            } else {
                if currentPage <= totalPage {
                    isLoading = true
                    currentPage += 1
                    return userAPIUseCase.getBookmarkPopUp(page: currentPage, size: size, sort: nil)
                        .withUnretained(self)
                        .map { (owner, response) in
                            owner.listSection.inputDataList.append(contentsOf: response.popUpInfoList.map {
                                .init(
                                    imagePath: $0.mainImageUrl,
                                    date: $0.endDate,
                                    title: $0.popUpStoreName,
                                    id: $0.popUpStoreId,
                                    isBookMark: true
                                )
                            })
                            owner.cardListSection.inputDataList.append(contentsOf: response.popUpInfoList.map {
                                .init(
                                    imagePath: $0.mainImageUrl,
                                    date: ($0.startDate ?? "") + " - " + ($0.endDate ?? ""),
                                    title: $0.popUpStoreName,
                                    id: $0.popUpStoreId,
                                    address: $0.address,
                                    isBookMark: true
                                )
                            })
                            return .loadView
                        }
                } else {
                    return Observable.just(.skip)
                }
            }
        case .backButtonTapped(let controller):
            return Observable.just(.moveToRecentScene(controller: controller))
        case .cellTapped(let controller, let row):
            return Observable.just(.moveToDetailScene(controller: controller, row: row))
        case .dropDownButtonTapped(let controller):
            return Observable.just(.presentModal(controller: controller))
        case .emptyButtonTapped(let controller):
            return Observable.just(.moveToSuggestScene(controller: controller))
        case .bookMarkButtonTapped(let row):
            let popUpID = cardListSection.inputDataList[row].id
            cardListSection.inputDataList[row].isBookMark.toggle()
            listSection.inputDataList[row].isBookMark?.toggle()
            ToastMaker.createBookMarkToast(isBookMark: cardListSection.inputDataList[row].isBookMark)
            if cardListSection.inputDataList[row].isBookMark {
                return userAPIUseCase.postBookmarkPopUp(popUpID: popUpID)
                    .andThen(Observable.just(.loadView))
            } else {
                return userAPIUseCase.deleteBookmarkPopUp(popUpID: popUpID)
                    .andThen(Observable.just(.loadView))
            }
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.isReloadView = false
        switch mutation {
        case .loadView:
            newState.isReloadView = true
        case .skip:
            break
        case .moveToRecentScene(let controller):
            controller.navigationController?.popViewController(animated: true)
        case .moveToDetailScene(let controller, let row):
            let nextController = DetailController()
            nextController.reactor = DetailReactor(
                popUpID: listSection.inputDataList[row].id,
                userAPIUseCase: userAPIUseCase
            )
            controller.navigationController?.pushViewController(nextController, animated: true)
        case .presentModal(let controller):
            let nextController = BookMarkPopUpViewTypeModalController()
            nextController.reactor = BookMarkPopUpViewTypeModalReactor(sortedCode: viewType)
            controller.presentPanModal(nextController)
            nextController.reactor?.state
                .withUnretained(self)
                .subscribe(onNext: { (owner, state) in
                    if state.isSave {
                        owner.viewType = state.currentSortedCode ?? ""
                        ToastMaker.createToast(message: "보기 옵션을 적용했어요")
                    }
                })
                .disposed(by: nextController.disposeBag)
        case .moveToSuggestScene(let controller):
            let nextController = HomeListController()
            nextController.reactor = HomeListReactor(
                popUpType: .curation,
                userAPIUseCase: userAPIUseCase
            )
            controller.navigationController?.pushViewController(nextController, animated: true)
        }
        newState.sections = getSection()
        newState.isEmptyCase = listSection.isEmpty
        newState.count = totalElement
        newState.buttonTitle = viewType
        return newState
    }

    func getSection() -> [any Sectionable] {
        return [
            spacing12Section,
            viewType == "크게보기" ? cardListSection : listSection,
            spacing150Section
        ]
    }
}
