import PhotosUI
import UIKit

import DomainInterface
import Infrastructure
import DesignSystem

import ReactorKit
import RxCocoa
import RxSwift

final class NormalCommentAddReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case photoAddButtonTapped(controller: BaseViewController)
        case setImage(images: [UIImage?])
        case imageDeleteButtonTapped(indexPath: IndexPath)
        case backButtonTapped(controller: BaseViewController)
        case inputComment(text: String?)
        case saveButtonTapped(controller: BaseViewController)
    }

    enum Mutation {
        case loadView
        case showImagePicker(controller: BaseViewController)
        case showCheckModal(controller: BaseViewController)
        case setComment(text: String?)
        case save(controller: BaseViewController)
    }

    struct State {
        var sections: [any Sectionable] = []
        var text: String?
        var isReloadView: Bool = true
        var isSaving: Bool = false
    }

    // MARK: - properties

    var initialState: State
    var disposeBag = DisposeBag()
    private var popUpID: Int64
    private var popUpName: String

    private let commentAPIUseCase: CommentAPIUseCase
    private let preSignedUseCase: PreSignedUseCase

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
    private let photoTitleSection = AddCommentTitleSection(inputDataList: [.init(title: "사진 선택")])
    private lazy var photoDescriptionSection = AddCommentDescriptionSection(inputDataList: [.init(description: "\(self.popUpName)과 관련있는 사진을 업로드해보세요.")])
    private var imageSection = AddCommentImageSection(inputDataList: [.init(isFirstCell: true)])
    private let commentTitleSection = AddCommentTitleSection(inputDataList: [.init(title: "코멘트 작성")])
    private lazy var commentDescriptionSection = AddCommentDescriptionSection(inputDataList: [.init(description: "방문했던 \(self.popUpName)에 대한 감상평을 작성해주세요.")])
    private var commentSection = AddCommentSection(inputDataList: [.init()])
    private let spacing25Section = SpacingSection(inputDataList: [.init(spacing: 25)])
    private let spacing5Section = SpacingSection(inputDataList: [.init(spacing: 5)])
    private let spacing16Section = SpacingSection(inputDataList: [.init(spacing: 16)])
    private let spacing32Section = SpacingSection(inputDataList: [.init(spacing: 32)])
    // MARK: - init
    init(
        popUpID: Int64,
        popUpName: String,
        commentAPIUseCase: CommentAPIUseCase,
        preSignedUseCase: PreSignedUseCase
    ) {
        self.initialState = State()
        self.popUpID = popUpID
        self.popUpName = popUpName
        self.commentAPIUseCase = commentAPIUseCase
        self.preSignedUseCase = preSignedUseCase
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return Observable.just(.loadView)
        case .photoAddButtonTapped(let controller):
            return Observable.just(.showImagePicker(controller: controller))
        case .setImage(let images):
            imageSection.inputDataList = [.init(isFirstCell: true)] + images.map { return .init(image: $0)}
            return Observable.just(.loadView)
        case .imageDeleteButtonTapped(let indexPath):
            imageSection.inputDataList.remove(at: indexPath.row)
            return Observable.just(.loadView)
        case .backButtonTapped(let controller):
            return Observable.just(.showCheckModal(controller: controller))
        case .inputComment(let text):
            commentSection.inputDataList[0].text = text
            return Observable.just(.setComment(text: text))
        case .saveButtonTapped(let controller):
            return Observable.just(.save(controller: controller))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.isReloadView = false
        switch mutation {
        case .loadView:
            newState.isReloadView = true
            newState.sections = getSection()
        case .showImagePicker(let controller):
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 5
            configuration.filter = .images
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            controller.present(picker, animated: true, completion: nil)
        case .showCheckModal(let controller):
            let nextController = CommentCheckController()
            nextController.reactor = CommentCheckReactor()
            controller.presentPanModal(nextController)
            nextController.reactor?.state
                .withUnretained(nextController)
                .subscribe(onNext: { (nextController, state) in
                    switch state.selectedType {
                    case .none:
                        break
                    case .continues:
                        nextController.dismiss(animated: true)
                    case .stop:
                        nextController.dismiss(animated: true) {
                            controller.navigationController?.popViewController(animated: true)
                        }
                    }
                })
                .disposed(by: nextController.disposeBag)
        case .setComment(let text):
            newState.text = text
        case .save(let controller):
            newState.isSaving = true
            if imageSection.dataCount == 1 {
                commentAPIUseCase.postCommentAdd(popUpStoreId: self.popUpID, content: newState.text, commentType: "NORMAL", imageUrlList: [])
                    .subscribe {
                        controller.navigationController?.popViewController(animated: true) {
                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                ToastMaker.createToast(message: "코멘트 작성을 완료했어요")
                            }
                        }
                    }
                    .disposed(by: disposeBag)
            } else {
                let images = imageSection.inputDataList.compactMap { $0.image }.enumerated().map { $0 }
                let uuid = UUID().uuidString
                let pathList = images.map { "PopUpComment/\(popUpName)/\(uuid)/\($0.offset).jpg" }

                preSignedUseCase.tryUpload(presignedURLRequest: images.map {
                    return (
                        filePath: "PopUpComment/\(popUpName)/\(uuid)/\($0.offset).jpg",
                        image: $0.element
                    )
                })
                .subscribe(onSuccess: { [weak self] _ in
                    guard let self = self else { return }
                    self.commentAPIUseCase.postCommentAdd(popUpStoreId: self.popUpID, content: newState.text, commentType: "NORMAL", imageUrlList: pathList)
                        .subscribe(onDisposed: {
                            controller.navigationController?.popViewController(animated: true) {
                                DispatchQueue.main.asyncAfter(deadline: .now()) {
                                    ToastMaker.createToast(message: "코멘트 작성을 완료했어요")
                                }
                            }
                        })
                        .disposed(by: disposeBag)
                })
                .disposed(by: disposeBag)
            }

        }
        return newState
    }

    func getSection() -> [any Sectionable] {
        return [
            spacing25Section,
            photoTitleSection,
            spacing5Section,
            photoDescriptionSection,
            spacing16Section,
            imageSection,
            spacing32Section,
            commentTitleSection,
            spacing5Section,
            commentDescriptionSection,
            spacing16Section,
            commentSection,
            spacing32Section,
            spacing32Section
        ]
    }
}

// MARK: - PHPickerViewControllerDelegate
extension NormalCommentAddReactor: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        // 이미지가 로드된 순서를 보장하기 위해 선택한 이미지 개수만큼의 nil 배열을 생성
        var originImageList = [UIImage?](repeating: nil, count: results.count)
        let dispatchGroup = DispatchGroup() // 모든 이미지를 로드할 때까지 대기

        // results에서 이미지를 비동기적으로 로드
        for (index, result) in results.enumerated() {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                dispatchGroup.enter() // 이미지 로드가 시작될 때 그룹에 등록

                result.itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                    defer { dispatchGroup.leave() } // 이미지 로드가 끝날 때 그룹에서 제거

                    if let image = image as? UIImage {
                        originImageList[index] = image // 로드된 이미지를 해당 인덱스에 저장
                    } else {
                        Logger.log("Failed to load image", category: .error)
                    }
                }
            } else {
                Logger.log("ItemProvider Can Not Load Object", category: .error)
            }
        }

        // 모든 이미지가 로드된 후에 한 번에 choiceImageList 업데이트
        dispatchGroup.notify(queue: .main) {
            let filteredImages = originImageList.compactMap { $0 }
            self.action.onNext(.setImage(images: filteredImages))
        }
    }
}
