import UIKit
import SnapKit

final class BalloonBackgroundView: UIView {
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .g50
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { section, env in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .estimated(80),
                heightDimension: .absolute(30)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(30)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            group.interItemSpacing = .fixed(8)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 20, leading: 20, bottom: 19, trailing: 20)
            section.interGroupSpacing = 8

            return section
        }

        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(BalloonChipCell.self, forCellWithReuseIdentifier: BalloonChipCell.identifier)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    
    
    // MARK: - Properties
    var arrowPosition: CGFloat = 0.6 {
        didSet {
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    private var selectedRegions: Set<String> = []
    private var currentSubRegions: [String] = []
    private var mainRegionTitle: String = ""
    private var selectionHandler: ((String) -> Void)?
    private var allSelectionHandler: (() -> Void)?
    private var tagSection: TagSection?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupLayout()
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupLayout() {
        addSubview(containerView)
        containerView.addSubview(collectionView)
        
        containerView.snp.makeConstraints { make in
               make.leading.trailing.equalToSuperview() // 
               make.bottom.equalToSuperview()
               make.top.equalToSuperview().offset(11)
           }

           collectionView.snp.makeConstraints { make in
               make.edges.equalTo(containerView.snp.edges)  // edges로 한번에 설정
           }
       }

    private func setupCollectionView() {
        collectionView.dataSource = self
    }
    

    // MARK: - Drawing
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let arrowWidth: CGFloat = 16
        let arrowHeight: CGFloat = 10
        
        let arrowX = bounds.width * arrowPosition - (arrowWidth / 2)
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: arrowX, y: 8))
        path.addLine(to: CGPoint(x: arrowX + arrowWidth, y: 8))
        path.addLine(to: CGPoint(x: arrowX + (arrowWidth / 2), y: 0))
        path.close()
        
        UIColor.g50.set()
        path.fill()
    }
    
    // MARK: - Public Methods
    func configure(
        with subRegions: [String],
        selectedRegions: [String] = [],
        mainRegionTitle: String,
        selectionHandler: @escaping (String) -> Void,
        allSelectionHandler: @escaping () -> Void
    ) {
        self.currentSubRegions = subRegions
        self.selectedRegions = Set(selectedRegions)
        self.mainRegionTitle = mainRegionTitle
        self.selectionHandler = selectionHandler
        self.allSelectionHandler = allSelectionHandler

        var inputDataList = ["\(mainRegionTitle)전체"]
        inputDataList.append(contentsOf: subRegions)

        self.tagSection = TagSection(
            inputDataList: inputDataList.map { subRegion in
                TagSectionCell.Input(
                    title: subRegion,
                    isSelected: subRegion == "\(mainRegionTitle)전체" ? selectedRegions.count == subRegions.count : selectedRegions.contains(subRegion)
                )
            }
        )

        collectionView.reloadData()

        let dynamicHeight = calculateHeight()
        self.snp.updateConstraints { make in
            make.height.equalTo(dynamicHeight)
        }

        self.layoutIfNeeded()
    }


    
    func calculateHeight() -> CGFloat {
        guard let inputDataList = tagSection?.inputDataList else { return 0 }

        let screenWidth = UIScreen.main.bounds.width
        let horizontalSpacing: CGFloat = 8
        let totalInsets: CGFloat = 40
        let availableWidth = screenWidth - totalInsets

        var currentRowWidth: CGFloat = 0
        var numberOfRows: Int = 1

        for input in inputDataList {
            let buttonWidth = calculateButtonWidth(for: input.title ?? "", font: .systemFont(ofSize: 12))

            if currentRowWidth + buttonWidth + horizontalSpacing > availableWidth {
                numberOfRows += 1
                currentRowWidth = buttonWidth
            } else {
                currentRowWidth += buttonWidth + horizontalSpacing
            }
        }

        let itemHeight: CGFloat = 36 // 버튼 높이
        let interGroupSpacing: CGFloat = 8 // 줄 간 간격
        let verticalInset: CGFloat = 20 + 19 // 상하 여백

        return (itemHeight * CGFloat(numberOfRows)) +
               (interGroupSpacing * CGFloat(numberOfRows - 1)) +
               verticalInset
    }

    private func calculateButtonWidth(for text: String, font: UIFont) -> CGFloat {
        let textWidth = (text as NSString).size(withAttributes: [.font: font]).width
        let iconWidth: CGFloat = 16
        let padding: CGFloat = 2
        return textWidth + (iconWidth > 0 ? (iconWidth + 4) : 0) + padding
    }
}

// MARK: - UICollectionViewDataSource
extension BalloonBackgroundView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = tagSection?.inputDataList.count ?? 0
        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BalloonChipCell.identifier,
            for: indexPath
        ) as? BalloonChipCell else {
            return UICollectionViewCell()
        }

        if let input = tagSection?.inputDataList[indexPath.item] {
            cell.configure(with: input.title ?? "", isSelected: input.isSelected)

            cell.buttonAction = { [weak self] in
                if indexPath.item == 0 {
                    self?.allSelectionHandler?()
                } else {
                    if let title = input.title {
                        self?.selectionHandler?(title)
                    }
                }
            }
        }

        return cell
    }

}
