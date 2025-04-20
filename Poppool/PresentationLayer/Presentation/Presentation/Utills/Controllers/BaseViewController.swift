import UIKit

import Infrastructure

import RxCocoa
import RxSwift

public class BaseViewController: UIViewController {

    var systemStatusBarIsDark: BehaviorRelay<Bool> = .init(value: true)
    var systemStatusBarDisposeBag = DisposeBag()

    init() {
        super.init(nibName: nil, bundle: nil)
        Logger.log(
            message: "\(self) init",
            category: .info,
            fileName: #file,
            line: #line
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = true
        systemStatusBarIsDarkBind()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        systemStatusBarIsDark.accept(systemStatusBarIsDark.value)
    }

    deinit {
        Logger.log(
            message: "\(self) deinit",
            category: .info,
            fileName: #file,
            line: #line
        )
    }

    func systemStatusBarIsDarkBind() {
        systemStatusBarIsDark
            .withUnretained(self)
            .subscribe { (owner, isDark) in
                if isDark {
                    owner.navigationController?.navigationBar.barStyle = .default
                } else {
                    owner.navigationController?.navigationBar.barStyle = .black
                }
            }
            .disposed(by: systemStatusBarDisposeBag)
    }
}
