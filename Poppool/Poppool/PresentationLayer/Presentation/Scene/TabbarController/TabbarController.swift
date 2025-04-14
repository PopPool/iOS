//
//  TabbarController.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/1/24.
//

import UIKit

class WaveTabBarController: UITabBarController, UITabBarControllerDelegate {

    private let waveLayer = CAShapeLayer()

    private let dotView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 0.6
        view.layer.borderColor = UIColor.white.cgColor
        view.backgroundColor = .blu500
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        addSomeTabItems()
        setUp()
        setupWaveTabBar()
        delegate = self
    }

    private func setupWaveTabBar() {
        // TabBar의 배경 투명 설정
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.isTranslucent = true

        // Wave Layer 설정
        waveLayer.fillColor = UIColor.white.cgColor
        tabBar.layer.insertSublayer(waveLayer, at: 0)

        // Dot 설정
        dotView.frame.size = CGSize(width: 12, height: 12)
        dotView.layer.cornerRadius = 6
        tabBar.addSubview(dotView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateWavePath()
        updateDotPosition(animated: false)
        updateItem()
    }

    private func updateItem() {
        let tabBarItemViews = tabBar.subviews.filter { $0.isUserInteractionEnabled }

        if selectedIndex < tabBarItemViews.count {
            let selectedView = tabBarItemViews[selectedIndex]

            // 애니메이션 적용
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: .transitionCrossDissolve,
                animations: { [weak self] in
                    guard let self = self else { return }
                    for (index, otherView) in tabBarItemViews.enumerated() {
                        if index != selectedIndex { otherView.transform = .identity }
                    }
                    selectedView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                }
            )
        }
    }

    private func updateWavePath(animated: Bool = false) {
        guard let items = tabBar.items else { return }
        let tabWidth = tabBar.bounds.width / CGFloat(items.count)
        let selectedTabX = CGFloat(selectedIndex) * tabWidth
        let waveHeight: CGFloat = 12
        let waveWidth: CGFloat = 24
        let leftPoint = selectedTabX + tabWidth / 2 - waveWidth / 2
        let cornerRadius: CGFloat = 12  // 둥근 코너 반지름
        let newPath = UIBezierPath()

        // 시작점 - 왼쪽 둥근 부분
        newPath.move(to: CGPoint(x: 0, y: -waveHeight))
        newPath.addArc(
            withCenter: CGPoint(x: cornerRadius, y: -waveHeight + cornerRadius),
            radius: cornerRadius,
            startAngle: .pi, // 왼쪽 상단 180도
            endAngle: .pi * 1.5, // 왼쪽 하단 270도
            clockwise: true
        )

        // 왼쪽 끝과 중앙을 부드럽게 연결 (라운드 처리)
        newPath.addLine(to: CGPoint(x: leftPoint, y: -waveHeight))
        newPath.addArc(
            withCenter: CGPoint(x: selectedTabX + tabWidth / 2, y: -waveHeight),
            radius: 12,
            startAngle: .pi, // 왼쪽 180도
            endAngle: .pi * 2, // 오른쪽 0도
            clockwise: false
        )

        // 오른쪽 끝과 중앙을 부드럽게 연결 (라운드 처리)
        newPath.addLine(to: CGPoint(x: tabBar.bounds.width - cornerRadius, y: -waveHeight))

        // 오른쪽 둥근 부분
        newPath.addArc(
            withCenter: CGPoint(x: tabBar.bounds.width - cornerRadius, y: -waveHeight + cornerRadius),
            radius: cornerRadius,
            startAngle: .pi * 1.5, // 오른쪽 하단 270도
            endAngle: 0, // 오른쪽 상단 0도
            clockwise: true
        )

        // TabBar 하단을 덮는 직선
        newPath.addLine(to: CGPoint(x: tabBar.bounds.width, y: tabBar.bounds.height))
        newPath.addLine(to: CGPoint(x: 0, y: tabBar.bounds.height))
        newPath.close()

        if animated {
            let transition = CATransition()
            transition.type = .fade
            transition.duration = 0.3
            waveLayer.add(transition, forKey: "dissolveAnimation")
        }
        waveLayer.path = newPath.cgPath

        // 그림자 설정
        waveLayer.shadowColor = UIColor.black.cgColor
        waveLayer.shadowOpacity = 0.25 // 그림자의 투명도
        waveLayer.shadowOffset = CGSize(width: 0, height: 4) // 그림자의 위치
        waveLayer.shadowRadius = 6 // 그림자의 흐림 정도
        waveLayer.masksToBounds = false
    }

    private func updateDotPosition(animated: Bool) {
        guard let items = tabBar.items else { return }
        let tabWidth = tabBar.bounds.width / CGFloat(items.count)
        let selectedTabX = CGFloat(selectedIndex) * tabWidth

        let targetCenter = CGPoint(
            x: selectedTabX + tabWidth / 2,
            y: -12
        )

        if animated {
            UIView.animate(withDuration: 1,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0.3,
                           options: .curveEaseInOut,
                           animations: {
                self.dotView.center = targetCenter
            })
        } else {
            dotView.center = targetCenter
        }
    }

    // 탭 선택 시 애니메이션 적용
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        updateWavePath(animated: true)
        updateDotPosition(animated: true)
        updateItem()
    }

    func setUp() {
        self.selectedIndex = 1
        self.tabBar.barTintColor = .g200
        self.tabBar.tintColor = .blu500
    }

    func resizeImage(image: UIImage?, targetSize: CGSize) -> UIImage? {
        guard let image = image else { return nil }
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        let scaleFactor = min(widthRatio, heightRatio)

        let scaledImageSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)

        UIGraphicsBeginImageContextWithOptions(scaledImageSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: scaledImageSize))

        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }

    func addSomeTabItems() {
        let provider = ProviderImpl()

        let mapController = MapViewController()
        let mapUseCase = MapUseCaseImpl(repository: MapRepositoryImpl(provider: provider))
        let directionRepository = MapDirectionRepositoryImpl(provider: provider)
        mapController.reactor = MapReactor(useCase: mapUseCase, directionRepository: directionRepository)

        let homeController = HomeController()
        homeController.reactor = HomeReactor()

        let myPageController = MyPageController()
        myPageController.reactor = MyPageReactor()

        let iconSize = CGSize(width: 32, height: 32)
        // 탭바 아이템 생성
        mapController.tabBarItem = UITabBarItem(
            title: "지도",
            image: resizeImage(image: UIImage(named: "icon_tabbar_map"), targetSize: iconSize),
            selectedImage: resizeImage(image: UIImage(named: "icon_tabbar_map"), targetSize: iconSize)
        )
        homeController.tabBarItem = UITabBarItem(
            title: "홈",
            image: resizeImage(image: UIImage(named: "icon_tabbar_home"), targetSize: iconSize),
            selectedImage: resizeImage(image: UIImage(named: "icon_tabbar_home"), targetSize: iconSize)
        )
        myPageController.tabBarItem = UITabBarItem(
            title: "마이",
            image: resizeImage(image: UIImage(named: "icon_tabbar_menu"), targetSize: iconSize),
            selectedImage: resizeImage(image: UIImage(named: "icon_tabbar_menu"), targetSize: iconSize)
        )

        // 네비게이션 컨트롤러 설정
        let map = UINavigationController(rootViewController: mapController)
        let home = UINavigationController(rootViewController: homeController)
        let myPage = UINavigationController(rootViewController: myPageController)

        viewControllers = [map, home, myPage]

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2  // 기본 값보다 높은 라인 간격을 설정

        // 폰트 설정
        let appearance = UITabBarAppearance()
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .font: UIFont.korFont(style: .medium, size: 11)!,
            .paragraphStyle: paragraphStyle
        ]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .font: UIFont.korFont(style: .bold, size: 11)!,
            .paragraphStyle: paragraphStyle
        ]

        let verticalOffset: CGFloat = 4 // 원하는 간격 (양수: 아래로 이동, 음수: 위로 이동)
        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: verticalOffset)
        appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: verticalOffset)

        tabBar.standardAppearance = appearance
    }

}
