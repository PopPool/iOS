//
//  InquiryTableViewCell.swift
//  PopPool
//
//  Created by Porori on 8/5/24.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay

class InquiryTableViewCell: UITableViewCell {
    
    static let reuseIdentifier: String = "InquiryTableViewCell"
    
    let dropDownList = ListDropDownCPNT()
    private var indexPath: IndexPath?
    let disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpConstraint()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func addSubview(_ view: UIView) {
        super.addSubview(view)
        sendSubviewToBack(contentView)
    }
    
    private func bind() {
        dropDownList.actionButton.rx.tap
            .subscribe(onNext: {
                print("did press within cell")
            })
            .disposed(by: disposeBag)
    }
    
    private func setUpConstraint() {
        addSubview(dropDownList)
        dropDownList.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
