//
//  informBottomSheet.swift
//  PopPool
//
//  Created by Porori on 7/1/24.
//

import Foundation
import UIKit

class informBottomSheet: ModalViewController {
    private let headerView = HeaderViewCPNT(title: "[필수] 이용약관", style: .icon(UIImage(named: "line")))
    private let contentLabel: UILabel = {
        let label = UILabel()
        let text = """
        하위의 텍스트는 모두 로렘 입숨입니다.
        
        모든 국민은 학문과 예술의 자유를 가진다. 모든 국민은 언론·출판의 자유와 집회·결사의 자유를 가진다. 헌법재판소는 법률에 저촉되지 아니하는 범위안에서 심판에 관한 절차, 내부규율과 사무처리에 관한 규칙을 제정할 수 있다. 국가는 농지에 관하여 경자유전의 원칙이 달성될 수 있도록 노력하여야 하며, 농지의 소작제도는 금지된다.
        
        국교는 인정되지 아니하며, 종교와 정치는 분리된다. 훈장등의 영전은 이를 받은 자에게만 효력이 있고, 어떠한 특권도 이에 따르지 아니한다. 모든 국민은 보건에 관하여 국가의 보호를 받는다. 모든 국민은 주거의 자유를 침해받지 아니한다. 주거에 대한 압수나 수색을 할 때에는 검사의 신청에 의하여 법관이 발부한 영장을 제시하여야 한다.
        
        국회의 정기회는 법률이 정하는 바에 의하여 매년 1회 집회되며, 국회의 임시회는 대통령 또는 국회재적의원 4분의 1 이상의 요구에 의하여 집회된다. 근로조건의 기준은 인간의 존엄성을 보장하도록 법률로 정한다. 국회의원의 선거구와 비례대표제 기타 선거에 관한 사항은 법률로 정한다. 대통령은 국민의 보통·평등·직접·비밀선거에 의하여 선출한다.
        
        제1항의 지시를 받은 당해 행정기관은 이에 응하여야 한다. 국무총리 또는 행정각부의 장은 소관사무에 관하여 법률이나 대통령령의 위임 또는 직권으로 총리령 또는 부령을 발할 수 있다. 제2항의 재판관중 3인은 국회에서 선출하는 자를, 3인은 대법원장이 지명하는 자를 임명한다. 국민경제의 발전을 위한 중요정책의 수립에 관하여 대통령의 자문에 응하기 위하여 국민경제자문회의를 둘 수 있다.
        """
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        let attributedStr = NSMutableAttributedString(string: text)
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.5
        label.attributedText = attributedStr
        
        label.attributedText = NSMutableAttributedString(
            string: text,
            attributes: [.paragraphStyle: style]
        )
        
        label.font = .KorFont(style: .regular, size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(headerView)
        stack.addArrangedSubview(contentLabel)
        stack.axis = .vertical
        stack.spacing = 32
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpConstraint()
    }
    
    private func setUpConstraint() {
        view.backgroundColor = .clear
        headerView.leftBarButton.isHidden = true
        headerView.titleLabel.font = .KorFont(style: .bold, size: 15)
        
        setContent(content: contentStack)
    }
    
    func updateText(text: String) {
//        let attributedStr = NSMutableAttributedString(string: text)
//        let style = NSMutableParagraphStyle()
//        style.lineHeightMultiple = 1.5
//        contentLabel.attributedText = attributedStr
//        
//        contentLabel.attributedText = NSMutableAttributedString(
//            string: text,
//            attributes: [.paragraphStyle: style]
//        )
        
        self.setContent(content: contentStack)
    }
}
