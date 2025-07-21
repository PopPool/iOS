import UIKit

import Data
import Domain
import DomainInterface
import Infrastructure
import LoginFeature
import LoginFeatureInterface
import PresentationInterface
import PresentationTesting

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        self.registerDependencies()
        self.registerFactory()

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

extension AppDelegate {
    private func registerDependencies() {
        // MARK: Register Service
        DIContainer.register(Provider.self) { return ProviderImpl() }
        DIContainer.register(UserDefaultService.self) { return UserDefaultService() }
        DIContainer.register(KeyChainService.self) { return KeyChainService() }

        // MARK: Resolve service
        @Dependency var provider: Provider

        // MARK: Register repository
        DIContainer.register(AuthAPIRepository.self) { return AuthAPIRepositoryImpl(provider: provider) }
        DIContainer.register(KakaoLoginRepository.self) { return KakaoLoginRepositoryImpl() }
        DIContainer.register(AppleLoginRepository.self) { return AppleLoginRepositoryImpl() }

        // MARK: Resolve repository
        @Dependency var authAPIRepository: AuthAPIRepository
        @Dependency var kakaoLoginRepository: KakaoLoginRepository
        @Dependency var appleLoginRepository: AppleLoginRepository

        // MARK: Register UseCase
        DIContainer.register(AuthAPIUseCase.self) { return AuthAPIUseCaseImpl(repository: authAPIRepository) }
        DIContainer.register(KakaoLoginUseCase.self) { return KakaoLoginUseCaseImpl(repository: kakaoLoginRepository) }
        DIContainer.register(AppleLoginUseCase.self) { return AppleLoginUseCaseImpl(repository: appleLoginRepository) }
    }

    private func registerFactory() {
        DIContainer.register(LoginFactory.self) { return LoginFactoryImpl() }
        DIContainer.register(SignUpFactory.self) { return SignUpFactoryMock() }
        DIContainer.register(WaveTabbarFactory.self) { return WaveTabbarFactoryMock() }
        DIContainer.register(FAQFactory.self) { return FAQFactoryMock() }
    }
}
