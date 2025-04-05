//
//  InstaCommentAddReactor.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/15/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class InstaCommentAddReactor: Reactor {

    // MARK: - Reactor
    enum Action {
        case viewWillAppear
        case instaButtonTapped
    }

    enum Mutation {
        case loadView
        case moveToInsta
    }

    struct State {
        var sections: [any Sectionable] = []
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

    private let guideSection = InstaGuideSection(inputDataList: [
        .init(
            imageList: [
                UIImage(named: "icon_instaGuide_0"),
                UIImage(named: "icon_instaGuide_1"),
                UIImage(named: "icon_instaGuide_2"),
                UIImage(named: "icon_instaGuide_3")
            ],
            title: [
                {
                    let title = "아래 인스타그램 열기\n버튼을 터치해 앱 열기"
                    let attributedTitle = NSMutableAttributedString(string: title)
                    let koreanFont = UIFont.korFont(style: .bold, size: 20)!
                    attributedTitle.addAttribute(.font, value: koreanFont, range: NSRange(location: 0, length: title.count))
                    attributedTitle.addAttribute(.foregroundColor, value: UIColor.blu500.cgColor, range: (title as NSString).range(of: "인스타그램 열기"))
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineHeightMultiple = 1.2
                    attributedTitle.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: title.count))
                    return attributedTitle
                }(),
                {
                    let title = "원하는 피드의 이미지로 이동 후\n공유하기 > 링크복사 터치하기"
                    let attributedTitle = NSMutableAttributedString(string: title)
                    let koreanFont = UIFont.korFont(style: .bold, size: 20)!
                    attributedTitle.addAttribute(.font, value: koreanFont, range: NSRange(location: 0, length: title.count))
                    attributedTitle.addAttribute(.foregroundColor, value: UIColor.blu500.cgColor, range: (title as NSString).range(of: "공유하기 > 링크복사"))
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineHeightMultiple = 1.2
                    attributedTitle.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: title.count))
                    return attributedTitle
                }(),
                {
                    let title = "아래 이미지 영역을 터치해\n팝풀 앱으로 돌아오기"
                    let attributedTitle = NSMutableAttributedString(string: title)
                    let koreanFont = UIFont.korFont(style: .bold, size: 20)!
                    attributedTitle.addAttribute(.font, value: koreanFont, range: NSRange(location: 0, length: title.count))
                    attributedTitle.addAttribute(.foregroundColor, value: UIColor.blu500.cgColor, range: (title as NSString).range(of: "팝풀 앱"))
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineHeightMultiple = 1.2
                    attributedTitle.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: title.count))
                    return attributedTitle
                }(),
                {
                    let title = "복사된 인스타 피드 이미지와\n함께할 글을 입력 후 등록하기"
                    let attributedTitle = NSMutableAttributedString(string: title)
                    let koreanFont = UIFont.korFont(style: .bold, size: 20)!
                    attributedTitle.addAttribute(.font, value: koreanFont, range: NSRange(location: 0, length: title.count))
                    attributedTitle.addAttribute(.foregroundColor, value: UIColor.blu500.cgColor, range: (title as NSString).range(of: "글을 입력 후 등록"))
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineHeightMultiple = 1.2
                    attributedTitle.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: title.count))
                    return attributedTitle
                }()
            ]
        )
    ])

    // MARK: - init
    init() {
        self.initialState = State()
    }

    // MARK: - Reactor Methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return Observable.just(.loadView)
        case .instaButtonTapped:
            return Observable.just(.moveToInsta)
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .loadView:
            newState.sections = getSection()
        case .moveToInsta:
            openInstagram()

        }
        return newState
    }

    func getSection() -> [any Sectionable] {
        return [
            guideSection
        ]
    }

    func openInstagram() {
        // Instagram 앱의 URL Scheme
        let instagramURL = URL(string: "instagram://app")!

        if UIApplication.shared.canOpenURL(instagramURL) {
            // Instagram 앱 열기
            UIApplication.shared.open(instagramURL, options: [:], completionHandler: nil)
        } else {
            // Instagram 앱이 설치되지 않은 경우
            let appStoreURL = URL(string: "https://apps.apple.com/app/instagram/id389801252")!
            UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
        }
    }
}
