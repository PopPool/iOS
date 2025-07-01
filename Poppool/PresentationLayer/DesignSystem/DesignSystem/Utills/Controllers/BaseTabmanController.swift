import UIKit

import Infrastructure

import Pageboy
import Tabman

open class BaseTabmanController: TabmanViewController {
    public init() {
        super.init(nibName: nil, bundle: nil)
        Logger.log(
            "\(self) init",
            category: .info
        )
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.isHidden = true
    }

    deinit {
        Logger.log(
            "\(self) deinit",
            category: .info
        )
    }
}
