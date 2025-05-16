import UIKit

import DesignSystem

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class MyPageNoticeDetailController: BaseViewController, View {

    typealias Reactor = MyPageNoticeDetailReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = MyPageNoticeDetailView()
}

// MARK: - Life Cycle
extension MyPageNoticeDetailController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// MARK: - SetUp
private extension MyPageNoticeDetailController {
    func setUp() {
        view.backgroundColor = .g50
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension MyPageNoticeDetailController {
    func bind(reactor: Reactor) {
        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
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
                owner.mainView.titleLabel.setLineHeightText(text: state.title, font: .korFont(style: .bold, size: 18))
                owner.mainView.dateLabel.setLineHeightText(text: state.date, font: .engFont(style: .regular, size: 14))
                owner.mainView.contentLabel.setLineHeightText(text: state.content, font: .korFont(style: .regular, size: 14))
            }
            .disposed(by: disposeBag)
    }
}
