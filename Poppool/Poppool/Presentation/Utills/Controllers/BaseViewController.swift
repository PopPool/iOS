//
//  BaseViewController.swift
//  MomsVillage
//
//  Created by SeoJunYoung on 8/9/24.
//

import UIKit

class BaseViewController: UIViewController {
    
    var statusBarIsDarkMode: Bool {
        didSet {
            if oldValue != statusBarIsDarkMode {
                setStatusBarColor()
            }
        }
    }
    
    init() {
        statusBarIsDarkMode = true
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarColor()
    }
    
    deinit {
        Logger.log(
            message: "\(self) deinit",
            category: .info,
            fileName: #file,
            line: #line
        )
    }
    
    func setStatusBarColor() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            if statusBarIsDarkMode {
                navigationController?.navigationBar.barStyle = .default
            } else {
                navigationController?.navigationBar.barStyle = .black
            }
        }
    }
}
