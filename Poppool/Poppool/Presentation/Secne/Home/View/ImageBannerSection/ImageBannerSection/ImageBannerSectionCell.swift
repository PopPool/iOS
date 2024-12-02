//
//  ImageBannerSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/28/24.
//

import UIKit

import SnapKit
import RxSwift

final class ImageBannerSectionCell: UICollectionViewCell {
    
    // MARK: - Components

    let disposeBag = DisposeBag()
    
    private var autoScrollTimer: Timer?
    
    private lazy var contentCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
        view.contentInsetAdjustmentBehavior = .never
        return view
    }()
    
    var pageControl: UIPageControl = {
        let controller = UIPageControl()
        controller.currentPage = 0
        controller.preferredIndicatorImage = UIImage(systemName: "circle")
        controller.preferredCurrentPageIndicatorImage = UIImage(systemName: "circle.fill")
        controller.isUserInteractionEnabled = false
        return controller
    }()
    
    let stopButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_banner_stopButton"), for: .normal)
        return button
    }()
    
    private var isAutoBannerPlay: Bool = false
    
    private var imageSection = ImageBannerChildSection(inputDataList: [])
    
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
    
    private let imageService = PreSignedService()
    
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
private extension ImageBannerSectionCell {
    func setUp() {
        contentCollectionView.delegate = self
        contentCollectionView.dataSource = self
        
        contentCollectionView.register(
            ImageBannerChildSectionCell.self,
            forCellWithReuseIdentifier: ImageBannerChildSectionCell.identifiers
        )
        pageControl.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
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
            make.edges.equalToSuperview()
        }
        contentView.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(4)
            make.bottom.equalToSuperview().inset(24)
        }
        contentView.addSubview(stopButton)
        stopButton.snp.makeConstraints { make in
            make.size.equalTo(6)
            make.centerY.equalTo(pageControl)
            make.leading.equalTo(pageControl.snp.trailing).offset(-40)
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

extension ImageBannerSectionCell: Inputable {
    struct Input {
        var imagePaths: [String]
        var idList: [Int64]
    }
    
    func injection(with input: Input) {
        pageControl.numberOfPages = input.imagePaths.count
        imageService.tryDownload(filePaths: input.imagePaths)
            .subscribe { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let images):
                    let datas = zip(images, input.idList)
                    self.imageSection.inputDataList = datas.map { .init(image: $0.0, id: $0.1) }
                    self.contentCollectionView.reloadData()
                    self.startAutoScroll()
                case .failure:
                    Logger.log(message: "Image Downlaod Fail", category: .error)
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension ImageBannerSectionCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
