import UIKit

import DesignSystem

import SnapKit

final class FilterSelectView: UIView {

    // MARK: - Components
    private let titleLabel = PPLabel(style: .bold, fontSize: 18, text: "노출 순서를 선택해주세요")

    let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "icon_xmark"), for: .normal)
    }

    private let statusLabel = PPLabel(style: .regular, fontSize: 13, text: "노출 조건")

    let statusSegmentControl = PPSegmentedControl(type: .base, segments: ["오픈", "종료"], selectedSegmentIndex: 0)

    private let sortLabel = PPLabel(style: .regular, fontSize: 13, text: "팝업순서")

    let sortSegmentControl = PPSegmentedControl(type: .base, segments: ["신규순", "인기순"], selectedSegmentIndex: 0)

    let saveButton = PPButton(style: .primary, text: "저장", disabledText: "저장")

    // MARK: - init
    init() {
        super.init(frame: .zero)

        self.addViews()
        self.setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#file), \(#function) Error")
    }
}

// MARK: - SetUp
private extension FilterSelectView {
    func addViews() {
        [titleLabel, closeButton, statusLabel, statusSegmentControl,
         sortLabel, sortSegmentControl, saveButton].forEach {
            self.addSubview($0)
        }
    }

    // FIXME: 레이아웃 에러로 인한 Modal이 살짝 내려가지는 문제 발생중
    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(32)
        }

        closeButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(titleLabel)
        }

        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(36)
            make.leading.equalToSuperview().inset(20)
        }

        statusSegmentControl.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        sortLabel.snp.makeConstraints { make in
            make.top.equalTo(statusSegmentControl.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(20)
        }

        sortSegmentControl.snp.makeConstraints { make in
            make.top.equalTo(sortLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(20)
        }

        saveButton.snp.makeConstraints { make in
            make.top.equalTo(sortSegmentControl.snp.bottom).offset(32)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalTo(self.safeAreaLayoutGuide)
        }
    }
}
