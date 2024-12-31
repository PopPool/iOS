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

    // CompositionalLayout
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { section, env in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .estimated(200),
                heightDimension: .absolute(30)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(30)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = .fixed(8)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 20, leading: 20, bottom: 19, trailing: 20)
            section.interGroupSpacing = 8
            return section
        }

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.register(BalloonChipCell.self, forCellWithReuseIdentifier: BalloonChipCell.identifier)
        return cv
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

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupLayout()
        setupCollectionView()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup
    private func setupLayout() {
        addSubview(containerView)
        containerView.addSubview(collectionView)

        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(11)
        }

        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
    }

    // MARK: - Draw arrow
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

    // MARK: - Public
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
                    isSelected: subRegion == "\(mainRegionTitle)전체"
                        ? selectedRegions.count == subRegions.count
                        : selectedRegions.contains(subRegion)
                )
            }
        )

        // reload
        collectionView.reloadData()
        // layoutIfNeeded
        collectionView.layoutIfNeeded()

        // manual height calc
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
        let totalInsets: CGFloat = 40 // left(20) + right(20)
        let availableWidth = screenWidth - totalInsets

        var currentRowWidth: CGFloat = 0
        var numberOfRows: Int = 1

        for input in inputDataList {
            let buttonWidth = calculateButtonWidth(for: input.title ?? "", font: .systemFont(ofSize: 12),            isSelected: input.isSelected ?? false
)


            if currentRowWidth + buttonWidth + horizontalSpacing > availableWidth {
                numberOfRows += 1
                currentRowWidth = buttonWidth
            } else {
                currentRowWidth += buttonWidth + horizontalSpacing
            }
        }

        let itemHeight: CGFloat = 36
        let interGroupSpacing: CGFloat = 8
        let verticalInset: CGFloat = 20 + 19 // top/bottom in CompositionalLayout

        return (itemHeight * CGFloat(numberOfRows))
             + (interGroupSpacing * CGFloat(numberOfRows - 1))
             + verticalInset
    }

    private func calculateButtonWidth(for text: String, font: UIFont, isSelected: Bool) -> CGFloat {
        let textWidth = (text as NSString).size(withAttributes: [.font: font]).width

        // iconWidth는 선택된 상태에서만 16, 아니면 0
        let iconWidth: CGFloat = isSelected ? 16 : 0
        let iconGap: CGFloat = isSelected ? 4 : 0

        // contentEdgeInsets (왼+오른)
        // ex: isSelected(왼10+오른12=22), else(왼12+오른10=22)
        // 실제로 합치면 22
        let horizontalInsets: CGFloat = 22

        // 최종 너비
        return textWidth + iconWidth + iconGap + horizontalInsets
    }
}

// MARK: - UICollectionViewDataSource
extension BalloonBackgroundView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagSection?.inputDataList.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: BalloonChipCell.identifier,
                for: indexPath
            ) as? BalloonChipCell,
            let input = tagSection?.inputDataList[indexPath.item]
        else {
            return UICollectionViewCell()
        }

        cell.configure(with: input.title ?? "", isSelected: input.isSelected)
        cell.buttonAction = { [weak self] in
            guard let self = self else { return }
            if indexPath.item == 0 {
                self.allSelectionHandler?()
            } else {
                if let title = input.title {
                    self.selectionHandler?(title)
                }
            }
        }
        return cell
    }
}
