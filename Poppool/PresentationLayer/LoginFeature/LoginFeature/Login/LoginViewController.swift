import UIKit

import DesignSystem
import SnapKit
import RxCocoa
import RxSwift
import ReactorKit

final class LoginViewController: BaseViewController, View {

    typealias Reactor = LoginReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = LoginView()

    override func loadView() {
        self.view = mainView
    }
}

// MARK: - Life Cycle
extension LoginViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addViews()
        self.setupConstraints()
        self.configureUI()
    }
}

// MARK: - SetUp
private extension LoginViewController {
    func addViews() { }

    func setupConstraints() { }

    func configureUI() {
        mainView.backgroundColor = .black
    }
}

extension LoginViewController {
    func bind(reactor: Reactor) { }
}


