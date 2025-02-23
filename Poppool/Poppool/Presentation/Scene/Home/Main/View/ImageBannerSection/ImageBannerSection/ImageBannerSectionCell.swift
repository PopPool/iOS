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

    var disposeBag = DisposeBag()
    
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
    
    let playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_banner_playButton"), for: .normal)
        return button
    }()
    
    private var isAutoBannerPlay: Bool = false
    private var isFirstResponseAutoScroll: Bool = true
    
    var imageSection = ImageBannerChildSection(inputDataList: [])
    
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
    
    let bannerTapped: PublishSubject<Int> = .init()
    
    private var currentIndex: Int = 1
    private var stopButtonLeadingConstraints: Constraint?
    private var playButtonLeadingConstraints: Constraint?
    private var isHiddenPauseButton: Bool = true
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        isFirstResponseAutoScroll = false
    }
    
    // 자동 스크롤 중지 함수
    func stopAutoScroll() {
        stopButton.isHidden = true
        playButton.isHidden = false
        isAutoBannerPlay = false
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    func startAutoScroll(interval: TimeInterval = 3.0) {
        stopAutoScroll() // 기존 타이머를 중지
        stopButton.isHidden = false
        playButton.isHidden = true
        isAutoBannerPlay = true
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.contentCollectionView.scrollToItem(
                at: .init(row: self.currentIndex + 1, section: 0),
                at: .centeredHorizontally, animated: true
            )
        }
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
            stopButtonLeadingConstraints =  make.leading.equalTo(pageControl.snp.trailing).offset(-40).constraint
        }
        
        contentView.addSubview(playButton)
        playButton.snp.makeConstraints { make in
            make.size.equalTo(6)
            make.centerY.equalTo(pageControl)
            playButtonLeadingConstraints =  make.leading.equalTo(pageControl.snp.trailing).offset(-40).constraint
        }
    }
    
    func getSection() -> [any Sectionable] {
        return [imageSection]
    }
    
    private func findViewController() -> BaseViewController? {
        var nextResponder = self.next
        while nextResponder != nil {
            if let vc = nextResponder as? BaseViewController {
                return vc
            }
            nextResponder = nextResponder?.next
        }
        return nil
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
        
        playButton.rx.tap
            .withUnretained(self)
            .subscribe { (owner, _) in
                if owner.isAutoBannerPlay {
                    owner.stopAutoScroll()
                } else {
                    owner.startAutoScroll()
                }
            }
            .disposed(by: disposeBag)
        
        imageSection.currentPage
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe { (owner, index) in
                var index = index
                owner.currentIndex = index
                if index == 0 { index = 1 }
                if index == owner.imageSection.dataCount - 1 { index = owner.imageSection.dataCount - 2 }
                owner.pageControl.currentPage = index - 1
            }
            .disposed(by: disposeBag)
    }
}

extension ImageBannerSectionCell: Inputable {
    struct Input {
        var imagePaths: [String]
        var idList: [Int64]
        var isHiddenPauseButton: Bool = false
    }
    
    func injection(with input: Input) {
        if imageSection.isEmpty {
            pageControl.numberOfPages = input.imagePaths.count
            if #available(iOS 18.3, *) {
                let stopButtonLeadingOffset = -26
                stopButtonLeadingConstraints?.update(offset: stopButtonLeadingOffset)
                playButtonLeadingConstraints?.update(offset: stopButtonLeadingOffset)
            } else {
                let stopButtonLeadingOffset = input.imagePaths.count == 3 ? -40 : input.imagePaths.count == 2 ? -36 : 0
                stopButtonLeadingConstraints?.update(offset: stopButtonLeadingOffset)
                playButtonLeadingConstraints?.update(offset: stopButtonLeadingOffset)
            }
            let datas = zip(input.imagePaths, input.idList)
            let backContents = datas.suffix(1)
            let frontContents = datas.prefix(1)
            imageSection.inputDataList = datas.map { .init(imagePath: $0.0, id: $0.1) }
            imageSection.inputDataList.append(contentsOf: frontContents.map { .init(imagePath: $0.0, id: $0.1) })
            imageSection.inputDataList = backContents.map {.init(imagePath: $0.0, id: $0.1) } + imageSection.inputDataList
            DispatchQueue.main.async { [weak self] in
                self?.contentCollectionView.scrollToItem(
                    at: .init(row: 1, section: 0),
                    at: .centeredHorizontally, animated: false
                )
            }
        }
        
        contentCollectionView.reloadData()
        isHiddenPauseButton = input.isHiddenPauseButton
        if isFirstResponseAutoScroll {
            startAutoScroll()
            isFirstResponseAutoScroll = false
        }
        
        if input.isHiddenPauseButton {
            stopAutoScroll()
            stopButton.isHidden = true
            playButton.isHidden = true
        }
        
        bind()
        
        if input.imagePaths.count == 1 {
            playButton.isHidden = true
            stopButton.isHidden = true
            pageControl.isHidden = true
        }
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        bannerTapped.onNext(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if currentIndex == 0 {
            contentCollectionView.scrollToItem(
                at: .init(row: imageSection.dataCount - 2, section: 0),
                at: .centeredHorizontally, animated: false
            )
        }
        if currentIndex == imageSection.dataCount - 1 {
            contentCollectionView.scrollToItem(
                at: .init(row: 1, section: 0),
                at: .centeredHorizontally, animated: false
            )
        }
        if !isHiddenPauseButton {
            startAutoScroll()
        }
        
    }
}
