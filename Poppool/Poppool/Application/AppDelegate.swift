import CoreLocation
import KakaoSDKCommon
import NMapsMap
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        KakaoSDK.initSDK(appKey: Secrets.kakaoAuthAppKey)
        NMFAuthManager.shared().clientId = Secrets.naverMapClientID

        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()

        self.registerDependencies()

        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

// MARK: - Dependency
extension AppDelegate {
    /// 의존성 등록을 위한 메서드
    private func registerDependencies() {
        // MARK: Register Service
        DIContainer.register(Provider.self) { return ProviderImpl() }
        DIContainer.register(KeyChainService.self) { return KeyChainService() }

        // MARK: Resolve service
        @Dependency var provider: Provider

        // MARK: Register repository
        DIContainer.register(MapRepository.self) { return MapRepositoryImpl(provider: provider) }
        DIContainer.register(AdminRepository.self) { return AdminRepositoryImpl(provider: provider) }
        DIContainer.register(UserAPIRepository.self) { return UserAPIRepositoryImpl(provider: provider) }

        // MARK: Resolve repository
        @Dependency var mapRepository: MapRepository
        @Dependency var adminRepository: AdminRepository
        @Dependency var userAPIRepository: UserAPIRepository

        // MARK: Register UseCase
        DIContainer.register(MapUseCase.self) { return MapUseCaseImpl(repository: mapRepository) }
        DIContainer.register(AdminUseCase.self) { return AdminUseCaseImpl(repository: adminRepository) }
        DIContainer.register(UserAPIUseCase.self) { return UserAPIUseCaseImpl(repository: userAPIRepository) }
    }
}
