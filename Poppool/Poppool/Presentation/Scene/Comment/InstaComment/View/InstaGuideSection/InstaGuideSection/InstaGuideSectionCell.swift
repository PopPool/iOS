//
//  InstaGuideSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/15/24.
//

import UIKit

import SnapKit
import RxSwift

final class InstaGuideSectionCell: UICollectionViewCell {
    
    // MARK: - Components

    let disposeBag = DisposeBag()
    
    private var autoScrollTimer: Timer?
    
    private lazy var contentCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
        view.isScrollEnabled = false
        view.backgroundColor = .g50
        return view
    }()
    
    var pageControl: UIPageControl = {
        let controller = UIPageControl()
        controller.currentPage = 0
        controller.preferredIndicatorImage = UIImage(systemName: "circle")
        controller.preferredCurrentPageIndicatorImage = UIImage(systemName: "circle.fill")
        controller.pageIndicatorTintColor = .pb30
        controller.currentPageIndicatorTintColor = .g600
        controller.isUserInteractionEnabled = false
        controller.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        return controller
    }()
    
    let stopButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_banner_stopButton_gray"), for: .normal)
        return button
    }()
    
    private var isAutoBannerPlay: Bool = false
    
    private var imageSection = InstaGuideChildSection(inputDataList: [])
    
    lazy var compositionalLayout: UICollectionViewCompositionalLayout = {
        UICollectionViewCompositionalLayout { [weak self] section, env in
            guard let self = self else {
                return NSCollectionLayoutSection(group: NSCollectionLayoutGroup(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)
                    ))
                )
            }
            return getSection()[section].getSection(section: section, env: env)
        }
    }()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
        setUpConstraints()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopAutoScroll()
    }
    
    deinit {
        stopAutoScroll()
    }
}

// MARK: - SetUp
private extension InstaGuideSectionCell {
    func setUp() {
        contentCollectionView.delegate = self
        contentCollectionView.dataSource = self
        
        contentCollectionView.register(
            InstaGuideChildSectionCell.self,
            forCellWithReuseIdentifier: InstaGuideChildSectionCell.identifiers
        )
        imageSection.currentPage
            .withUnretained(self)
            .subscribe { (owner, page) in
                owner.pageControl.currentPage = page
            }
            .disposed(by: disposeBag)
    }
    
    func setUpConstraints() {
        contentView.addSubview(contentCollectionView)
        contentCollectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(504)
        }
        
        contentView.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(contentCollectionView.snp.bottom)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        contentView.addSubview(stopButton)
        stopButton.snp.makeConstraints { make in
            make.size.equalTo(8)
            make.centerY.equalTo(pageControl.snp.centerY)
            make.leading.equalTo(pageControl.snp.trailing).offset(-36)
        }
    }
    
    func getSection() -> [any Sectionable] {
        return [imageSection]
    }
    
    func startAutoScroll(interval: TimeInterval = 3.0) {
        stopAutoScroll() // 기존 타이머를 중지
        isAutoBannerPlay = true
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.scrollToNextItem()
        }
    }

    // 자동 스크롤 중지 함수
    func stopAutoScroll() {
        isAutoBannerPlay = false
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }

    // 다음 배너로 스크롤
    private func scrollToNextItem() {

        let visibleIndexPaths = contentCollectionView.indexPathsForVisibleItems.sorted()
        guard let currentIndex = visibleIndexPaths.first else { return }

        let nextIndex = IndexPath(
            item: (currentIndex.item + 1) % imageSection.dataCount,
            section: currentIndex.section
        )

        contentCollectionView.scrollToItem(at: nextIndex, at: .centeredHorizontally, animated: true)
        pageControl.currentPage = nextIndex.item
    }
    
    func bind() {
        stopButton.rx.tap
            .withUnretained(self)
            .subscribe { (owner, _) in
                if owner.isAutoBannerPlay {
                    owner.stopAutoScroll()
                } else {
                    owner.startAutoScroll()
                }
            }
            .disposed(by: disposeBag)
    }
}

extension InstaGuideSectionCell: Inputable {
    struct Input {
        var imageList: [UIImage?]
        var title: [NSMutableAttributedString?]
    }
    
    func injection(with input: Input) {
        pageControl.numberOfPages = input.imageList.count
        let datas = zip(input.imageList, input.title).enumerated().map { $0 }
        imageSection.inputDataList = datas.map { .init(image: $0.element.0, title: $0.element.1, index: $0.offset)}
        contentCollectionView.reloadData()
        startAutoScroll()
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension InstaGuideSectionCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return getSection().count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getSection()[section].dataCount
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = getSection()[indexPath.section].getCell(collectionView: collectionView, indexPath: indexPath)
        return cell
    }
}
