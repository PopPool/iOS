import UIKit
import SnapKit

final class MarkerTooltipView: UIView, UIGestureRecognizerDelegate {

    // MARK: - Properties
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.borderColor = UIColor.blu500.cgColor
        view.layer.borderWidth = 1
        return view
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    var onStoreSelected: ((Int) -> Void)?
    var selectedIndex: Int = -1

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame.size = CGSize(width: 200, height: 100) // 임시 높이로 시작
        setupLayout()
//        setupGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupLayout() {
        addSubview(containerView)
        containerView.addSubview(stackView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(200)
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }

    private func setupGestures() {
        // 컨테이너 전체에 대한 탭 제스처
        let containerTap = UITapGestureRecognizer(target: self, action: #selector(handleContainerTap(_:)))
        containerTap.delegate = self
        containerView.addGestureRecognizer(containerTap)

        // 외부 탭 차단을 위한 제스처
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(_:)))
        backgroundTap.delegate = self
        self.addGestureRecognizer(backgroundTap)
    }

    // MARK: - Configuration
    func configure(with stores: [MapPopUpStore]) {
        // 기존 뷰 제거
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        print("🗨️ 툴팁 구성")
        print("📋 입력받은 스토어: \(stores.map { $0.name })")

        // stores 배열 순서대로 처리
        for (index, store) in stores.enumerated() {
            let rowContainer = createRow(for: store, at: index)
            stackView.addArrangedSubview(rowContainer)

            // 구분선 추가 (마지막 아이템 제외)
            if index < stores.count - 1 {
                let separator = createSeparator()
                stackView.addArrangedSubview(separator)
            }
        }

        // 레이아웃 업데이트
        layoutIfNeeded()

        // 컨텐츠 크기에 맞게 높이 조정
        let height = stackView.systemLayoutSizeFitting(
            CGSize(width: 200, height: UIView.layoutFittingCompressedSize.height)
        ).height + 24

        // frame 높이 업데이트
        self.frame.size.height = height
    }

    private func createRow(for store: MapPopUpStore, at index: Int) -> UIView {
        let rowContainer = UIView()
        rowContainer.isUserInteractionEnabled = true
        rowContainer.tag = index  // 정순 인덱스 사용

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleRowTap(_:)))
        rowContainer.addGestureRecognizer(tapGesture)

        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 8
        horizontalStack.alignment = .center

        let bulletView = UIView()
        bulletView.backgroundColor = .clear
        bulletView.layer.cornerRadius = 4
        bulletView.snp.makeConstraints { make in
            make.width.height.equalTo(8)
        }

        let label = UILabel()
        label.text = store.name
        label.font = .systemFont(ofSize: 12)
        label.textColor = .blu500
        label.numberOfLines = 1

        horizontalStack.addArrangedSubview(bulletView)
        horizontalStack.addArrangedSubview(label)

        rowContainer.addSubview(horizontalStack)
        horizontalStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        return rowContainer
    }

    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .g50
        separator.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        return separator
    }

    // MARK: - Gesture Handling
    @objc private func handleContainerTap(_ gesture: UITapGestureRecognizer) {
        gesture.cancelsTouchesInView = true
    }

    @objc private func handleBackgroundTap(_ gesture: UITapGestureRecognizer) {
        gesture.cancelsTouchesInView = true
    }

    @objc private func handleRowTap(_ gesture: UITapGestureRecognizer) {
        guard let row = gesture.view else { return }
        let index = row.tag

        print("🗨️ 툴팁 탭")
        print("👆 탭된 인덱스: \(index)")

        gesture.cancelsTouchesInView = true
        selectStore(at: index)
        onStoreSelected?(index)
    }

    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                          shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view,
           touchView.isDescendant(of: stackView) {
            return false
        }
        return true
    }

    // MARK: - Store Selection
    func selectStore(at index: Int) {
        selectedIndex = index
        for case let row as UIView in stackView.arrangedSubviews {
            guard let horizontalStack = row.subviews.first as? UIStackView,
                  horizontalStack.arrangedSubviews.count >= 2,
                  let bulletView = horizontalStack.arrangedSubviews.first,
                  let label = horizontalStack.arrangedSubviews.last as? UILabel
            else { continue }

            if row.tag == index {
                // 선택된 행
                label.font = .boldSystemFont(ofSize: 12)
                bulletView.backgroundColor = .jd500
            } else {
                // 선택되지 않은 행
                label.font = .systemFont(ofSize: 12)
                bulletView.backgroundColor = .clear
            }
        }
    }
}
