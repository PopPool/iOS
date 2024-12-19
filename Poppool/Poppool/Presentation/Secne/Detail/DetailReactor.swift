//
//  DetailReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/9/24.
//

import UIKit

import ReactorKit
import RxSwift
import RxCocoa

final class DetailReactor: Reactor {
    
    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case commentButtonTapped(controller: BaseViewController)
    }
    
    enum Mutation {
        case loadView
        case moveToCommentTypeSelectedScene(controller: BaseViewController)
    }
    
    struct State {
        var sections: [any Sectionable] = []
    }
    
    // MARK: - properties
    
    var initialState: State
    var disposeBag = DisposeBag()
    private let popUpID: Int64
    private var popUpName: String?
    
    private let popUpAPIUseCase = PopUpAPIUseCaseImpl(repository: PopUpAPIRepositoryImpl(provider: ProviderImpl()))
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
    
    private var imageBannerSection = ImageBannerSection(inputDataList: [])
    private var titleSection = DetailTitleSection(inputDataList: [.init(title: "hi", isBookMark: false)])
    private var contentSection = DetailContentSection(inputDataList: [])
    private var infoSection = DetailInfoSection(inputDataList: [])
    private var commentTitleSection = DetailCommentTitleSection(inputDataList: [])
    private var commentSection = DetailCommentSection(inputDataList: [])
    private var similarTitleSecion = SearchTitleSection(inputDataList: [.init(title: "지금 보고있는 팝업과 비슷한 팝업")])
    private var similarSection = DetailSimilarSection(inputDataList: [])
    
    
    private var spacing70Section = SpacingSection(inputDataList: [.init(spacing: 70)])
    private var spacing40Section = SpacingSection(inputDataList: [.init(spacing: 40)])
    private var spacing36Section = SpacingSection(inputDataList: [.init(spacing: 36)])
    private var spacing28Section = SpacingSection(inputDataList: [.init(spacing: 28)])
    private var spacing24Section = SpacingSection(inputDataList: [.init(spacing: 24)])
    private var spacing20Section = SpacingSection(inputDataList: [.init(spacing: 20)])
    private var spacing16Section = SpacingSection(inputDataList: [.init(spacing: 16)])
    private var spacing16GraySection = SpacingSection(inputDataList: [.init(spacing: 16, backgroundColor: .g50)])
    // MARK: - init
    init(popUpID: Int64) {
        self.popUpID = popUpID
        self.initialState = State()
    }
    
    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return setContent()
        case .commentButtonTapped(let controller):
            return Observable.just(.moveToCommentTypeSelectedScene(controller: controller))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .loadView:
            newState.sections = getSection()
        case .moveToCommentTypeSelectedScene(let controller):
            let nextController = CommentSelectedController()
            nextController.reactor = CommentSelectedReactor()
            controller.presentPanModal(nextController)
            nextController.reactor?.state
                .withUnretained(nextController)
                .subscribe(onNext: { (nextController, state) in
                    switch state.selectedType {
                    case .cancel:
                        nextController.dismiss(animated: true)
                    case .normal:
                        nextController.dismiss(animated: true) {
                            let commentController = NormalCommentAddController()
                            commentController.reactor = NormalCommentAddReactor(popUpID: self.popUpID, popUpName: self.popUpName ?? "")
                            controller.navigationController?.pushViewController(commentController, animated: true)
                        }
                    case .insta:
                        nextController.dismiss(animated: true) {
                            let commentController = InstaCommentAddController()
                            commentController.reactor = InstaCommentAddReactor()
                            controller.navigationController?.pushViewController(commentController, animated: true)
                        }
                    case .none:
                        break
                    }
                })
                .disposed(by: disposeBag)
        }
        return newState
    }
    
    func getSection() -> [any Sectionable] {
        return [
            imageBannerSection,
            spacing36Section,
            titleSection,
            spacing20Section,
            contentSection,
            spacing28Section,
            infoSection,
            spacing40Section,
            spacing16GraySection,
            spacing36Section,
            commentTitleSection,
            spacing16Section,
            commentSection,
            spacing40Section,
            similarTitleSecion,
            spacing24Section,
            similarSection,
            spacing70Section
        ]
    }
    
    func setContent() -> Observable<Mutation> {
        return popUpAPIUseCase.getPopUpDetail(commentType: "NORMAL", popUpStoredId: popUpID)
            .withUnretained(self)
            .map { (owner, response) in
                
                // image Banner
                let imagePaths = response.imageList.compactMap { $0.imageUrl }
                let idList = response.imageList.map { $0.id }
                owner.imageBannerSection.inputDataList = [.init(imagePaths: imagePaths, idList: idList, isHiddenPauseButton: true)]
                
                // titleSection
                owner.titleSection.inputDataList = [.init(title: response.name, isBookMark: response.bookmarkYn)]
                owner.popUpName = response.name
                
                // contentSection
                let testText = "1231231231231231232314123413412341234123412341341234123412412341234141341234141234124123412341234123-84901283409182309481209384-01238-94081290384-90182-903849012-9038490182-30948-90182-30948-901238-9048-0921384-098213-9084-09123809481-2093840981-02938409812-3094809128-03948091238-094091238904-812-0938409182-03948091283-0948-0912384-90"
                //                owner.contentSection.inputDataList = [.init(content: response.desc)]
                owner.contentSection.inputDataList = [.init(content: testText)]
                owner.infoSection.inputDataList = [.init(
                    startDate: response.startDate,
                    endDate: response.endDate,
                    startTime: response.startTime,
                    endTime: response.endTime,
                    address: response.address)
                ]
                owner.commentTitleSection.inputDataList = [.init(commentCount: response.commentCount)]
                owner.commentSection.inputDataList = response.commentList.map({ response in
                    return .init(
                        nickName: response.nickname,
                        profileImagePath: response.profileImageUrl,
                        date: response.createDateTime,
                        comment: response.content,
                        imageList: response.commentImageList.map { $0.imageUrl }
                    )
                })
                
                owner.similarSection.inputDataList = response.similarPopUpStoreList.map {
                    return .init(imagePath: $0.mainImageUrl, date: $0.endDate, title: $0.name)
                }
                print(response)
                return .loadView
            }
    }
}
