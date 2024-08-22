//
//  EntirePopupVC.swift
//  PopPool
//
//  Created by Porori on 8/11/24.
//

import UIKit
import RxSwift
import SnapKit

final class EntirePopupVC: BaseViewController {
    
    private let header: HeaderViewCPNT = HeaderViewCPNT(title: "큐레이션 팝업 전체보기",
                                                        style: .icon(nil))
    
    private let entirePopUpCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = (UIScreen.main.bounds.width - 56) / 2
        let height: CGFloat = 251
        layout.itemSize = .init(width: width, height: height)
        layout.minimumLineSpacing = 24
        layout.minimumInteritemSpacing = 16
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.contentInset = .init(top: 24, left: 20, bottom: 0, right: 20)
        view.backgroundColor = .g50
        view.isUserInteractionEnabled = true
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    private let viewModel: EntirePopupVM
    let disposeBag = DisposeBag()
    
    init(viewModel: EntirePopupVM) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        setUpConstraint()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func bind() {
        header.leftBarButton.rx.tap
            .subscribe(onNext: {
                print("버튼이 눌렸습니다.")
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func setUp() {
        header.rightBarButton.isHidden = true
        entirePopUpCollectionView.backgroundColor = .systemBackground
        entirePopUpCollectionView.delegate = self
        entirePopUpCollectionView.dataSource = self
        entirePopUpCollectionView.register(HomeDetailPopUpCell.self,
                                           forCellWithReuseIdentifier: HomeDetailPopUpCell.identifier)
    }
    
    private func setUpConstraint() {
        view.addSubview(header)
        view.addSubview(entirePopUpCollectionView)
        
        header.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        entirePopUpCollectionView.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension EntirePopupVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeDetailPopUpCell.identifier, for: indexPath) as? HomeDetailPopUpCell else { return UICollectionViewCell() }
        cell.injectionWith(input: .init(image: UIImage(systemName: "photo"), category: "#카테고리", title: "팝업스토어명팝업스토어명팝업스토어명팝업스토어명팝업스토어명팝업스토어명팝업스토어명팝업스토어명", location: "서울시 송파구", date: "2024.08.11"))
        return cell
    }
}
