//
//  SpacingSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/30/24.
//

import UIKit

import SnapKit
import RxSwift

final class SpacingSectionCell: UICollectionViewCell {
    
    // MARK: - Components

    let disposeBag = DisposeBag()
    
    private let spaceView: UIView = UIView()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

// MARK: - SetUp
private extension SpacingSectionCell {
    func setUpConstraints() {
        contentView.addSubview(spaceView)
    }
}

extension SpacingSectionCell: Inputable {
    struct Input {
        var spacing: Float
        var backgroundColor: UIColor? = .clear
    }
    
    func injection(with input: Input) {
        spaceView.snp.removeConstraints()
        spaceView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(input.spacing).priority(.high)
        }
        spaceView.backgroundColor = input.backgroundColor
    }
}
