import UIKit

import DesignSystem
import DomainInterface
import Infrastructure
import LoginFeatureInterface
import PresentationInterface

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

public final class SplashController: BaseViewController {

    // MARK: - Properties
    var disposeBag = DisposeBag()

    private var mainView = SplashView()
    // //FIXME: Reactor 태워서 UseCase 처리하도록 수정
    @Dependency private var authAPIUseCase: AuthAPIUseCase
    @Dependency private var keyChainService: KeyChainService

    private var rootViewController: UIViewController?
}

// MARK: - Life Cycle
extension SplashController {
    public override func viewDidLoad() {
        super.viewDidLoad()

		self.addViews()
		self.setupConstraints()
		self.configureUI()

        setRootview()
        playAnimation()
    }
}

// MARK: - SetUp
private extension SplashController {

	func addViews() {
		[mainView].forEach {
			view.addSubview($0)
		}
	}

	func setupConstraints() {
		mainView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}
	}

	func configureUI() {
		view.backgroundColor = .blu500
	}

    func playAnimation() {
        mainView.animationView.play { [weak self] _ in
			Task { @MainActor in
				try? await Task.sleep(nanoseconds: .seconds(0.1))
				self?.changeRootView()
			}
        }
    }

    func setRootview() {
        authAPIUseCase.postTokenReissue()
            .withUnretained(self)
            .subscribe(
                onNext: { (owner, response) in
                    let newAccessToken = response.accessToken ?? ""
                    let newRefreshToken = response.refreshToken ?? ""
					owner.keyChainService.saveToken(
						type: .accessToken,
						value: newAccessToken
					)
					owner.keyChainService.saveToken(
						type: .refreshToken,
						value: newRefreshToken
					)
                    @Dependency var factory: WaveTabbarFactory
                    owner.rootViewController = factory.make()
                },
                onError: { [weak self] _ in
                    guard let self = self else { return }
                    @Dependency var factory: LoginFactory
                    let loginNavigationController = UINavigationController(
						rootViewController: factory.make(
							.main,
							text: "간편하게 SNS 로그인하고\n팝풀 서비스를 이용해보세요"
						)
                    )
                rootViewController = loginNavigationController
            })
            .disposed(by: disposeBag)
    }

    func changeRootView() {
        view.window?.rootViewController = rootViewController
        view.window?.makeKeyAndVisible()
    }
}

