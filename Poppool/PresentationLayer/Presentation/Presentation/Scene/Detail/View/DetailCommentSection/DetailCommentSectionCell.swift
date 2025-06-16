import UIKit

import DesignSystem

import RxSwift
import SnapKit

final class DetailCommentSectionCell: UICollectionViewCell {

    // MARK: - Components
    private let contentStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.spacing = 16
        return view
    }()

    let profileView: DetailCommentProfileView = {
        return DetailCommentProfileView()
    }()

    let imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: 80, height: 80)
        layout.sectionInset = .init(top: 0, left: 20, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsHorizontalScrollIndicator = false
        return view
    }()

    private let contentLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 13)
        label.numberOfLines = 3
        return label
    }()

    let totalViewButton: UIButton = {
        return UIButton()
    }()

    private let buttonTitleLabel: PPLabel = {
        let label = PPLabel(style: .medium, fontSize: 13, text: "코멘트 전체보기")
        label.textColor = .g600
        return label
    }()

    private let buttonImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_right_black")
        return view
    }()

    let likeButton: UIButton = {
        return UIButton()
    }()

    private let likeButtonTitleLabel: PPLabel = {
        let label = PPLabel(style: .regular, fontSize: 13, text: "도움돼요")
        label.textColor = .g400
        return label
    }()

    private let likeButtonImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_like_gray")
        return view
    }()

    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .g100
        return view
    }()

    private let blurBackGroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }()
    private let blurView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = false
        return view
    }()

    var disposeBag = DisposeBag()

    private let loginStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.spacing = 16
        return view
    }()

    private let loginNoticelabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()

    let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("로그인하고 후기보기", for: .normal)
        button.titleLabel?.font = .korFont(style: .medium, size: 13)
        button.setTitleColor(.w100, for: .normal)
        button.layer.cornerRadius = 4
        button.backgroundColor = .blu500
        return button
    }()

    private var imagePathList: [String?] = []
    // MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}

// MARK: - SetUp
private extension DetailCommentSectionCell {
    func setUpConstraints() {

        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.register(DetailCommentImageCell.self, forCellWithReuseIdentifier: DetailCommentImageCell.identifiers)

        totalViewButton.addSubview(buttonTitleLabel)
        buttonTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.height.equalTo(20).priority(.high)
        }
        totalViewButton.addSubview(buttonImageView)
        buttonImageView.snp.makeConstraints { make in
            make.size.equalTo(14).priority(.high)
            make.trailing.equalToSuperview()
            make.leading.equalTo(buttonTitleLabel.snp.trailing)
            make.centerY.equalToSuperview()
        }

        profileView.snp.makeConstraints { make in
            make.width.equalTo(contentView.bounds.width - 40).priority(.high)
        }
        imageCollectionView.snp.makeConstraints { make in
            make.height.equalTo(80).priority(.high)
            make.width.equalTo(contentView.bounds.width).priority(.high)
        }
        contentLabel.snp.makeConstraints { make in
            make.width.equalTo(contentView.bounds.width - 40).priority(.high)
        }
        contentStackView.addArrangedSubview(profileView)
        contentStackView.addArrangedSubview(imageCollectionView)
        contentStackView.addArrangedSubview(contentLabel)
        contentStackView.addArrangedSubview(totalViewButton)

        contentView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.trailing.equalToSuperview()
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

        contentView.addSubview(likeButton)
        likeButton.snp.makeConstraints { make in
            make.top.equalTo(contentStackView.snp.bottom).offset(16)
            make.trailing.equalToSuperview().inset(20)
        }

        contentView.addSubview(borderView)
        borderView.snp.makeConstraints { make in
            make.top.equalTo(likeButton.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(1).priority(.high)
            make.bottom.equalToSuperview()
        }

        contentView.addSubview(blurBackGroundView)
        blurBackGroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.addSubview(loginStackView)
        loginStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        loginButton.snp.makeConstraints { make in
            make.height.equalTo(32)
            make.width.equalTo(141)
        }
        loginStackView.addArrangedSubview(loginNoticelabel)
        loginStackView.addArrangedSubview(loginButton)
    }

