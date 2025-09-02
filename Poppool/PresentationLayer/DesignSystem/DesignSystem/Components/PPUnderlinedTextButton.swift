import UIKit

import SnapKit

public final class PPUnderlinedTextButton: UIButton {

    public init(
        text: String = " ",
        font: PPFontStyle = .KOr16,
        color: UIColor = .g1000,
        for controlState: UIControl.State = .normal
    ) {
        super.init(frame: .zero)

        self.setText(to: text, with: font, color: color, for: controlState)

        self.addViews()
        self.setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("\(#file), \(#function) Error")
    }

    private let UnderlineView = UIView().then {
        $0.backgroundColor = .g1000
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
