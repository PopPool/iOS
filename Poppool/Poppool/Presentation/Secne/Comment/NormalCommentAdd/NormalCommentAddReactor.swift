//
//  NormalCommentAddReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/14/24.
//

import UIKit
import PhotosUI

import ReactorKit
import RxSwift
import RxCocoa

final class NormalCommentAddReactor: Reactor {
    
    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case photoAddButtonTapped(controller: BaseViewController)
        case setImage(images: [UIImage?])
        case imageDeleteButtonTapped(indexPath: IndexPath)
        case backButtonTapped(controller: BaseViewController)
        case inputComment(text: String?)
    }
    
    enum Mutation {
        case loadView
        case showImagePicker(controller: BaseViewController)
        case showCheckModal(controller: BaseViewController)
        case setComment(text: String?)
    }
    
    struct State {
        var sections: [any Sectionable] = []
        var text: String?
        var isReloadView: Bool = true
    }
    
    // MARK: - properties
    
    var initialState: State
    var disposeBag = DisposeBag()
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
    private let photoDescriptionSection = AddCommentDescriptionSection(inputDataList: [.init(description: "과 관련있는 사진을 업로드해보세요.")])
    private var imageSection = AddCommentImageSection(inputDataList: [.init(isFirstCell: true)])
    private let commentTitleSection = AddCommentTitleSection(inputDataList: [.init(title: "코멘트 작성")])
    private let commentDescriptionSection = AddCommentDescriptionSection(inputDataList: [.init(description: "방문했던 에 대한 감상평을 작성해주세요.")])
    private let commentSection = AddCommentSection(inputDataList: [.init()])
    private let spacing25Section = SpacingSection(inputDataList: [.init(spacing: 25)])
    private let spacing5Section = SpacingSection(inputDataList: [.init(spacing: 5)])
    private let spacing16Section = SpacingSection(inputDataList: [.init(spacing: 16)])
    private let spacing32Section = SpacingSection(inputDataList: [.init(spacing: 32)])
    // MARK: - init
    init() {
        self.initialState = State()
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
            return Observable.just(.setComment(text: text))
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
            commentSection
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
                        Logger.log(message: "Failed to load image", category: .error)
                    }
                }
            } else {
                Logger.log(message: "ItemProvider Can Not Load Object", category: .error)
            }
        }
        
        // 모든 이미지가 로드된 후에 한 번에 choiceImageList 업데이트
        dispatchGroup.notify(queue: .main) {
            let filteredImages = originImageList.compactMap { $0 }
            self.action.onNext(.setImage(images: filteredImages))
        }
    }
}
