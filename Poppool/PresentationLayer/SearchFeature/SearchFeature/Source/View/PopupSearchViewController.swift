import UIKit

import DesignSystem

import ReactorKit
import RxSwift

public final class PopupSearchViewController: BaseViewController, View {

    public typealias Reactor = PopupSearchReactor

    // MARK: - Properties
    public var disposeBag = DisposeBag()

    private let searchBar = PPSearchBarView()
}

// MARK: - Life Cycle
extension PopupSearchViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.addViews()
        self.setupConstraints()
        self.configureUI()
    }
}

// MARK: - SetUp
private extension PopupSearchViewController {
    func addViews() {
        self.view.addSubview(searchBar)
    }

    func setupConstraints() {
        searchBar.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(16)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(12)
        }
    }

    func configureUI() { }
}

// MARK: - Bind
extension PopupSearchViewController {
    public func bind(reactor: Reactor) {
        searchBar.cancelButton.rx.tap
            .withUnretained(self)
            .subscribe { (owner, _) in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
}

extension PopupSearchViewController: UISearchBarDelegate { }
