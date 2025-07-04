import UIKit

import DesignSystem

import PanModal
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class WithdrawlCheckModalController: BaseViewController, View {

    typealias Reactor = WithdrawlCheckModalReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = WithdrawlCheckModalView()

    init(nickName: String?) {
        super.init()
        let title = "\(nickName ?? "")님, 팝풀 서비스를\n정말 탈퇴하시겠어요?"
        mainView.titleLabel.setLineHeightText(text: title, font: .korFont(style: .bold, size: 18), lineHeight: 1.312)
        mainView.titleLabel.numberOfLines = 2
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Life Cycle
extension WithdrawlCheckModalController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// MARK: - SetUp
private extension WithdrawlCheckModalController {
    func setUp() {
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods
extension WithdrawlCheckModalController {
    func bind(reactor: Reactor) {
        mainView.cancelButton.rx.tap
            .map { Reactor.Action.cancelButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.agreeButton.rx.tap
            .map { Reactor.Action.appleyButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

// MARK: - PanModalPresentable
extension WithdrawlCheckModalController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }

    var longFormHeight: PanModalHeight {
        return .contentHeight(370)
    }
    var shortFormHeight: PanModalHeight {
        return .contentHeight(370)
    }
    var showDragIndicator: Bool {
        return false
    }
    var cornerRadius: CGFloat {
        return 20
    }
}
