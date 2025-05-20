import CoreLocation
import UIKit

import Data
import Domain
import DomainInterface
import Infrastructure
import Presentation
import PresentationInterface
import SearchFeature
import SearchFeatureInterface

import KakaoSDKCommon
import NMapsMap

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        KakaoSDK.initSDK(appKey: Secrets.kakaoAuthAppKey)
        NMFAuthManager.shared().clientId = Secrets.naverMapClientID

        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()

        self.registerDependencies()
        self.registerFactory()

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
        DIContainer.register(UserDefaultService.self) { return UserDefaultService() }
        DIContainer.register(KeyChainService.self) { return KeyChainService() }

        // MARK: Resolve service
        @Dependency var provider: Provider
        @Dependency var userDefaultService: UserDefaultService

        // MARK: Register repository
        DIContainer.register(MapRepository.self) { return MapRepositoryImpl(provider: provider) }
        DIContainer.register(AdminRepository.self) { return AdminRepositoryImpl(provider: provider) }
        DIContainer.register(UserAPIRepository.self) { return UserAPIRepositoryImpl(provider: provider) }
        DIContainer.register(PopUpAPIRepository.self) { return PopUpAPIRepositoryImpl(provider: provider) }
        DIContainer.register(CommentAPIRepository.self) { return CommentAPIRepositoryImpl(provider: provider) }
        DIContainer.register(HomeAPIRepository.self) { return HomeAPIRepositoryImpl(provider: provider) }
        DIContainer.register(AuthAPIRepository.self) { return AuthAPIRepositoryImpl(provider: provider) }
        DIContainer.register(SignUpRepository.self) { return SignUpRepositoryImpl(provider: provider) }
        DIContainer.register(MapDirectionRepository.self) { return MapDirectionRepositoryImpl(provider: provider) }
        DIContainer.register(PreSignedRepository.self) { return PreSignedRepositoryImpl() }
        DIContainer.register(KakaoLoginRepository.self) { return KakaoLoginRepositoryImpl() }
        DIContainer.register(AppleLoginRepository.self) { return AppleLoginRepositoryImpl() }
        DIContainer.register(CategoryRepository.self) { return CategoryRepositoryImpl(provider: provider) }
        DIContainer.register(SearchAPIRepository.self) { return SearchAPIRepositoryImpl(provider: provider, userDefaultService: userDefaultService) }

        // MARK: Resolve repository
        @Dependency var mapRepository: MapRepository
        @Dependency var adminRepository: AdminRepository
        @Dependency var userAPIRepository: UserAPIRepository
        @Dependency var popUpAPIRepository: PopUpAPIRepository
        @Dependency var commentAPIRepository: CommentAPIRepository
        @Dependency var homeAPIRepository: HomeAPIRepository
        @Dependency var authAPIRepository: AuthAPIRepository
        @Dependency var signUpRepository: SignUpRepository
        @Dependency var preSignedRepository: PreSignedRepository
        @Dependency var kakaoLoginRepository: KakaoLoginRepository
        @Dependency var appleLoginRepository: AppleLoginRepository
        @Dependency var categoryRepository: CategoryRepository
        @Dependency var searchAPIRepository: SearchAPIRepository

        // MARK: Register UseCase
        DIContainer.register(MapUseCase.self) { return MapUseCaseImpl(repository: mapRepository) }
        DIContainer.register(AdminUseCase.self) { return AdminUseCaseImpl(repository: adminRepository) }
        DIContainer.register(UserAPIUseCase.self) { return UserAPIUseCaseImpl(repository: userAPIRepository) }
        DIContainer.register(PopUpAPIUseCase.self) { return PopUpAPIUseCaseImpl(repository: popUpAPIRepository) }
        DIContainer.register(CommentAPIUseCase.self) { return CommentAPIUseCaseImpl(repository: commentAPIRepository) }
        DIContainer.register(HomeAPIUseCase.self) { return HomeAPIUseCaseImpl(repository: homeAPIRepository) }
        DIContainer.register(AuthAPIUseCase.self) { return AuthAPIUseCaseImpl(repository: authAPIRepository) }
        DIContainer.register(SignUpAPIUseCase.self) { return SignUpAPIUseCaseImpl(repository: signUpRepository) }
        DIContainer.register(PreSignedUseCase.self) { return PreSignedUseCaseImpl(repository: preSignedRepository) }
        DIContainer.register(KakaoLoginUseCase.self) { return KakaoLoginUseCaseImpl(repository: kakaoLoginRepository) }
        DIContainer.register(AppleLoginUseCase.self) { return AppleLoginUseCaseImpl(repository: appleLoginRepository) }
        DIContainer.register(FetchCategoryListUseCase.self) { return FetchCategoryListUseCaseImpl(repository: categoryRepository) }
        DIContainer.register(FetchKeywordBasePopupListUseCase.self) { return FetchKeywordBasePopupListUseCaseImpl(repository: searchAPIRepository) }
    }

    private func registerFactory() {
        DIContainer.register(PopupSearchFactory.self) { return PopupSearchFactoryImpl() }
        DIContainer.register(DetailFactory.self) { return DetailFactoryImpl() }
        DIContainer.register(CategorySelectorFactory.self) { return CategorySelectorFactoryImpl() }
        DIContainer.register(FilterSelectorFactory.self) { return FilterSelectorFactoryImpl() }
    }
}
