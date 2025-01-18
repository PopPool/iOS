import UIKit
import ReactorKit
import RxCocoa
import RxSwift

final class MapSearchInput: UIView, View {
    // MARK: - Components
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

    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "팝업스토어명, 지역을 입력해보세요"
        textField.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        textField.clearButtonMode = .whileEditing
        textField.textColor = .g400  
        textField.isUserInteractionEnabled = true 
        textField.returnKeyType = .search // 검색 버튼으로 설정
        textField.enablesReturnKeyAutomatically = true // 텍스트가 입력되면 활성화

        return textField
        textField.attributedPlaceholder = NSAttributedString(
            string: "팝업스토어명, 지역을 입력해보세요",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.g400]
        )
        return textField
    
    }()

    private let tapButton = UIButton()

    var disposeBag = DisposeBag()

    // MARK: - Init
    init() {
        super.init(frame: .zero)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setBackgroundColorForList() {
        searchTextField.backgroundColor = .g50
    }
    

    func bind(reactor: MapReactor) {
        searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .withLatestFrom(searchTextField.rx.text.orEmpty)
            .bind { query in
                
                reactor.action.onNext(.searchTapped(query))
            }
            .disposed(by: disposeBag)


        searchTextField.rx.text.orEmpty
            .subscribe(onNext: { text in
                print("[DEBUG] TextField Input: \(text)")
            })
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.selectedLocationFilters }
            .distinctUntilChanged()
            .bind { [weak self] filters in
                self?.searchTextField.text = filters.first // 필터에 맞는 텍스트를 UI에 표시
            }
            .disposed(by: disposeBag)

        // 검색 버튼을 눌렀을 때
        tapButton.rx.tap
            .withLatestFrom(searchTextField.rx.text.orEmpty)
            .bind { [weak self] query in
                guard let self = self else { return }
                self.reactor?.action.onNext(.searchTapped(query))
            }
            .disposed(by: disposeBag)

    }
    
}

// MARK: - Setup
private extension MapSearchInput {
    func setupLayout() {
        addSubview(containerView)
        containerView.addSubview(searchIcon)
        containerView.addSubview(searchTextField)
//        containerView.addSubview(tapButton)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            // 높이 제약 조건 제거하여 부모 뷰의 높이에 맞춤
        }

        searchIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }

        searchTextField.snp.makeConstraints { make in
            make.leading.equalTo(searchIcon.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16) // 우측 여백을 추가해 텍스트가 오른쪽에 붙지 않도록
        }

//        tapButton.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
    }
}
