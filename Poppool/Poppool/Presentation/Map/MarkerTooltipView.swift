import UIKit
import Foundation


class MarkerTooltipView: UIView {

    // 컨테이너 뷰: 흰색 배경, 둥근 모서리, 그림자, blu500 보더
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.borderColor = UIColor.blu500.cgColor
        view.layer.borderWidth = 1  // Level1 두께
        return view
    }()

    // 스택뷰: 세로 방향으로 각 스토어 행과 separator를 배치
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout Setup
    private func setupLayout() {
        addSubview(containerView)
        containerView.addSubview(stackView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }

    // MARK: - Configuration
    /// 내부에 들어갈 스토어 정보를 받아서 각 행을 구성합니다.
    /// 각 행은 좌측에 bullet과 우측에 라벨로 구성되며, 라벨은 blu500 색상으로 표시됩니다.
    /// 스토어 행 사이에는 두께 1pt, g50 컬러의 separator가 추가됩니다.
    func configure(with stores: [MapPopUpStore]) {
        // 기존의 모든 arrangedSubviews 제거
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, store) in stores.enumerated() {
            // 개별 스토어 행을 담을 컨테이너 뷰
            let rowContainer = UIView()

            // 수평 스택뷰: 좌측 bullet, 우측 라벨
            let horizontalStack = UIStackView()
            horizontalStack.axis = .horizontal
            horizontalStack.spacing = 8
            horizontalStack.alignment = .center

            // bullet view: 기본은 숨김(.clear)
            let bulletView = UIView()
            bulletView.backgroundColor = .clear
            bulletView.layer.cornerRadius = 4  // 8x8 크기의 원형으로 만들기 위해
            bulletView.snp.makeConstraints { make in
                make.width.height.equalTo(8)
            }

            // 라벨: 스토어 이름, blu500 색상, 기본 폰트 12pt
            let label = UILabel()
            label.text = store.name
            label.font = .systemFont(ofSize: 12)
            label.textColor = .blu500
            label.numberOfLines = 1
            label.isUserInteractionEnabled = true
            label.tag = index  // 탭된 스토어를 식별하기 위한 태그

            // 탭 제스처 추가: 탭 시 handleLabelTap(_:) 호출
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLabelTap(_:)))
            label.addGestureRecognizer(tapGesture)

            horizontalStack.addArrangedSubview(bulletView)
            horizontalStack.addArrangedSubview(label)

            rowContainer.addSubview(horizontalStack)
            horizontalStack.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            // 스택뷰에 행 추가
            stackView.addArrangedSubview(rowContainer)

            // 마지막 행이 아니라면 separator 추가 (두께 1pt, g50 색상)
            if index < stores.count - 1 {
                let separator = UIView()
                separator.backgroundColor = .g50
                separator.snp.makeConstraints { make in
                    make.height.equalTo(1)
                }
                stackView.addArrangedSubview(separator)
            }
        }

        // 기본 선택: 첫 번째 스토어 선택 처리
        selectStore(at: 0)
    }

    // MARK: - Store Selection Handling
    /// 라벨 탭 제스처 핸들러
    @objc private func handleLabelTap(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel else { return }
        selectStore(at: label.tag)
    }

    /// 선택된 스토어의 인덱스에 따라 UI 업데이트: 해당 라벨은 Bold, bullet은 jd500 색상으로 표시.
    private func selectStore(at index: Int) {
        // stackView의 arrangedSubviews 중 실제 스토어 행만 순회합니다.
        // (separator는 UIView 타입이지만 자식 뷰가 없으므로 무시)
        for subview in stackView.arrangedSubviews {
            // 스토어 행은 rowContainer 내부에 horizontalStack이 있으므로 이를 통해 구분합니다.
            if let horizontalStack = subview.subviews.first as? UIStackView,
               horizontalStack.arrangedSubviews.count >= 2,
               let bulletView = horizontalStack.arrangedSubviews.first,
               let label = horizontalStack.arrangedSubviews.last as? UILabel {

                if label.tag == index {
                    // 선택된 스토어: Bold 폰트, bullet 색상 jd500
                    label.font = .boldSystemFont(ofSize: 12)
                    bulletView.backgroundColor = .jd500
                } else {
                    // 나머지 스토어: 일반 폰트, bullet 숨김
                    label.font = .systemFont(ofSize: 12)
                    bulletView.backgroundColor = .clear
                }
            }
        }
    }
}
