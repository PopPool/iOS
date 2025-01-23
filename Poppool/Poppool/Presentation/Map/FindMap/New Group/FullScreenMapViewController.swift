//
//  FullScreenMapViewController.swift
//  Poppool
//
//  Created by 김기현 on 1/24/25.
//

import Foundation
import UIKit
import RxSwift
import ReactorKit

final class FullScreenMapViewController: MapViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = false
        setupNavigation()

        mainView.searchFilterContainer.isHidden = true
        mainView.filterChips.isHidden = true
        mainView.listButton.isHidden = true
        carouselView.isHidden = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    private func setupNavigation() {
        navigationItem.title = "찾아가는 길"

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 15, weight: .regular)
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "bakcbutton")?.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    }
    

    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
}
