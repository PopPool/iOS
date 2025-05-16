import UIKit

import DesignSystem

import SnapKit

final class CommentDetailView: UIView {

    // MARK: - Components
    let profileView: DetailCommentProfileView = {
        let view = DetailCommentProfileView()
        view.button.isHidden = true
        return view
    }()

    let likeButton: UIButton = {
        return UIButton()
    }()

    let likeButtonTitleLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 13, text: "도움돼요")
        label.textColor = .g400
        return label
    }()

    let likeButtonImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_like_gray")
        return view
    }()

    let contentCollectionView: UICollectionView = {
        return UICollectionView(frame: .zero, collectionViewLayout: .init())
    }()

    // MARK: - init
    init() {
        super.init(frame: .zero)
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SetUp
private extension CommentDetailView {

    func setUpConstraints() {
        self.addSubview(profileView)
        profileView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(40)
        }

        likeButton.addSubview(likeButtonTitleLabel)
        likeButtonTitleLabel.snp.makeConstraints { make in
            make.height.equalTo(20).priority(.high)
            make.top.bottom.trailing.equalToSuperview()
        }

        likeButton.addSubview(likeButtonImageView)
        likeButtonImageView.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.leading.centerY.equalToSuperview()
            make.trailing.equalTo(likeButtonTitleLabel.snp.leading)
        }

        self.addSubview(likeButton)
        likeButton.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().inset(20)
        }

        self.addSubview(contentCollectionView)
        contentCollectionView.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom).offset(16)
            make.bottom.equalTo(likeButton.snp.top).offset(-20)
            make.leading.trailing.equalToSuperview()
        }
    }
}
