//
//  ageSelectionBottomSheet.swift
//  PopPool
//
//  Created by Porori on 7/1/24.
//

import Foundation
import UIKit
import RxSwift

class AgeSelectionBottomSheetVC: ModalViewController {
    let titleLabel: UILabel = {
        let label = UILabel()
        var text = "나이를 선택해주세요"
        let attributedStr = NSMutableAttributedString(string: text)
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.4
        label.attributedText = NSMutableAttributedString(
            string: text,
            attributes: [.paragraphStyle: style]
        )
        label.numberOfLines = 1
        label.font = .KorFont(style: .bold, size: 18)
        return label
    }()
    
    private lazy var titleStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.addArrangedSubview(spacer24)
        stack.addArrangedSubview(titleLabel)
        return stack
    }()
    
    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.addArrangedSubview(cancelButton)
        stack.addArrangedSubview(confirmButton)
        return stack
    }()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.addArrangedSubview(titleStack)
        stack.addArrangedSubview(pickerView)
        stack.addArrangedSubview(buttonStack)
        return stack
    }()
    
    private let pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        return pickerView
    }()
    
    private lazy var spacer24 = SpacingFactory.shared.createSpace(size: 24)
    private lazy var confirmButton = ButtonCPNT(type: .primary, title: "확인")
    private lazy var cancelButton = ButtonCPNT(type: .secondary, title: "취소")
    let ageList = (1...100).map { "\($0) 세" }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpConstraint()
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    private func setUpConstraint() {
        buttonStack.snp.makeConstraints { make in
            make.height.equalTo(52)
        }
        
        // 스택 적용
        self.setContent(content: contentStack)
    }
}
