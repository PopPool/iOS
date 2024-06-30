//
//  ageSelectionBottomSheet.swift
//  PopPool
//
//  Created by Porori on 7/1/24.
//

import Foundation
import UIKit

class AgeSelectionBottomSheet: ModalViewController {
    let titleLabel: UILabel = {
        let label = UILabel()
        var text = "나이를 선택해주세요"
        label.numberOfLines = 1
        label.font = .KorFont(style: .bold, size: 18)
        let attributedStr = NSMutableAttributedString(string: text)
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.4
        label.attributedText = NSMutableAttributedString(
            string: text,
            attributes: [.paragraphStyle: style]
        )
        return label
    }()
    
    private lazy var titleStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.addArrangedSubview(spacer24)
        stack.addArrangedSubview(titleLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
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
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        return pickerView
    }()
    
    private lazy var spacer24 = SpacingFactory.shared.createSpace(on: self.view, size: 24)
    private lazy var confirmButton = ButtonCPNT(type: .primary, title: "확인")
    private lazy var cancelButton = ButtonCPNT(type: .secondary, title: "취소")
    private var ageList = (1...100).map { "\($0) 세" }
    
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
    
    private func bind() {
        
    }
}

extension AgeSelectionBottomSheet: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ageList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ageList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 150))
        let pickerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 150))
        
        let attributedStr = NSMutableAttributedString(string: ageList[row])
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.5
        pickerLabel.attributedText = NSMutableAttributedString(
            string: ageList[row],
            attributes: [.paragraphStyle: style]
        )
        
        pickerLabel.textAlignment = .center
        pickerLabel.font = .KorFont(style: .bold, size: 18)
        view.addSubview(pickerLabel)
        return view
    }
}
