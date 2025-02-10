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

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame.size = CGSize(width: 200, height: 0) // 고정된 너비, 동적 높이
        setupLayout()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupLayout() {
        addSubview(containerView)
        self.isUserInteractionEnabled = true
        containerView.isUserInteractionEnabled = true
        stackView.isUserInteractionEnabled = true

        containerView.addSubview(stackView)

        containerView.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.edges.equalToSuperview()
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
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // stores 배열을 역순으로 처리
        let reversedStores = stores.reversed()

        for (index, store) in reversedStores.enumerated() {
            let rowContainer = UIView()
            rowContainer.isUserInteractionEnabled = true
            rowContainer.tag = stores.count - 1 - index  // 인덱스도 반대로 설정
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
            stackView.addArrangedSubview(rowContainer)

            if index < stores.count - 1 {
                let separator = UIView()
                separator.backgroundColor = .g50
                separator.snp.makeConstraints { make in
                    make.height.equalTo(1)
                }
                stackView.addArrangedSubview(separator)
            }
        }

        selectStore(at: 0)
    

        // 레이아웃 업데이트
        setNeedsLayout()
        layoutIfNeeded()

        // 컨텐츠 크기에 맞게 높이 조정
        let height = stackView.systemLayoutSizeFitting(
            CGSize(width: 200, height: UIView.layoutFittingCompressedSize.height)
        ).height + 24 // 24는 상하 패딩

        self.frame.size.height = height
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
        for case let row as UIView in stackView.arrangedSubviews {
            guard let horizontalStack = row.subviews.first as? UIStackView,
                  horizontalStack.arrangedSubviews.count >= 2,
                  let bulletView = horizontalStack.arrangedSubviews.first,
                  let label = horizontalStack.arrangedSubviews.last as? UILabel
            else { continue }

            if row.tag == index {
                label.font = .boldSystemFont(ofSize: 12)
                bulletView.backgroundColor = .jd500
            } else {
                label.font = .systemFont(ofSize: 12)
                bulletView.backgroundColor = .clear
            }
        }
    }
}
