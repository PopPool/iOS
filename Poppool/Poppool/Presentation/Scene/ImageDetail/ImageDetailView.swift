//
//  ImageDetailView.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/25/24.
//

import UIKit

import SnapKit

final class ImageDetailView: UIView {
    
    // MARK: - Components
    let imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .pb60
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    // MARK: - init
    init() {
        super.init(frame: .zero)
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SetUp
private extension ImageDetailView {
    
    func setUpConstraints() {
        self.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
