//
//  ProfileEditController.swift
//  Poppool
//
//  Created by SeoJunYoung on 1/4/25.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift
import ReactorKit

final class ProfileEditController: BaseViewController, View {
    
    typealias Reactor = ProfileEditReactor
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private var mainView = ProfileEditView()
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
        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
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
        
        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                if state.isLoadView {
                    guard let originProfileData = state.originProfileData else { return }
                    owner.mainView.profileImageView.setPPImage(path: originProfileData.profileImageUrl)
                    owner.mainView.nickNameTextField.text = originProfileData.nickname
                    owner.mainView.introTextView.text = originProfileData.intro
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
                }
            }
            .disposed(by: disposeBag)
    }
}
