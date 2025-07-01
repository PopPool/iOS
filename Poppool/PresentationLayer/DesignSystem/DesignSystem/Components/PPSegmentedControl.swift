import UIKit

import SnapKit

public final class PPSegmentedControl: UISegmentedControl {

    /// 세그먼트 컨트롤 타입
    public enum SegmentedControlType {
        case radio
        case base
        case tab
    }
    // MARK: - Components
    private lazy var bottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .g200
        view.isHidden = true
        self.addSubview(view)
        return view
    }()
    private lazy var underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .blu500
        view.isHidden = true
        bottomLineView.addSubview(view)
        return view
    }()

    public init(type: SegmentedControlType, segments: [String], selectedSegmentIndex: Int? = nil) {
        super.init(frame: .zero)
        setUpSegments(type: type, segments: segments)
        if let selectedSegmentIndex = selectedSegmentIndex {
            self.selectedSegmentIndex = selectedSegmentIndex
        }

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 서브뷰 레이아웃 설정
    public override func layoutSubviews() {
        super.layoutSubviews()
        // layout이 업데이트 될 때 underbar 업데이트
        let underlineFinalXPosition = (self.bounds.width / CGFloat(self.numberOfSegments)) * CGFloat(self.selectedSegmentIndex)
        self.underlineView.snp.updateConstraints { make in
            make.leading.equalTo(underlineFinalXPosition)
        }
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut) {
            self.layoutIfNeeded()
        }
    }
}

// MARK: - SetUp
private extension PPSegmentedControl {

    /// 세그먼트 설정 메서드
    /// - Parameters:
    ///   - type: 세그먼트 컨트롤 타입
    ///   - segments: 세그먼트 타이틀 배열
    public func setUpSegments(type: SegmentedControlType, segments: [String]) {
        let emptyImage = UIImage()
        for seg in segments.reversed() {
            self.insertSegment(withTitle: seg, at: 0, animated: true)
        }
        self.snp.makeConstraints { make in
            make.height.equalTo(48)
        }
        // 디바이더 제거
        self.setDividerImage(emptyImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        switch type {
        case .radio:
            // background color 변경이 g50값으로 변경이 되지 않아 subview에 접근하여 layer를 Hidden처리
            for (index, view) in self.subviews.enumerated() {
                if segments.count > index {
                    view.layer.isHidden = true
                }
            }
            self.selectedSegmentTintColor = .blu500
            setFont(color: .w100, font: .korFont(style: .bold, size: 15), state: .selected)
            setFont(color: .g400, font: .korFont(style: .medium, size: 15), state: .normal)
        case .base:
            // background color 변경이 g50값으로 변경이 되지 않아 subview에 접근하여 layer를 Hidden처리 하고 새로운 뷰를 덮어씌워서 색상을 적용
            for (index, view) in self.subviews.enumerated() {
                if segments.count > index {
                    let bgView = UIView()
                    view.addSubview(bgView)
                    bgView.snp.makeConstraints { make in
                        make.edges.equalToSuperview()
                    }
                    bgView.backgroundColor = .g50
                }
            }
            self.selectedSegmentTintColor = .blu500
            setFont(color: .w100, font: .korFont(style: .bold, size: 15), state: .selected)
            setFont(color: .g400, font: .korFont(style: .medium, size: 14), state: .normal)
        case .tab:
            self.clipsToBounds = false
            self.setBackgroundImage(emptyImage, for: .normal, barMetrics: .default)
            self.setBackgroundImage(emptyImage, for: .selected, barMetrics: .default)
            self.setBackgroundImage(emptyImage, for: .highlighted, barMetrics: .default)
            bottomLineView.isHidden = false
            underlineView.isHidden = false
            bottomLineView.snp.makeConstraints { make in
                make.height.equalTo(1)
                make.leading.trailing.bottom.equalToSuperview()
            }
            underlineView.snp.makeConstraints { make in
                make.width.equalTo(bottomLineView.snp.width).dividedBy(self.numberOfSegments)
                make.height.equalTo(2)
                make.bottom.equalTo(bottomLineView.snp.bottom)
            }
            setFont(color: .blu500, font: .korFont(style: .bold, size: 15), state: .selected)
            setFont(color: .g400, font: .korFont(style: .medium, size: 15), state: .normal)
        }
    }

    /// 폰트 설정 메서드
    /// - Parameters:
    ///   - color: 폰트 색상
    ///   - font: 폰트 스타일
    ///   - state: 세그먼트 상태
    public func setFont(color: UIColor, font: UIFont?, state: UIControl.State) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        self.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.font: font!,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ], for: state)
    }
}
