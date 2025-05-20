import DesignSystem
import DomainInterface
import Infrastructure
import PresentationInterface

public final class DetailFactoryImpl: DetailFactory {
    public init() { }

    public func make(popupID: Int) -> BaseViewController {
        let viewController = DetailController()
        let reactor = DetailReactor(
            popUpID: Int64(popupID),
            userAPIUseCase: DIContainer.resolve(UserAPIUseCase.self),
            popUpAPIUseCase: DIContainer.resolve(PopUpAPIUseCase.self),
            commentAPIUseCase: DIContainer.resolve(CommentAPIUseCase.self),
            preSignedUseCase: DIContainer.resolve(PreSignedUseCase.self)
        )

        viewController.reactor = reactor

        return viewController
    }
}
