import UIKit

import DesignSystem

import SnapKit

final class DetailView: UIView {

    // MARK: - Components
    let contentCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: .init())
        view.contentInsetAdjustmentBehavior = .never
        return view
    }()

    let commentPostButton: PPButton = {
        return PPButton(style: .primary, text: "코멘트 작성하기", disabledText: "코멘트 작성 완료")
    }()

    private let buttonTopView: UIView = {
        var view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 32)
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(1).cgColor
        ]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)  // 시작점
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)    // 끝점
        gradientLayer.bounds = view.bounds
        gradientLayer.position = view.center
        view.layer.addSublayer(gradientLayer)
        return view
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
private extension DetailView {

    func setUpConstraints() {
        self.addSubview(commentPostButton)
        commentPostButton.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }

        self.addSubview(contentCollectionView)
        contentCollectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(commentPostButton.snp.top)
        }

        self.addSubview(buttonTopView)
        buttonTopView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(commentPostButton.snp.top)
            make.height.equalTo(32)
        }
    }
}
