import UIKit

import DesignSystem

import SnapKit

final class SearchSortedView: UIView {

    // MARK: - Components
    private let titleLabel: PPLabel = {
        return PPLabel(style: .bold, fontSize: 18, text: "노출 순서를 선택해주세요")
    }()

    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_xmark"), for: .normal)
        return button
    }()

    private let filterTitleLabel: PPLabel = {
        return PPLabel(style: .regular, fontSize: 13, text: "노출 조건")
    }()

    let filterSegmentControl: PPSegmentedControl = {
        return PPSegmentedControl(type: .base, segments: ["오픈", "종료"], selectedSegmentIndex: 0)
    }()

    private let sortedTitleLabel: PPLabel = {
        return PPLabel(style: .regular, fontSize: 13, text: "팝업순서")
    }()

    let sortedSegmentControl: PPSegmentedControl = {
        return PPSegmentedControl(type: .base, segments: ["신규순", "인기순"], selectedSegmentIndex: 0)
    }()

    let saveButton: PPButton = {
        return PPButton(style: .primary, text: "저장", disabledText: "저장")
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
private extension SearchSortedView {

    func setUpConstraints() {
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(32)
        }

        self.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(titleLabel)
        }

        self.addSubview(filterTitleLabel)
        filterTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(36)
            make.leading.equalToSuperview().inset(20)
        }

        self.addSubview(filterSegmentControl)
        filterSegmentControl.snp.makeConstraints { make in
            make.top.equalTo(filterTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        self.addSubview(sortedTitleLabel)
        sortedTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(filterSegmentControl.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(20)
        }

        self.addSubview(sortedSegmentControl)
        sortedSegmentControl.snp.makeConstraints { make in
            make.top.equalTo(sortedTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        self.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(sortedSegmentControl.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
}
