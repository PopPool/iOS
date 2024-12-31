import UIKit

final class FilterChipsView: UIView {
    // MARK: - Components
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

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(44)
        }
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
    }
    

    // MARK: - Configuration
    func configure(with filters: [String]) {
        self.filters = filters
        collectionView.reloadData()
    }
    func updateChips(with filters: [String]) {
           self.filters = filters
           collectionView.reloadData()
       }
   

    private func removeFilter(at index: Int) {
        filters.remove(at: index)
        collectionView.reloadData()
    }
}

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
