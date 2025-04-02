import SnapKit
import UIKit

final class LocationPermissionBottomSheet: UIViewController {

    var onDismiss: (() -> Void)?
    var onGoToSettings: (() -> Void)?

    // 제목 라벨
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "내 위치를 중심으로\n보기 위한 준비가 필요해요"
        label.font = UIFont.KorFont(style: .bold, size: 18)
        label.textColor = .g1000
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    // 설명 라벨
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "설정 > 위치 권한을 허용하신 후에\n내 주변의 다양한 팝업스토어를 볼 수 있어요."
        label.font = UIFont.KorFont(style: .regular, size: 14)
        label.textColor = .g600
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    // 취소 버튼
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.g600, for: .normal)
        button.titleLabel?.font = UIFont.KorFont(style: .medium, size: 16)
        button.backgroundColor = .g50
        button.layer.cornerRadius = 10
        return button
    }()

    // 권한 설정 버튼
    private let settingsButton: UIButton = {
        let button = UIButton()
        button.setTitle("권한설정", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.KorFont(style: .medium, size: 16)
        button.backgroundColor = .blu500
        button.layer.cornerRadius = 10
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupActions()
    }

    private func setupView() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 20

        let buttonStackView = UIStackView(arrangedSubviews: [cancelButton, settingsButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 12
        buttonStackView.distribution = .fillEqually

        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(buttonStackView)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(didTapSettings), for: .touchUpInside)
    }

    @objc private func didTapCancel() {
        dismiss(animated: true, completion: onDismiss)
    }

    @objc private func didTapSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
        dismiss(animated: true, completion: onGoToSettings)
    }
}
