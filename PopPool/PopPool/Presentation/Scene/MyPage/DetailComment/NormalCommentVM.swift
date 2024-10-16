//
//  NormalCommentVM.swift
//  PopPool
//
//  Created by Porori on 9/9/24.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay
import PhotosUI

class NormalCommentVM: ViewModelable {
    
    struct Input {
        var isTextViewFilled: ControlProperty<String?>
        var returnButtonTapped: ControlEvent<Void>
        var saveButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        var returnToHome: Observable<Void>
        var notifySave: Observable<Void>
        var currentImageCount: Observable<Int>
        var hasText: Observable<Bool>
    }
    
    var popUpStoreName: BehaviorRelay<String>
    var popUpStoreId: Int64
    var commentRequest: BehaviorRelay<CreateCommentRequestDTO> = .init(value: CreateCommentRequestDTO(
        userId: Constants.userId,
        popUpStoreId: 0,
        content: "",
        commentType: .normal,
        imageUrlList: []))
    
    var selectedImageCount: Observable<Int> {
        return selectedImageRelay.map { $0.count }
    }
    
    var selectedImages: Observable<[Data]> {
        return selectedImageRelay.compactMap { $0 }
    }
    
    var disposeBag = DisposeBag()
    private let maxImageCount = 5
    private var selectedImageRelay = BehaviorRelay<[Data]>(value: [])
    
    init(popUpName: String, popUpStoreId: Int64) {
        self.popUpStoreName = BehaviorRelay(value: popUpName)
        self.popUpStoreId = popUpStoreId
    }
    
    func addImage(_ imageData: Data) {
        var currentImages = selectedImageRelay.value
        if currentImages.count < maxImageCount {
            currentImages.append(imageData)
            selectedImageRelay.accept(currentImages)
        }
    }
    
    func removeImage(at index: Int) {
        var currentImages = selectedImageRelay.value
        if index < currentImages.count {
            currentImages.remove(at: index)
            selectedImageRelay.accept(currentImages)
        }
    }
    
    func getImage(at index: Int) -> Data? {
        let images = selectedImageRelay.value
        return index < images.count ? images[index] : nil
    }
    
    func transform(input: Input) -> Output {
        
        let isTextViewFilled = input.isTextViewFilled.map { $0?.isEmpty == false }
        
        return Output(
            returnToHome: input.returnButtonTapped.asObservable(),
            notifySave: input.saveButtonTapped.asObservable(),
            currentImageCount: selectedImageCount,
            hasText: isTextViewFilled
        )
    }
}
