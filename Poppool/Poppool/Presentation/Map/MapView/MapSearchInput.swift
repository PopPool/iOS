import ReactorKit
import RxCocoa
import RxSwift
import UIKit

final class MapSearchInput: UIView, View {
    // MARK: - Components
    var onSearch: ((String) -> Void)?
    var disposeBag = DisposeBag()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        return view
    }()

    private let searchIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "icon_search_gray")?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = .g400
        return iv
    }()

    let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "팝업스토어명, 지역을 입력해보세요"
        textField.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        textField.clearButtonMode = .whileEditing
        textField.textColor = .g400
        textField.returnKeyType = .search
        textField.enablesReturnKeyAutomatically = true
        textField.attributedPlaceholder = NSAttributedString(
            string: "팝업스토어명, 지역을 입력해보세요",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.g400]
        )
        // 편집은 하지 않고, 탭으로 화면 전환을 유도
        textField.isEnabled = false
        return textField
    }()

    // MARK: - Init
    init() {
        super.init(frame: .zero)
        setupLayout()
        setupActions()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods
    func setLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    func setBackgroundColorForList() {
        searchTextField.backgroundColor = .g50
    }

    func bind(reactor: MapReactor) {
        // 텍스트필드 입력 로그 (필요 시 확인)
        searchTextField.rx.text.orEmpty
            .subscribe(onNext: { text in
                print("[DEBUG] TextField Input: \(text)")
            })
            .disposed(by: disposeBag)

        // Reactor의 선택된 위치 필터를 텍스트필드에 바인딩 (없으면 기본 문구)
        reactor.state
            .map { $0.selectedLocationFilters.first ?? "팝업스토어명을 입력해보세요" }
            .distinctUntilChanged()
            .bind(to: searchTextField.rx.text)
            .disposed(by: disposeBag)
    }

    func setBackgroundColor(_ color: UIColor) {
        containerView.backgroundColor = color
    }

    // MARK: - Gesture Setup
    private func setupGesture() {
        // containerView에 탭 제스처를 추가하여 화면 전환 트리거
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
    }

    @objc private func handleTapGesture() {
        // onSearch 클로저를 호출해서 화면 전환을 진행
        onSearch?(searchTextField.text ?? "")
    }
}

// MARK: - Setup Layout and Actions
private extension MapSearchInput {
    func setupLayout() {
        addSubview(containerView)
        containerView.addSubview(searchIcon)
        containerView.addSubview(searchTextField)
        containerView.addSubview(activityIndicator)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        searchIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }

        searchTextField.snp.makeConstraints { make in
            make.leading.equalTo(searchIcon.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
        }

        activityIndicator.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }

    func setupActions() {
        // 텍스트필드에서 엔터(검색) 이벤트 발생 시 onSearch 클로저 호출 (필요 시 사용)
        searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .withLatestFrom(searchTextField.rx.text.orEmpty)
            .subscribe(onNext: { [weak self] query in
                self?.onSearch?(query)
            })
            .disposed(by: disposeBag)
    }
}
