import UIKit

import SnapKit

final class LoginView: UIView {
    // MARK: - Properties

    // MARK: - init
    init() {
        super.init(frame: .zero)

        self.addViews()
        self.setupConstraints()
        self.configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("\(#file), \(#function) Error")
    }
}

// MARK: - SetUp
private extension LoginView {
    func addViews() { }

    func setupConstraints() { }

    func configureUI() { }
}

