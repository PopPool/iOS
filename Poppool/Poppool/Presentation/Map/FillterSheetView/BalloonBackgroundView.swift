import SnapKit
import UIKit

final class BalloonBackgroundView: UIView {

    // MARK: - UI Components

    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.backgroundColor = UIColor.g50
        return view
    }()

    // 기존 말풍선 UI: 서브 지역을 나열하는 CollectionView (서울/경기/부산용)
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { section, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .estimated(30),
                heightDimension: .absolute(30)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(36)
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

    // "그 외 지역" 전용 UI: 아이콘과 안내문구
    private let singleRegionIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .blu500
        iv.image = UIImage(named: "Marker") // 에셋에 추가된 Marker 이미지
        iv.isHidden = true  // 기본은 숨김
        return iv
    }()

    private let singleRegionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.blu500
        label.textAlignment = .center
        return label
    }()

    private let singleRegionDetailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.g400
        label.textAlignment = .center
        label.numberOfLines = 2  // 두 줄 표시
        return label
    }()

    // MARK: - Properties

    var arrowPosition: CGFloat = 0.6 {
        didSet {
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    private let arrowHeight: CGFloat = 10

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
        containerView.snp.makeConstraints { make in
                 make.left.right.bottom.equalToSuperview()
                 make.top.equalToSuperview().offset(arrowHeight)
             }

        containerView.addSubview(collectionView)
        containerView.addSubview(singleRegionIcon)
        containerView.addSubview(singleRegionTitleLabel)
        containerView.addSubview(singleRegionDetailLabel)

        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        singleRegionIcon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 24, height: 24))
        }

        singleRegionTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(singleRegionIcon.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        if singleRegionDetailLabel.superview != nil {
            singleRegionDetailLabel.snp.makeConstraints { make in
                make.top.equalTo(singleRegionTitleLabel.snp.bottom).offset(4)
                make.left.equalToSuperview().offset(18)
                make.right.equalToSuperview().inset(18)
            }
        }
    }
    private func setupCollectionView() {
        collectionView.dataSource = self
    }

    // MARK: - Draw Arrow

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let arrowWidth: CGFloat = 12  // 화살표 너비 조정
        let arrowHeight: CGFloat = 8   // 화살표 높이 조정

        // 화살표의 시작 x좌표 계산
        let arrowX = bounds.width * arrowPosition - (arrowWidth / 2)

        // 경로 그리기
        let path = UIBezierPath()

        // 1. 화살표 그리기
        path.move(to: CGPoint(x: arrowX, y: arrowHeight))                         // 왼쪽 아래
        path.addLine(to: CGPoint(x: arrowX + (arrowWidth / 2), y: 0))            // 상단 중앙
        path.addLine(to: CGPoint(x: arrowX + arrowWidth, y: arrowHeight))        // 오른쪽 아래

        // 2. 말풍선 본체 그리기
        let balloonRect = CGRect(x: 0, y: arrowHeight,
                                width: bounds.width,
                                height: bounds.height - arrowHeight)

        path.addLine(to: CGPoint(x: balloonRect.maxX, y: balloonRect.minY))      // 오른쪽 상단
        path.addLine(to: CGPoint(x: balloonRect.maxX, y: balloonRect.maxY))      // 오른쪽 하단
        path.addLine(to: CGPoint(x: balloonRect.minX, y: balloonRect.maxY))      // 왼쪽 하단
        path.addLine(to: CGPoint(x: balloonRect.minX, y: balloonRect.minY))      // 왼쪽 상단

        path.close()

        UIColor.g50.setFill()
        path.fill()

        // 그림자 설정
