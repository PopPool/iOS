//
//  TermsDetailController.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/25/24.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift

final class TermsDetailController: BaseViewController {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private var mainView = TermsDetailView()
    
    init(title: String?, content: String?) {
        super.init()
        mainView.titleLabel.text = title
        mainView.contentTextView.text = content
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
