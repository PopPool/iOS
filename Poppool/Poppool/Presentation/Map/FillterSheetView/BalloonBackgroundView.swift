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
                widthDimension: .estimated(30),
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

        // UICollectionView 데이터 갱신
        collectionView.reloadData()
        collectionView.layoutIfNeeded()

        let dynamicHeight = calculateHeight()
        self.snp.updateConstraints { make in
            make.height.equalTo(dynamicHeight)
        }

        self.layoutIfNeeded()
    }

    func calculateHeight() -> CGFloat {
        guard let inputDataList = tagSection?.inputDataList else { return 0 }

        let balloonWidth = self.bounds.width
        let horizontalSpacing: CGFloat = 8 // 버튼 간 간격
        let leftPadding: CGFloat = 20 // 왼쪽 패딩
        let rightPadding: CGFloat = 20 // 오른쪽 패딩
        let availableWidth = balloonWidth - leftPadding - rightPadding - horizontalSpacing

        var currentRowWidth: CGFloat = 0
        var numberOfRows: Int = 1

        for input in inputDataList {
            // 버튼 너비 계산
            let buttonWidth = calculateButtonWidth(for: input.title ?? "", font: .systemFont(ofSize: 12), isSelected: input.isSelected ?? false)
//            print("DEBUG - Calculated Button Width: \(buttonWidth)")

            if currentRowWidth + buttonWidth + horizontalSpacing > availableWidth {
//                print("""
//                DEBUG - 줄바꿈 발생:
//                    버튼 길이: \(buttonWidth),
//                    버튼 간 패딩: \(horizontalSpacing),
//                    현재 줄 누적 너비: \(currentRowWidth),
//                    가용 너비: \(availableWidth),
//                    새로운 줄 시작.
//                """)
                numberOfRows += 1
                currentRowWidth = buttonWidth
            } else {
                currentRowWidth += buttonWidth + horizontalSpacing
//                print("""
//                DEBUG - 현재 줄에 추가:
//                    버튼 길이: \(buttonWidth),
//                    버튼 간 패딩: \(horizontalSpacing),
//                    현재 줄 누적 너비: \(currentRowWidth),
//                    가용 너비: \(availableWidth).
//                """)
            }
        }

        // 높이 계산
        let itemHeight: CGFloat = 36
        let interGroupSpacing: CGFloat = 8
        let verticalInset: CGFloat = 20 + 19
        let totalHeight = max(
            (itemHeight * CGFloat(numberOfRows)) +
            (interGroupSpacing * CGFloat(numberOfRows - 1)) +
            verticalInset,
            36
        )

//        print("DEBUG - Total Calculated Height: \(totalHeight)")
        return totalHeight
    }
    private func calculateButtonWidth(for text: String, font: UIFont, isSelected: Bool) -> CGFloat {
        let textWidth = (text as NSString).size(withAttributes: [.font: font]).width
        let iconWidth: CGFloat = isSelected ? 16 : 0
        let iconGap: CGFloat = isSelected ? 4 : 0

        let horizontalPadding: CGFloat = 24

        let calculatedWidth = textWidth + iconWidth + iconGap + horizontalPadding

        // 디버깅 출력
//        print("DEBUG - 텍스트: \(text), 선택 상태: \(isSelected), 최종 버튼 너비: \(calculatedWidth)")

        return calculatedWidth
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