//        layer.shadowPath = path.cgPath
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOpacity = 0.1
//        layer.shadowOffset = CGSize(width: 0, height: 2)
//        layer.shadowRadius = 4
    }

    // MARK: - Public

    /// configure 메서드
    /// 서울/경기/부산이면 기존 말풍선 UI(서브지역 콜렉션뷰)를 표시
    /// 그 외 지역이면 단일 아이콘+안내 문구 UI를 containerView 내부에 표시
    func configure(for mainRegion: String,
                   subRegions: [String],
                   selectedRegions: [String],
                   selectionHandler: @escaping (String) -> Void,
                   allSelectionHandler: @escaping () -> Void) {
        self.mainRegionTitle = mainRegion
        self.currentSubRegions = subRegions
        self.selectedRegions = Set(selectedRegions)
        self.selectionHandler = selectionHandler
        self.allSelectionHandler = allSelectionHandler

        containerView.isHidden = false

        if ["서울", "경기", "부산"].contains(mainRegion) {
            collectionView.isHidden = false
            singleRegionIcon.isHidden = true
            singleRegionTitleLabel.isHidden = true
            singleRegionDetailLabel.isHidden = true
            setupTagSection()
            collectionView.reloadData()
        } else {
            collectionView.isHidden = true
            singleRegionIcon.isHidden = false
            singleRegionTitleLabel.isHidden = false
            singleRegionDetailLabel.isHidden = false

            singleRegionTitleLabel.text = mainRegion
            singleRegionDetailLabel.text = "선택하신 지역은 상세\n구분 없이 팝업을 보여드릴게요"
        }
    }

    private func setupTagSection() {
        let allKey = "\(mainRegionTitle)전체"

        let originalList = currentSubRegions
        var inputDataList = [allKey]

        inputDataList.append(contentsOf: originalList.map { subRegion in
            let isSelected = selectedRegions.contains(subRegion)
            return subRegion
        })

        self.tagSection = TagSection(
            inputDataList: inputDataList.map {
                TagSectionCell.Input(
                    title: $0,
                    isSelected: ($0 == allKey ? selectedRegions.contains(allKey) : selectedRegions.contains($0))
                )
            }
        )
    }

    func calculateHeight() -> CGFloat {
       if collectionView.isHidden {
           return 145
       }

       guard let inputDataList = tagSection?.inputDataList else { return 0 }

       collectionView.layoutIfNeeded()

       print("실제 contentSize 높이: \(collectionView.collectionViewLayout.collectionViewContentSize.height)")

       let balloonWidth = self.bounds.width
       let horizontalSpacing: CGFloat = 8
       let leftPadding: CGFloat = 20
       let rightPadding: CGFloat = 20
       let availableWidth = balloonWidth - leftPadding - rightPadding

       print("사용 가능한 너비: \(availableWidth)")

       var currentRowWidth: CGFloat = 0
       var numberOfRows: Int = 1

       for input in inputDataList {
           let buttonWidth = calculateButtonWidth(for: input.title ?? "", font: .systemFont(ofSize: 12), isSelected: input.isSelected ?? false)
           print("버튼 너비 [\(input.title ?? "")]: \(buttonWidth)")

           let widthWithSpacing = currentRowWidth == 0 ? buttonWidth : buttonWidth + horizontalSpacing

           if currentRowWidth + widthWithSpacing > availableWidth {
               numberOfRows += 1
               currentRowWidth = buttonWidth
               print("새로운 줄 시작: \(numberOfRows)번째 줄")
           } else {
               currentRowWidth += widthWithSpacing
               print("현재 줄 너비: \(currentRowWidth)")
           }
       }

       let itemHeight: CGFloat = 36
       let interGroupSpacing: CGFloat = 8
       let verticalInset: CGFloat = 20 + 20  // top: 20, bottom: 20
       let totalHeight = max(
           (itemHeight * CGFloat(numberOfRows)) +
           (interGroupSpacing * CGFloat(numberOfRows - 1)) +
           verticalInset,
           36
       )

       print("계산된 최종 높이: \(totalHeight)")
       return totalHeight
    }
    private func calculateButtonWidth(for text: String, font: UIFont, isSelected: Bool) -> CGFloat {
        let textWidth = (text as NSString).size(withAttributes: [.font: font]).width
        let iconWidth: CGFloat = isSelected ? 16 : 0
        let iconGap: CGFloat = isSelected ? 4 : 0
        let horizontalPadding: CGFloat = 24
        return textWidth + iconWidth + iconGap + horizontalPadding
    }
}

// MARK: - UICollectionViewDataSource
extension BalloonBackgroundView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagSection?.inputDataList.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
            } else if let title = input.title {
                self.selectionHandler?(title)
            }
        }
        return cell
    }
}