    private func blur() {
        layoutIfNeeded()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let bounds = self.bounds
            UIGraphicsBeginImageContext(contentView.bounds.size)
            contentView.layer.render(in: UIGraphicsGetCurrentContext()!)
            guard let image = UIGraphicsGetImageFromCurrentImageContext(), let blurFilter = CIFilter(name: "CIGaussianBlur") else {
                UIGraphicsEndImageContext()
                return
            }
            UIGraphicsEndImageContext()

            blurFilter.setDefaults()

            blurFilter.setValue(CIImage(image: image), forKey: kCIInputImageKey)
            blurFilter.setValue(8, forKey: kCIInputRadiusKey)

            var convertedImage: UIImage?
            let context = CIContext(options: nil)
            if let blurOutputImage = blurFilter.outputImage,
                let cgImage = context.createCGImage(blurOutputImage, from: blurOutputImage.extent) {
                convertedImage = UIImage(cgImage: cgImage)
            }
            blurView.image = convertedImage
            blurBackGroundView.isHidden = false
        }
    }
}

extension DetailCommentSectionCell: Inputable {
    struct Input {
        var commentID: Int64
        var nickName: String?
        var profileImagePath: String?
        var date: String?
        var comment: String?
        var imageList: [String?]
        var imageIDList: [Int64]
        var isLike: Bool
        var likeCount: Int64
        var isLogin: Bool
        var title: String?
        var creator: String?
        var isMyComment: Bool
        var isLastCell: Bool = false
    }

    func injection(with input: Input) {

        let comment = input.comment ?? ""
        profileView.profileImageView.setPPImage(path: input.profileImagePath)
        profileView.nickNameLabel.setLineHeightText(text: input.nickName, font: .korFont(style: .bold, size: 13))
        profileView.dateLabel.setLineHeightText(text: input.date, font: .korFont(style: .regular, size: 12))
        contentLabel.setLineHeightText(text: input.comment, font: .korFont(style: .regular, size: 13))
        likeButtonTitleLabel.setLineHeightText(text: "도움돼요 \(input.likeCount)", font: .korFont(style: .regular, size: 13))
        if input.isLike {
            likeButtonImageView.image = UIImage(named: "icon_like_blue")
            likeButtonTitleLabel.textColor = .blu500
        } else {
            likeButtonImageView.image = UIImage(named: "icon_like_gray")
            likeButtonTitleLabel.textColor = .g400
        }
        if comment.count > 78 {
            totalViewButton.isHidden = false
        } else {
            totalViewButton.isHidden = true
        }
        if input.imageList.isEmpty {
            imageCollectionView.isHidden = true
        } else {
            imageCollectionView.isHidden = false
            imagePathList = input.imageList
        }

        imageCollectionView.reloadData()
        if input.isLogin {
            blurBackGroundView.isHidden = true
            loginStackView.isHidden = true
            blurView.isHidden = true
        } else {
            loginStackView.isHidden = false
            blurView.isHidden = false
            if blurView.image == nil { blur() }
        }
        let title = input.title ?? ""
        let fullText = "\(title)를 다녀온 팝풀인들의 생생한 후기가 궁금하다면?"

        // "팝업스토어명"과 "생생한 후기" 부분의 NSRange 설정
        let popupStoreRange = (fullText as NSString).range(of: title)
        let reviewRange = (fullText as NSString).range(of: "생생한 후기")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.4

        // 기본 스타일 (폰트, 색상 등)
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.korFont(style: .regular, size: 14),
            .foregroundColor: UIColor.g1000,
            .paragraphStyle: paragraphStyle
        ]

        // 스타일을 다르게 할 부분 (팝업스토어명, 생생한 후기)
        let popupStoreAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.korFont(style: .bold, size: 14),  // 다른 폰트 스타일
            .foregroundColor: UIColor.blu500,  // 다른 색상
            .paragraphStyle: paragraphStyle
        ]

        let reviewAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.korFont(style: .bold, size: 14),  // 이탤릭체
            .foregroundColor: UIColor.g1000,  // 다른 색상
            .paragraphStyle: paragraphStyle
        ]

        // NSAttributedString 생성
        let attributedString = NSMutableAttributedString(string: fullText, attributes: normalAttributes)
        attributedString.addAttributes(popupStoreAttributes, range: popupStoreRange)
        attributedString.addAttributes(reviewAttributes, range: reviewRange)

        loginNoticelabel.attributedText = attributedString
        loginNoticelabel.textAlignment = .center
        loginNoticelabel.lineBreakStrategy = .hangulWordPriority
        loginNoticelabel.numberOfLines = 0

        borderView.isHidden = input.isLastCell
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension DetailCommentSectionCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagePathList.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailCommentImageCell.identifiers, for: indexPath) as? DetailCommentImageCell else {
            return UICollectionViewCell()
        }
        cell.injection(with: .init(imagePath: imagePathList[indexPath.row]))
        return cell
    }
}
