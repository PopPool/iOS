import UIKit

import RxCocoa
import RxSwift
import SnapKit

public final class PPProgressIndicator: UIStackView {

    // MARK: - Properties
    private var progressViews: [PPProgressView]
    private var progressIndex: Int

    // MARK: - init
    /// 전체 단계 수와 시작 지점을 기반으로 CMPTProgressIndicator를 초기화
    /// - Parameters:
    ///   - totalStep: 전체 단계 수
    ///   - startPoint: 초기 시작 지점 (1부터 시작하는 인덱스)
    public init(totalStep: Int, startPoint: Int) {
        self.progressViews = (1...totalStep).map({ index in
            return PPProgressView(isSelected: index == startPoint)
        })
        self.progressIndex = startPoint
        super.init(frame: .zero)
        setUp()
        setUpConstraints()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SetUp
private extension PPProgressIndicator {

    /// 스택 뷰 속성 설정
    func setUp() {
        self.axis = .horizontal
        self.distribution = .fillEqually
        self.spacing = 6
    }

    /// 진행 뷰의 제약 조건을 설정
    func setUpConstraints() {
        progressViews.forEach { views in
            self.addArrangedSubview(views)
        }
    }
}

// MARK: - Methods
extension PPProgressIndicator {

    /// 진행 인디케이터를 한 단계 앞으로 이동
    public func increaseIndicator() {
        if progressIndex < progressViews.count {
            progressViews[progressIndex - 1].disappearAnimation(option: .fromLeft)
            progressIndex += 1
            progressViews[progressIndex - 1].fillAnimation(option: .fromLeft)
        }
    }

    /// 진행 인디케이터를 한 단계 뒤로 이동
    public func decreaseIndicator() {
        if progressIndex - 1 > 0 {
            progressViews[progressIndex - 1].disappearAnimation(option: .fromRight)
            progressIndex -= 1
            progressViews[progressIndex - 1].fillAnimation(option: .fromRight)
        }
    }
}
