import UIKit

import DomainInterface
import Infrastructure
import SearchFeatureInterface

class LiquidTabbarController: UITabBarController, UITabBarControllerDelegate {

	override func viewDidLoad() {
		super.viewDidLoad()

		self.delegate = self
		self.configureUI()
		self.addSomeTabItems()
	}
}

// MARK: - SetUp
private extension LiquidTabbarController {

	func configureUI() {
		self.selectedIndex = 1
		self.tabBar.tintColor = .blu500
		tabBarController?.tabBarMinimizeBehavior = .onScrollDown
	}

	func addSomeTabItems() {
		let mapController = MapViewController()

		mapController.reactor = MapReactor(
			mapUseCase: DIContainer.resolve(MapUseCase.self),
			mapDirectionRepository: DIContainer.resolve(MapDirectionRepository.self)
		)

		let homeController = HomeController()
		homeController.reactor = HomeReactor(
			userAPIUseCase: DIContainer.resolve(UserAPIUseCase.self),
			homeAPIUseCase: DIContainer.resolve(HomeAPIUseCase.self)
		)

		let myPageController = MyPageController()
		myPageController.reactor = MyPageReactor(userAPIUseCase: DIContainer.resolve(UserAPIUseCase.self))

		@Dependency var popupSearchFactory: PopupSearchFactory
		let popupSearchVC = popupSearchFactory.make()

		let iconSize = CGSize(width: 32, height: 32)
		// 탭바 아이템 생성
		mapController.tabBarItem = UITabBarItem(
			title: "지도",
			image: resizeImage(
				image: UIImage(named: "icon_tabbar_map"),
				targetSize: iconSize
			),
			selectedImage: resizeImage(
				image: UIImage(named: "icon_tabbar_map"),
				targetSize: iconSize
			)
		)
		homeController.tabBarItem = UITabBarItem(
			title: "홈",
			image: resizeImage(
				image: UIImage(named: "icon_tabbar_home"),
				targetSize: iconSize
			),
			selectedImage: resizeImage(
				image: UIImage(named: "icon_tabbar_home"),
				targetSize: iconSize
			)
		)
		myPageController.tabBarItem = UITabBarItem(
			title: "마이",
			image: resizeImage(
				image: UIImage(named: "icon_tabbar_menu"),
				targetSize: iconSize
			),
			selectedImage: resizeImage(
				image: UIImage(named: "icon_tabbar_menu"),
				targetSize: iconSize
			)
		)
		popupSearchVC.tabBarItem = UITabBarItem(
			tabBarSystemItem: .search,
			tag: 3
		)

		// 네비게이션 컨트롤러 설정
		let map = UINavigationController(rootViewController: mapController)
		let home = UINavigationController(rootViewController: homeController)
		let myPage = UINavigationController(rootViewController: myPageController)
		let search = UINavigationController(rootViewController: popupSearchVC)

		viewControllers = [map, home, myPage, search]

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

		tabBar.standardAppearance = appearance
	}
}

// MARK: - Utils
private extension LiquidTabbarController {

	func resizeImage(image: UIImage?, targetSize: CGSize) -> UIImage? {
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
