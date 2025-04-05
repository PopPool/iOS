import SnapKit
import UIKit

final class FilterChipsView: UIView {
    // MARK: - Components
    var onRemoveChip: ((String) -> Void)?
    private let titleLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 13)
        label.text = "선택한 옵션"
        label.textColor = .g200
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(FilterCell.self, forCellWithReuseIdentifier: "FilterCell")
        return collectionView
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "선택한 옵션이 없어요 :)"
        label.textColor = .g300
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.isHidden = true // 초기에는 숨김 상태
        return label
    }()

    private var filters: [String] = []

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupCollectionView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout Setup
    private func setupLayout() {
        addSubview(titleLabel)
        addSubview(collectionView)
        addSubview(emptyStateLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
            make.height.greaterThanOrEqualTo(44).priority(.high)
        }

        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalTo(collectionView)
        }
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
    }

    // MARK: - Configuration
    func configure(with filters: [String]) {
        self.filters = filters
        updateUI()
    }

    func updateChips(with filters: [String]) {
        self.filters = filters
        updateUI()
    }

    private func updateUI() {
        let isEmpty = filters.isEmpty
        collectionView.isHidden = isEmpty
        emptyStateLabel.isHidden = !isEmpty
        collectionView.reloadData()
    }

    private func removeFilter(at index: Int) {
        let removedFilter = filters[index]
        filters.remove(at: index)
        updateUI()

        // 콜백 호출
        onRemoveChip?(removedFilter)
    }
}

// MARK: - UICollectionViewDataSource
extension FilterChipsView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as? FilterCell else {
            return UICollectionViewCell()
        }

        let filterText = filters[indexPath.item]
        cell.configure(with: filterText)
        cell.onRemove = { [weak self] in
            self?.removeFilter(at: indexPath.item)
        }
        return cell
    }
}
