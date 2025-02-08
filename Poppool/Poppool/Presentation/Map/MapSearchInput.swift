import UIKit
import ReactorKit
import RxCocoa
import RxSwift

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
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
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
        return textField
    }()

    // MARK: - Init
    init() {
        super.init(frame: .zero)
        setupLayout()
        setupActions()
        searchTextField.isEnabled = false


    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods
    func setLoading(_ isLoading: Bool) {
        searchTextField.isEnabled = !isLoading
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
        // 엔터 키로 검색 실행
        searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .withLatestFrom(searchTextField.rx.text.orEmpty)
            .bind { query in
                reactor.action.onNext(.searchTapped(query))
            }
            .disposed(by: disposeBag)

        // 텍스트 입력 로그
        searchTextField.rx.text.orEmpty
            .subscribe(onNext: { text in
                print("[DEBUG] TextField Input: \(text)")
            })
            .disposed(by: disposeBag)

        // 선택된 필터를 검색창에 반영
        reactor.state
            .map { $0.selectedLocationFilters.first }
            .distinctUntilChanged()
            .bind(to: searchTextField.rx.text)
            .disposed(by: disposeBag)
    }
    func setBackgroundColor(_ color: UIColor) {
        containerView.backgroundColor = color
    }
    private func setupGesture() {
        // 전체 뷰에 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }


}

// MARK: - Setup
private extension MapSearchInput {
    func setupLayout() {
        addSubview(containerView)
        containerView.addSubview(searchIcon)
        containerView.addSubview(searchTextField)

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
    }

    func setupActions() {
        // 텍스트 필드 액션 설정
        searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .withLatestFrom(searchTextField.rx.text.orEmpty)
            .subscribe(onNext: { [weak self] query in
                self?.onSearch?(query)
            })
            .disposed(by: disposeBag)
    }
}
