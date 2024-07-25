//
//  BlockedUserVC.swift
//  PopPool
//
//  Created by Porori on 7/23/24.
//

import UIKit
import SnapKit
import RxSwift

final class BlockedUserVC: UIViewController {
    
    let viewModel: BlockedUserVM
    let headerView = HeaderViewCPNT(title: "차단한 사용자 관리", style: .icon(nil))
    lazy var contentHeader = ListMenuCPNT(titleText: "총 \(viewModel.userData.blockedUserInfoList.count)건", style: .none)
    let topSpaceView = UIView()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.tableHeaderView = UIView(frame: .zero)
        table.tableFooterView = UIView(frame: .zero)
        table.register(BlockedUserCell.self,
            forCellReuseIdentifier: BlockedUserCell.reuseIdentifier)
        return table
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.addArrangedSubview(headerView)
        stack.addArrangedSubview(topSpaceView)
        stack.addArrangedSubview(contentHeader)
        return stack
    }()
    
    private let disposeBag = DisposeBag()
    
    init(viewModel: BlockedUserVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        setUpConstraints()
        bindViewModel()
    }
    
    private func bindViewModel() {
        let input = BlockedUserVM.Input(
            returnTap: headerView.leftBarButton.rx.tap
        )
        let output = viewModel.transform(input: input)
        
        // 테이블 뷰 연결
        output.userData
            .bind(to: tableView.rx.items(
                cellIdentifier: BlockedUserCell.reuseIdentifier,
                cellType: BlockedUserCell.self)
            ) { (row, element, cell) in
                print("열:", row)
                print("요소?/",element)
                print("셀?:", cell)
                cell.setStyle(title: element.instagramId,
                              subTitle: element.nickname,
                              style: .button("차단 완료"))
            }
            .disposed(by: disposeBag)
        
        // 리턴 버튼 연결
        output.returnTapped
            .withUnretained(self)
            .subscribe { (owner, _) in
                print("버튼이 눌렸습니다")
            }
            .disposed(by: disposeBag)
    }
    
    private func setUp() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = true
        headerView.rightBarButton.isHidden = true
        
        
    }
    
    private func setUpConstraints() {
        view.addSubview(stackView)
        view.addSubview(tableView)
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
        
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        topSpaceView.snp.makeConstraints { make in
            make.height.equalTo(12)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom)
            make.bottom.leading.trailing.equalToSuperview()
        }
    }
}

//extension BlockedUserVC: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let userList = viewModel.userData.blockedUserInfoList
//        return userList.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if let cell = tableView.dequeueReusableCell(withIdentifier: BlockedUserCell.reuseIdentifier,
//                                                 for: indexPath) as? BlockedUserCell {
//            let userList = viewModel.userData.blockedUserInfoList
//            cell.setStyle(title: userList[indexPath.row].instagramId,
//                          subTitle: userList[indexPath.row].nickname,
//                          style: .button("차단"))
//            return cell
//        }
//        return UITableViewCell()
//    }
//}
