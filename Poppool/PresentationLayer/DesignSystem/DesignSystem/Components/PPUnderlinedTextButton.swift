import UIKit

import SnapKit

public final class PPUnderlinedTextButton: UIButton {

    private let textColor: UIColor = .g1000
    private let disabledTextColor: UIColor = .g300

    private let UnderlineView = UIView().then {
        $0.backgroundColor = .g1000
    }

    public init(
        fontStyle: PPFontStyle = .KOm16,
        text: String,
        disabledText: String = "",
    ) {
        super.init(frame: .zero)

        self.setText(to: text, with: fontStyle, color: textColor, for: .normal)
        self.setText(to: disabledText.isEmpty ? text : disabledText, with: fontStyle, color: disabledTextColor, for: .disabled)

        self.addViews()
        self.setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("\(#file), \(#function) Error")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        switch state {
        case .normal:
            UnderlineView.backgroundColor = textColor
        case .disabled:
            UnderlineView.backgroundColor = disabledTextColor
        default: break
        }
    }
}

extension PPUnderlinedTextButton {
    func addViews() {
        [UnderlineView].forEach {
            self.addSubview($0)
        }
    }

    func setupConstraints() {
        UnderlineView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
        }
    }
}
