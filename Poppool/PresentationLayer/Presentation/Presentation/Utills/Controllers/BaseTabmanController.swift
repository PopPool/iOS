import UIKit

import Infrastructure

import Pageboy
import Tabman

class BaseTabmanController: TabmanViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
        Logger.log(
            "\(self) init",
            category: .info,
            fileName: #file,
            line: #line
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.isHidden = true
    }

    deinit {
        Logger.log(
            "\(self) deinit",
            category: .info,
            fileName: #file,
            line: #line
        )
    }
}
