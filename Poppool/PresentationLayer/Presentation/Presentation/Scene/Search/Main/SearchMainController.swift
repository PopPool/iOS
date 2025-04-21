import UIKit

import DomainInterface
import Infrastructure

import Pageboy
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Tabman

final class SearchMainController: BaseTabmanController, View {

    typealias Reactor = SearchMainReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = SearchMainView()

    var beforeController: SearchController = {
        let controller = SearchController()
        controller.reactor = SearchReactor(
            userAPIUseCase: DIContainer.resolve(UserAPIUseCase.self),
            popUpAPIUseCase: DIContainer.resolve(PopUpAPIUseCase.self)
        )
        return controller
    }()

    var afterController: SearchResultController = {
        let controller = SearchResultController()
        controller.reactor = SearchResultReactor(
            userAPIUseCase: DIContainer.resolve(UserAPIUseCase.self),
            popUpAPIUseCase: DIContainer.resolve(PopUpAPIUseCase.self)
        )
        return controller
    }()

    lazy var controllers = [
        beforeController,
        afterController
    ]

    var isResponseTextField: Bool = false
}

// MARK: - Life Cycle
extension SearchMainController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isResponseTextField {
            mainView.searchTextField.becomeFirstResponder()
            isResponseTextField = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
}

// MARK: - SetUp
private extension SearchMainController {
    func setUp() {
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(56)
        }
        self.dataSource = self
        self.isScrollEnabled = false
    }
}

// MARK: - Methods
extension SearchMainController {
    func bind(reactor: Reactor) {
        beforeController.reactor?.state
            .withUnretained(self)
            .subscribe(onNext: { (owner, state) in
                owner.view.endEditing(true)
                if let text = state.searchKeyWord {
                    if let index = owner.currentIndex {
                        if index == 0 {
                            owner.scrollToPage(.at(index: 1), animated: false)
                            reactor.action.onNext(.returnSearchKeyWord(text: text))
                            owner.mainView.searchTextField.text = state.searchKeyWord
                        }
                    }
                }
            })
            .disposed(by: disposeBag)

//        mainView.searchTextField.rx.controlEvent(.editingDidEndOnExit)
//            .withUnretained(self)
//            .map { (owner, _) in
//                Reactor.Action.returnSearchKeyWord(text: owner.mainView.searchTextField.text )
//            }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)
//        
//        mainView.searchTextField.rx.controlEvent(.editingDidEndOnExit)
//            .withUnretained(self)
//            .subscribe(onNext: { (owner, _) in
//                if let text = owner.mainView.searchTextField.text {
//                    if !text.isEmpty {
//                        owner.scrollToPage(.at(index: 1), animated: false)
//                    }
//                }
//                owner.beforeController.reactor?.action.onNext(.returnSearchKeyword(text: owner.mainView.searchTextField.text))
//            })
//            .disposed(by: disposeBag)
        mainView.searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .withLatestFrom(mainView.searchTextField.rx.text.orEmpty)
            .withUnretained(self)
            .subscribe(onNext: { (owner, query) in
                owner.view.endEditing(true)
                // 텍스트가 비어있지 않으면 페이지 전환
                if !query.isEmpty {
                    owner.scrollToPage(.at(index: 1), animated: false)
                }
                owner.reactor?.action.onNext(.returnSearchKeyWord(text: query))
                owner.beforeController.reactor?.action.onNext(.returnSearchKeyword(text: query))
            })
            .disposed(by: disposeBag)

        mainView.searchTextField.rx.text
            .withUnretained(self)
            .subscribe(onNext: { (owner, text) in
                if let text = text {
                    owner.mainView.clearButton.isHidden = text.isEmpty
                } else {
                    owner.mainView.clearButton.isHidden = true
                }
            })
            .disposed(by: disposeBag)

        mainView.cancelButton.rx.tap
            .withUnretained(self)
            .map { (owner, _) in
                owner.view.endEditing(true)
                if owner.currentIndex == 1 {
                    owner.mainView.searchTextField.text = nil
                    owner.beforeController.reactor?.action.onNext(.resetSearchKeyWord)
                    owner.scrollToPage(.at(index: 0), animated: false)
                } else {
                    owner.navigationController?.popViewController(animated: true)
                }
                return Reactor.Action.returnSearchKeyWord(text: nil)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.clearButton.rx.tap
            .withUnretained(self)
            .subscribe { (owner, _) in
                owner.mainView.searchTextField.text = nil
                owner.mainView.clearButton.isHidden = true
            }
            .disposed(by: disposeBag)

        reactor.state
            .withUnretained(self)
            .subscribe { (owner, state) in
                if let text = state.searchKeyword {
                    owner.afterController.reactor?.action.onNext(.returnSearch(text: text))
                }
            }
            .disposed(by: disposeBag)
    }
}

extension SearchMainController: PageboyViewControllerDataSource, TMBarDataSource {
    func barItem(for bar: any Tabman.TMBar, at index: Int) -> any Tabman.TMBarItemable {
        return TMBarItem(title: "")
    }

    func numberOfViewControllers(in pageboyViewController: Pageboy.PageboyViewController) -> Int {
        return controllers.count
    }

    func viewController(
        for pageboyViewController: Pageboy.PageboyViewController,
        at index: Pageboy.PageboyViewController.PageIndex
    ) -> UIViewController? {
        return controllers[index]
    }

    func defaultPage(
        for pageboyViewController: Pageboy.PageboyViewController
    ) -> Pageboy.PageboyViewController.Page? {
        if let currentIndex = currentIndex { return .at(index: currentIndex) }
        return .at(index: 0)
    }
}
