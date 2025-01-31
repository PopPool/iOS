//
//  AddCommentSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/15/24.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class AddCommentSectionCell: UICollectionViewCell {
    
    // MARK: - Components
    
    var disposeBag = DisposeBag()
    
    let commentTextView: UITextView = {
        let view = UITextView()
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.font = .KorFont(style: .medium, size: 14)
        return view
    }()
    
    let countLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 12)
        label.textColor = .g500
        return label
    }()
    
    private let placeHolderLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 14, text: "최소 10자 이상 입력해주세요")
        label.textColor = .g200
        return label
    }()
    
    private let noticeLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 12, text: "최대 500자까지 입력해주세요")
        label.textColor = .re500
        label.isHidden = true
        return label
    }()
    
    private var isActiveComment: Bool = false
    
    private var commentState: BehaviorRelay<CommentState> = .init(value: .empty)
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpConstraints()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        bind()
    }
}

// MARK: - SetUp
private extension AddCommentSectionCell {
    func bind() {
        
        commentTextView.rx.didBeginEditing
            .withUnretained(self)
            .subscribe { (owner, _) in
                owner.isActiveComment = true
                owner.commentState.accept(owner.checkValidation(text: owner.commentTextView.text))
            }
            .disposed(by: disposeBag)
        
        commentTextView.rx.didEndEditing
            .withUnretained(self)
            .subscribe { (owner, _) in
                owner.isActiveComment = false
                owner.commentState.accept(owner.checkValidation(text: owner.commentTextView.text))
            }
            .disposed(by: disposeBag)
        
        commentTextView.rx.didChange
            .debounce(.milliseconds(5), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .subscribe { (owner, _) in
                owner.commentState.accept(owner.checkValidation(text: owner.commentTextView.text))
            }
            .disposed(by: disposeBag)
        
        commentState
            .withUnretained(self)
            .subscribe { (owner, state) in
                let text = owner.commentTextView.text ?? ""
                owner.countLabel.text = "\(text.count) / 500자"
                owner.placeHolderLabel.isHidden = state.isHiddenPlaceHolder
                owner.noticeLabel.isHidden = state.isHiddenNoticeLabel
                owner.contentView.layer.borderColor = state.borderColor?.cgColor
                owner.countLabel.textColor = state.countLabelColor
                owner.commentTextView.textColor = state.textColor
            }
            .disposed(by: disposeBag)
    }
    
    func setUpConstraints() {
        contentView.layer.cornerRadius = 4
        contentView.clipsToBounds = true
        contentView.layer.borderColor = UIColor.g100.cgColor
        contentView.layer.borderWidth = 1
        contentView.backgroundColor = .w100
        contentView.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(16)
        }
        contentView.addSubview(commentTextView)
        commentTextView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(countLabel.snp.top).offset(-4)
        }
        contentView.addSubview(placeHolderLabel)
        placeHolderLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }
        contentView.addSubview(noticeLabel)
        noticeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    func checkValidation(text: String?) -> CommentState {
        guard let text = text else { return .empty }
        if text.isEmpty {
            return isActiveComment ? .emptyActive : .empty
        }
        
        switch text.count {
        case 1...9:
            return isActiveComment ? .shortLengthActive : .shortLength
        case 10...500:
            return isActiveComment ? .normalActive : .normal
        default:
            return isActiveComment ? .longLengthActive : .longLength
        }
    }
}

extension AddCommentSectionCell: Inputable {
    struct Input {
    }
    
    func injection(with input: Input) {
    }
}

enum CommentState {
    case empty
    case emptyActive
    case shortLength
    case shortLengthActive
    case longLength
    case longLengthActive
    case normal
    case normalActive
    
    var borderColor: UIColor? {
        switch self {
        case .shortLength, .longLength, .longLengthActive:
            return .re500
        default:
            return .g100
        }
    }
    
    var countLabelColor: UIColor? {
        switch self {
        case .shortLength, .longLength, .longLengthActive:
            return .re500
        default:
            return .g500
        }
    }
    
    var textColor: UIColor? {
        switch self {
        case .shortLength, .longLength, .longLengthActive:
            return .re500
        default:
            return .g1000
        }
    }
    
    var description: String? {
        switch self {
        case .longLength, .longLengthActive:
            return "최대 500자까지 입력해주세요"
        case .shortLength:
            return "최소 10자 이상 입력해주세요"
        default:
            return nil
        }
    }
    
    var isHiddenNoticeLabel: Bool {
        switch self {
        case .longLength, .longLengthActive, .shortLength:
            return false
        default:
            return true
        }
    }
    
    var isHiddenPlaceHolder: Bool {
        switch self {
        case .empty, .emptyActive:
            return false
        default:
            return true
        }
    }
}
