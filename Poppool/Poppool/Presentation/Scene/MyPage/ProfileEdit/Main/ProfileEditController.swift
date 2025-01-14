//
//  ProfileEditController.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/4/25.
//

import UIKit
import PhotosUI

import SnapKit
import RxCocoa
import RxSwift
import ReactorKit
import RxGesture

final class ProfileEditController: BaseViewController, View {
    
    typealias Reactor = ProfileEditReactor
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private var mainView = ProfileEditView()
    
    var isFirstResponse: Bool = true
}

// MARK: - Life Cycle
extension ProfileEditController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
}

// MARK: - SetUp
private extension ProfileEditController {
    func setUp() {
        view.backgroundColor = .g50
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension ProfileEditController {
    func bind(reactor: Reactor) {
        
        mainView.rx.tapGesture()
            .withUnretained(self)
            .subscribe { (owner, _) in
                owner.mainView.endEditing(true)
            }
            .disposed(by: disposeBag)
        
        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.nickNameTextField.rx.text
            .skip(1)
            .debounce(.milliseconds(300), scheduler: MainScheduler.asyncInstance)
            .map { Reactor.Action.changeNickName(nickName: $0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.nickNameTextField.rx.controlEvent(.editingDidBegin)
            .map { Reactor.Action.beginNickName }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.nickNameTextField.rx.controlEvent(.editingDidEnd)
            .map { Reactor.Action.endNickName }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.introTextView.rx.text
            .distinctUntilChanged()
            .skip(1)
            .debounce(.milliseconds(100), scheduler: MainScheduler.asyncInstance)
            .map { Reactor.Action.changeIntro(intro: $0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.introTextView.rx.didBeginEditing
            .map { Reactor.Action.beginIntro }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.introTextView.rx.didEndEditing
            .map { Reactor.Action.endIntro }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.profileImageButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (owner, _) in
                owner.showActionSheet()
            })
            .disposed(by: disposeBag)
        
        mainView.categoryButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.categoryButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.infoButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.infoButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.saveButton.rx.tap
            .map { Reactor.Action.saveButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        mainView.nickNameDuplicatedCheckButton.rx.tap
            .map { Reactor.Action.nickNameCheckButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.headerView.backButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                Reactor.Action.backButtonTapped(controller: owner)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                guard let originProfileData = state.originProfileData else { return }
                
                if owner.isFirstResponse {
                    owner.mainView.profileImageView.setPPImage(path: originProfileData.profileImageUrl)
                    owner.mainView.nickNameTextField.text = originProfileData.nickname
                    owner.mainView.introTextView.text = originProfileData.intro
                }
                
                let categoryTitleList = originProfileData.interestCategoryList.map { $0.category }
                let categoryTitle: String
                if let firstTitle = categoryTitleList.first {
                    categoryTitle = categoryTitleList.count == 1
                        ? firstTitle
                        : "\(firstTitle) 외 \(categoryTitleList.count - 1)개"
                } else {
                    categoryTitle = ""
                }
                owner.mainView.categoryButton.subTitleLabel
                    .setLineHeightText(text: categoryTitle, font: .KorFont(style: .regular, size: 13), lineHeight: 1)
                let userInfoTitle = "\(originProfileData.gender ?? "")・\(originProfileData.age)세"
                owner.mainView.infoButton.subTitleLabel
                    .setLineHeightText(text: userInfoTitle, font: .KorFont(style: .regular, size: 13) ,lineHeight: 1)
                
                
                // NickName TextField 설정
                owner.mainView.nickNameTextFieldTrailingView.layer.borderColor = state.nickNameState.borderColor?.cgColor
                owner.mainView.nickNameClearButton.isHidden = state.nickNameState.isHiddenClearButton
                owner.mainView.nickNameDuplicatedCheckButton.isHidden = state.nickNameState.isHiddenCheckButton
                owner.mainView.nickNameTextDescriptionLabel.text = state.nickNameState.description
                owner.mainView.nickNameTextDescriptionLabel.textColor = state.nickNameState.textColor
                owner.mainView.nickNameTextField.textColor = state.nickNameState.textFieldTextColor
                owner.mainView.nickNameTextCountLabel.text = "\(owner.mainView.nickNameTextField.text?.count ?? 0) / 10자"
                owner.mainView.nickNameDuplicatedCheckButton.isEnabled = state.nickNameState.duplicatedCheckButtonIsEnabled
                
                // Intro TextView 설정
                owner.mainView.introTextCountLabel.text = "\(owner.mainView.introTextView.text?.count ?? 0) / 30자"
                owner.mainView.introTextTrailingView.layer.borderColor = state.introState.borderColor?.cgColor
                owner.mainView.introDescriptionLabel.text = state.introState.description
                owner.mainView.introDescriptionLabel.textColor = state.introState.textColor
                owner.mainView.introTextCountLabel.textColor = state.introState.textColor
                owner.mainView.introTextView.textColor = state.introState.textFieldTextColor
                owner.mainView.introPlaceHolderLabel.isHidden = state.introState.placeHolderIsHidden
                
                owner.mainView.saveButton.isEnabled = state.saveButtonIsEnable
                owner.isFirstResponse = false
            }
            .disposed(by: disposeBag)
    }
}

extension ProfileEditController: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showActionSheet() {
        // ActionSheet 생성
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // 버튼 추가
        let takePhotoAction = UIAlertAction(title: "촬영하기", style: .default) { [weak self] _ in
            self?.showCamera()
        }
        let selectFromAlbumAction = UIAlertAction(title: "앨범에서 선택하기", style: .default) { [weak self] _ in
            self?.showPHPicker()
        }
        let changeToDefaultImageAction = UIAlertAction(title: "기본 이미지로 바꾸기", style: .default) { [weak self] _ in
            self?.mainView.profileImageView.setPPImage(path: nil)
            self?.reactor?.action.onNext(.changeDefaultImage)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        // 버튼 스타일 변경 (기본 이미지는 빨간색으로 표시)
        changeToDefaultImageAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        // 버튼 추가
        actionSheet.addAction(takePhotoAction)
        actionSheet.addAction(selectFromAlbumAction)
        actionSheet.addAction(changeToDefaultImageAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true)
    }
    
    func showCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            Logger.log(message: "카메라를 사용할 수 없습니다.", category: .error)
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    // MARK: - PHPicker 실행
    func showPHPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1 // 0으로 설정하면 여러 장 선택 가능
        configuration.filter = .images // 이미지만
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            handleSelectedImage(selectedImage)
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    // MARK: - PHPickerViewControllerDelegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                    if let selectedImage = image as? UIImage {
                        DispatchQueue.main.async {
                            self?.handleSelectedImage(selectedImage)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 이미지 처리
    func handleSelectedImage(_ image: UIImage) {
        // 선택한 이미지 처리
        mainView.profileImageView.image = image
        reactor?.action.onNext(.changeImage(image: image))
    }
}
