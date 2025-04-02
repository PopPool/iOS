import SnapKit
import UIKit

final class FilterCell: UICollectionViewCell {
    // MARK: - Properties
    private let chipView = FilterChip()

    var onRemove: (() -> Void)?

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupLayout() {
        contentView.addSubview(chipView)
        chipView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupActions() {
        chipView.onClose = { [weak self] in
            self?.onRemove?()
        }
    }

    // MARK: - Configuration
    func configure(with text: String) {
        chipView.setTitle(text, style: .option)
    }
}
