import UIKit

import DesignSystem

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class WithdrawlCompleteController: BaseViewController {

    // MARK: - Properties
    var disposeBag = DisposeBag()

    var mainView = WithdrawlCompleteView()
}

// MARK: - Life Cycle
extension WithdrawlCompleteController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// MARK: - SetUp
private extension WithdrawlCompleteController {
    func setUp() {
        view.backgroundColor = .g50
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
