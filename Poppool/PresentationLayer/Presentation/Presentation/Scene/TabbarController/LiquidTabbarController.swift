import UIKit

import DomainInterface
import Infrastructure
import SearchFeatureInterface

class LiquidTabbarController: UITabBarController, UITabBarControllerDelegate {

	override func viewDidLoad() {
		super.viewDidLoad()

		self.delegate = self
		self.setupTabBarItems()
		self.setupTabBarParagraphs()
		self.configureUI()
	}
}

// MARK: - SetUp
private extension LiquidTabbarController {

	func configureUI() {
		self.selectedIndex = 1
		self.tabBar.tintColor = .blu500
		self.tabBarMinimizeBehavior = .onScrollDown
		self.navigationItem.searchBarPlacementAllowsToolbarIntegration = true
	}

	func setupTabBarItems() {
		let mapVC = MapViewController()
		mapVC.reactor = MapReactor(
			mapUseCase: DIContainer.resolve(MapUseCase.self),
			mapDirectionRepository: DIContainer.resolve(MapDirectionRepository.self)
		)

		let homeVC = HomeController()
		homeVC.reactor = HomeReactor(
			userAPIUseCase: DIContainer.resolve(UserAPIUseCase.self),
			homeAPIUseCase: DIContainer.resolve(HomeAPIUseCase.self)
		)

		let myPageVC = MyPageController()
		myPageVC.reactor = MyPageReactor(userAPIUseCase: DIContainer.resolve(UserAPIUseCase.self))

		// 네비게이션 컨트롤러 설정
		self.viewControllers = [
			tabBarItemInjected(mapVC, type: .map),
			tabBarItemInjected(homeVC, type: .home),
			tabBarItemInjected(myPageVC, type: .myPage)
		]

		@Dependency var searchFactory: PopupSearchFactory
		let searchVC = UINavigationController(rootViewController: searchFactory.make())
		searchVC.tabBarItem = UITabBarItem(
			tabBarSystemItem: .search,
			tag: 3
		)
		self.viewControllers!.append(searchVC)
	}

	func setupTabBarParagraphs() {
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineHeightMultiple = 1.2  // 기본 값보다 높은 라인 간격을 설정

		// 폰트 설정
		let appearance = UITabBarAppearance()
		appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
			.font: UIFont.PPFont(style: .KOm11),
			.paragraphStyle: paragraphStyle
		]
		appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
			.font: UIFont.PPFont(style: .KOb11),
			.paragraphStyle: paragraphStyle
		]

		self.tabBar.standardAppearance = appearance
	}

	func tabBarItemInjected(_ viewController: UIViewController, type: TabType) -> UIViewController {
		let viewController = UINavigationController(rootViewController: viewController)
		viewController.tabBarItem = UITabBarItem(
			title: type.title,
			image: resizedImage(image: UIImage(named: type.iconName)),
			tag: type.rawValue
		)

		return viewController
	}

	func resizedImage(image: UIImage?, targetSize: CGSize = CGSize(width: 32, height: 32)) -> UIImage? {
		guard let image = image else { return nil }
		let size = image.size

		let widthRatio  = targetSize.width  / size.width
		let heightRatio = targetSize.height / size.height

		let scaleFactor = min(widthRatio, heightRatio)

		let scaledImageSize = CGSize(
			width: size.width * scaleFactor,
			height: size.height * scaleFactor
		)

		UIGraphicsBeginImageContextWithOptions(scaledImageSize, false, 0.0)
		image.draw(in: CGRect(origin: .zero, size: scaledImageSize))

		let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return resizedImage
	}
}

private enum TabType: Int {
	case map = 0
	case home = 1
	case myPage = 2

	var title: String {
		switch self {
		case .map: return "지도"
		case .home: return "홈"
		case .myPage: return "마이"
		}
	}

	var iconName: String {
		switch self {
		case .map: return "icon_tabbar_map"
		case .home: return "icon_tabbar_map"
		case .myPage: return "icon_tabbar_home"
		}
	}
}
