//
//  AgeSelectionBottomSheetVC+.swift
//  PopPool
//
//  Created by Porori on 7/1/24.
//

import Foundation
import UIKit

extension AgeSelectionBottomSheetVC: UIPickerViewDataSource, UIPickerViewDelegate {
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
