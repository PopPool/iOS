//
//  MyPageProfileSectionCell.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/31/24.
//

import UIKit

import RxSwift
import SnapKit

final class MyPageProfileSectionCell: UICollectionViewCell {

    // MARK: - Components

    private let backGroundTrailingView: UIView = {
        return UIView()
    }()

    private let backGroundImageView: UIImageView = {
        return UIImageView()
    }()

    lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        return UIVisualEffectView(effect: blurEffect)
    }()

    private let profileView: UIView = {
        return UIView()
    }()

    private let profileImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 32
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()

    private let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .w100
        return view
    }()

    let nickNameLabel: UILabel = {
        return UILabel()
    }()

    private let descriptionLabel: UILabel = {
        return UILabel()
    }()

    private let bottomHoleView: UIView = {
        let view = UIView()
        view.backgroundColor = .w100
        view.alpha = 0
        return view
    }()

    private let loginView: UIView = {
        return UIView()
    }()

    private let loginLabel: PPLabel = {
        let label = PPLabel(style: .bold, fontSize: 18, text: "나에게 딱 맞는\n팝업스토어 만나러 가기")
        label.textColor = .w100
        label.numberOfLines = 2
        return label
    }()

    let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("로그인/회원가입", for: .normal)
        button.backgroundColor = .w10
        button.titleLabel?.font = .korFont(style: .medium, size: 13)
        button.setTitleColor(.w100, for: .normal)
        button.layer.cornerRadius = 4
        return button
    }()

    var disposeBag = DisposeBag()
    // MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpConstraints()
        addHolesToCell()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    var cellHeight: Constraint?
    var containerTopInset: Constraint?

    var isBright: PublishSubject<Bool> = .init()
}

// MARK: - SetUp
private extension MyPageProfileSectionCell {
    func setUpConstraints() {
        contentView.clipsToBounds = true
        contentView.addSubview(backGroundTrailingView)
        backGroundTrailingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            cellHeight = make.height.equalTo(162 + 49 + 44).priority(.high).constraint
        }

        backGroundTrailingView.addSubview(backGroundImageView)
        backGroundImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.size.equalTo(UIScreen.main.bounds.width)
        }

        backGroundTrailingView.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        backGroundTrailingView.addSubview(profileView)
        profileView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(162)
            containerTopInset = make.top.equalToSuperview().constraint
        }

        backGroundTrailingView.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(49)
        }

        backGroundTrailingView.addSubview(loginView)
        loginView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(162)
            make.bottom.equalTo(bottomView.snp.top)
        }

        profileView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(64)
            make.top.equalToSuperview().inset(17)
            make.leading.equalToSuperview().inset(20)
        }

        profileView.addSubview(nickNameLabel)
        nickNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView)
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
        }

        profileView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(25)
            make.leading.equalToSuperview().inset(20)
        }

        contentView.addSubview(bottomHoleView)
        bottomHoleView.snp.makeConstraints { make in
            make.edges.equalTo(bottomView)
        }

        contentView.addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.width.equalTo(120)
            make.height.equalTo(32)
            make.bottom.equalToSuperview().inset(97)
            make.leading.equalToSuperview().inset(20)
        }

        contentView.addSubview(loginLabel)
        loginLabel.snp.makeConstraints { make in
            make.bottom.equalTo(loginButton.snp.top).offset(-16)
            make.leading.equalToSuperview().inset(20)
        }
    }

    private func addHolesToCell() {
        // 전체 영역 경로
        let fullPath = UIBezierPath(rect: bounds)

        // 왼쪽 아래와 오른쪽 아래 구멍을 뚫을 위치 설정 (이미지뷰의 frame 위치 고려)
        let holeCenter = CGPoint(x: bounds.maxX / 2, y: bounds.minY)

        // 구멍을 만드는 경로 생성 (반지름 6)
        let holePath = UIBezierPath(arcCenter: holeCenter, radius: 12, startAngle: 0, endAngle: .pi, clockwise: true)

        // 구멍 경로를 전체 경로에서 빼기
        fullPath.append(holePath)

        // 기존에 구멍을 뚫을 경로를 추가하는 레이어
        let holeLayer = CAShapeLayer()
        holeLayer.path = fullPath.cgPath
        holeLayer.fillRule = .evenOdd

        // 구멍을 추가하는 서브 레이어로 삽입
        bottomView.layer.mask = holeLayer
    }
}

extension MyPageProfileSectionCell: Inputable {
    struct Input {
        var isLogin: Bool
        var profileImagePath: String?
        var nickName: String?
        var description: String?
    }

    func injection(with input: Input) {
        if input.isLogin {
            profileView.isHidden = false
            loginView.isHidden = true
            loginLabel.isHidden = true
            loginButton.isHidden = true
            blurView.isHidden = false
            nickNameLabel.setLineHeightText(text: input.nickName, font: .korFont(style: .bold, size: 16))
            descriptionLabel.setLineHeightText(text: input.description ?? "", font: .korFont(style: .light, size: 11))
            backGroundImageView.image = nil
            backGroundImageView.setPPImage(path: input.profileImagePath)
            profileImageView.setPPImage(path: input.profileImagePath) { [weak self] in
                guard let self = self,
                      let isBright = self.profileImageView.image?.isBright() else { return }
                self.isBright.onNext(isBright)
                if isBright {
                    nickNameLabel.textColor = .g1000
                    descriptionLabel.textColor = .g1000
                } else {
                    nickNameLabel.textColor = .w100
                    descriptionLabel.textColor = .w100
                }
            }

        } else {
            backGroundImageView.image = nil
            backGroundImageView.backgroundColor = .g1000
            profileView.isHidden = true
            loginView.isHidden = false
            loginLabel.isHidden = false
            loginButton.isHidden = false
            blurView.isHidden = true

        }
    }

    func updateHeight(height: CGFloat) {
        cellHeight?.update(offset: height)
        layoutIfNeeded()
    }

    func updateAlpha(alpha: CGFloat) {
        bottomHoleView.alpha = alpha
    }

    func updateContentTopInset(inset: CGFloat) {
        containerTopInset?.update(offset: inset)
    }
}
