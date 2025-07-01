import UIKit

import DesignSystem

import RxCocoa
import RxSwift
import SnapKit

final class TermsDetailController: BaseViewController {

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = TermsDetailView()

    init(title: String?, content: String?) {
        super.init()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.korFont(style: .regular, size: 14),
            .paragraphStyle: paragraphStyle
        ]

        mainView.contentTextView.attributedText = NSAttributedString(string: content ?? "", attributes: attributes)
        mainView.titleLabel.text = title

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Life Cycle
extension TermsDetailController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        bind()
    }
}

// MARK: - SetUp
private extension TermsDetailController {
    func setUp() {
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    func bind() {
        mainView.xmarkButton.rx.tap
            .withUnretained(self)
            .subscribe { (owner, _) in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
}
