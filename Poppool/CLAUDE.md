# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PopPool is an iOS application built with Swift, following Clean Architecture principles with four distinct layers. The app helps users discover and interact with pop-up stores, featuring map integration, search functionality, and user authentication.

## Build and Development Commands

### Building the Project
```bash
# Open workspace (required - do not use .xcodeproj)
open Poppool.xcworkspace

# Build from command line
xcodebuild -workspace Poppool.xcworkspace -scheme Poppool -configuration Debug build

# Clean build folder
xcodebuild -workspace Poppool.xcworkspace -scheme Poppool clean
```

### Running Tests
```bash
# Run all tests
xcodebuild test -workspace Poppool.xcworkspace -scheme Poppool -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test
xcodebuild test -workspace Poppool.xcworkspace -scheme Poppool -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:PoppoolTests/YourTestClass/testMethod
```

### Code Quality
```bash
# Run SwiftLint
swiftlint lint

# Auto-fix SwiftLint issues
swiftlint --fix

# SwiftLint with custom config
swiftlint lint --config .swiftlint.yml
```

### Deployment
```bash
# Install fastlane dependencies
bundle install

# Deploy to TestFlight
bundle exec fastlane beta
```

## Architecture

### Layer Structure

The codebase follows **Clean Architecture** with strict unidirectional dependencies:

```
Presentation Layer (UI & Features)
    ↓ depends on
Domain Layer (Business Logic & Interfaces)
    ↓ implemented by
Data Layer (Network & Data Sources)
    ↓ uses
Core Layer (Infrastructure & Utilities)
```

**Key Principle:** Lower layers NEVER depend on higher layers.

### CoreLayer (`/CoreLayer`)
**Purpose:** Cross-cutting infrastructure and utilities

- **DIContainer:** Custom dependency injection container with type-safe registration/resolution
- **Provider:** Network abstraction layer (Alamofire-based)
- **Services:** UserDefaultService, KeyChainService, Logger, ImageLoader
- All other layers depend on CoreLayer, but CoreLayer depends on nothing

### DomainLayer (`/DomainLayer`)
**Purpose:** Business logic and protocol definitions

Structure:
- `DomainInterface/Repository/` - Repository protocol definitions (data access contracts)
- `DomainInterface/UseCase/` - UseCase protocol definitions (business logic contracts)
- `DomainInterface/Entity/` - Domain models (DTO transformations from Data layer)
- `Domain/UseCaseImpl/` - UseCase implementations

Key patterns:
- All async operations return `Observable<T>` (RxSwift)
- Protocol-first design for testability
- UseCases delegate to Repositories for data access
- Zero platform-specific code

### DataLayer (`/DataLayer`)
**Purpose:** External data source integration

Structure:
- `Network/API/{Feature}API/` - Feature-specific API endpoints and DTOs
- `Network/EndPoint/` - Endpoint definitions
- `Network/Interceptor/` - Token management for authenticated requests
- `RepositoryImpl/` - Implementation of Domain layer Repository protocols

Key patterns:
- **DTO Pattern:** All API responses use DTOs that transform to domain models via `.toDomain()`
- **Endpoint Pattern:** Encapsulates request details (URL, method, parameters)
- **Repository Implementation:** Implements Domain protocols, calls Provider, transforms DTOs

### PresentationLayer (`/PresentationLayer`)
**Purpose:** UI components and feature modules

Structure:
- `DesignSystem/` - Shared UI components (BaseViewController, etc.)
- `Presentation/` - Main app screens and navigation
- `{Feature}Feature/` - Self-contained feature modules (SearchFeature, LoginFeature)

Each feature module contains:
- `{Feature}FeatureInterface/` - Public API (Factory protocols)
- `{Feature}Feature/` - Implementation (Reactors, ViewControllers, Views)
- `{Feature}FeatureDemo/` - Isolated demo app for testing

Key patterns:
- **MVVM + ReactorKit:** Unidirectional data flow (Action → Mutation → State)
- **Factory Pattern:** Feature composition with protocol-based factories
- **Module Pattern:** Features are isolated with their own .xcodeproj files
- **Reactive Binding:** ViewControllers bind to Reactor state using RxSwift

## Dependency Injection

### Registration (AppDelegate.swift:40-110)

All dependencies are registered in `AppDelegate.registerDependencies()` and `AppDelegate.registerFactory()`:

```swift
// 1. Register Services (CoreLayer)
DIContainer.register(Provider.self) { ProviderImpl() }

// 2. Register Repositories (DataLayer)
DIContainer.register(SearchAPIRepository.self) {
    SearchAPIRepositoryImpl(provider: provider, userDefaultService: userDefaultService)
}

// 3. Register UseCases (DomainLayer)
DIContainer.register(FetchKeywordBasePopupListUseCase.self) {
    FetchKeywordBasePopupListUseCaseImpl(repository: searchAPIRepository)
}

// 4. Register Factories (PresentationLayer)
DIContainer.register(PopupSearchFactory.self) { PopupSearchFactoryImpl() }
```

### Resolution

Use the `@Dependency` property wrapper for automatic injection:

```swift
final class MyReactor: Reactor {
    @Dependency var searchUseCase: FetchKeywordBasePopupListUseCase

    // Alternatively, resolve explicitly:
    let useCase: MyUseCase = DIContainer.resolve(MyUseCase.self)
}
```

## Adding New Features

Follow this pattern when implementing new features:

### 1. Domain Layer (Contracts)

Create protocols in `DomainLayer/Domain/DomainInterface/`:

```swift
// Repository/{FeatureName}Repository.swift
public protocol MyFeatureRepository {
    func fetchData(id: String) -> Observable<MyFeatureResponse>
}

// UseCase/{FeatureName}UseCase.swift
public protocol MyFeatureUseCase {
    func execute(id: String) -> Observable<MyFeatureResponse>
}

// Entity/{FeatureName}Response.swift
public struct MyFeatureResponse {
    let id: String
    let name: String
}
```

Create implementation in `DomainLayer/Domain/Domain/UseCaseImpl/`:

```swift
public final class MyFeatureUseCaseImpl: MyFeatureUseCase {
    private let repository: MyFeatureRepository

    public init(repository: MyFeatureRepository) {
        self.repository = repository
    }

    public func execute(id: String) -> Observable<MyFeatureResponse> {
        return repository.fetchData(id: id)
    }
}
```

### 2. Data Layer (Implementation)

Create API structure in `DataLayer/Data/Data/Network/API/MyFeatureAPI/`:

```swift
// RequestDTO/MyFeatureRequestDTO.swift
struct MyFeatureRequestDTO: Encodable {
    let id: String
}

// ResponseDTO/MyFeatureResponseDTO.swift
struct MyFeatureResponseDTO: Decodable {
    let id: String
    let name: String

    func toDomain() -> MyFeatureResponse {
        return MyFeatureResponse(id: id, name: name)
    }
}

// MyFeatureEndPoint.swift
struct MyFeatureEndPoint {
    static func getData(request: MyFeatureRequestDTO) -> Endpoint<MyFeatureResponseDTO> {
        return Endpoint(
            baseURL: Secrets.popPoolBaseURL,
            path: "/api/myfeature",
            method: .get,
            queryParameters: request
        )
    }
}
```

Create repository implementation in `DataLayer/Data/Data/RepositoryImpl/`:

```swift
public final class MyFeatureRepositoryImpl: MyFeatureRepository {
    private let provider: Provider

    public init(provider: Provider) {
        self.provider = provider
    }

    public func fetchData(id: String) -> Observable<MyFeatureResponse> {
        let request = MyFeatureRequestDTO(id: id)
        let endpoint = MyFeatureEndPoint.getData(request: request)

        return provider.requestData(with: endpoint)
            .map { $0.toDomain() }
    }
}
```

### 3. Presentation Layer (UI)

Create feature module in `PresentationLayer/{Feature}Feature/`:

```swift
// {Feature}FeatureInterface/Factory/MyFeatureFactory.swift
public protocol MyFeatureFactory {
    func make() -> BaseViewController
}

// {Feature}Feature/Reactor/MyFeatureReactor.swift
public final class MyFeatureReactor: Reactor {
    @Dependency var myFeatureUseCase: MyFeatureUseCase

    public enum Action {
        case viewDidLoad
        case buttonTapped(id: String)
    }

    public enum Mutation {
        case setData(MyFeatureResponse)
        case setLoading(Bool)
    }

    public struct State {
        var data: MyFeatureResponse?
        var isLoading: Bool = false
    }

    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .just(.setLoading(true))
        case .buttonTapped(let id):
            return myFeatureUseCase.execute(id: id)
                .map { Mutation.setData($0) }
        }
    }

    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setData(let data):
            newState.data = data
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        }
        return newState
    }
}

// {Feature}Feature/View/MyFeatureViewController.swift
final class MyFeatureViewController: BaseViewController, View {
    typealias Reactor = MyFeatureReactor
    var disposeBag = DisposeBag()

    func bind(reactor: Reactor) {
        // Bind actions
        rx.viewDidLoad
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Bind state
        reactor.state.map { $0.data }
            .bind(to: /* your UI */)
            .disposed(by: disposeBag)
    }
}

// {Feature}Feature/Factory/MyFeatureFactoryImpl.swift
public final class MyFeatureFactoryImpl: MyFeatureFactory {
    public func make() -> BaseViewController {
        let viewController = MyFeatureViewController()
        viewController.reactor = MyFeatureReactor()
        return viewController
    }
}
```

### 4. Register Dependencies

Add to `AppDelegate.swift`:

```swift
private func registerDependencies() {
    // ... existing registrations ...

    // Register Repository
    DIContainer.register(MyFeatureRepository.self) {
        MyFeatureRepositoryImpl(provider: provider)
    }

    // Register UseCase
    DIContainer.register(MyFeatureUseCase.self) {
        MyFeatureUseCaseImpl(repository: myFeatureRepository)
    }
}

private func registerFactory() {
    // ... existing registrations ...

    // Register Factory
    DIContainer.register(MyFeatureFactory.self) {
        MyFeatureFactoryImpl()
    }
}
```

## Key Technologies

### Core Dependencies (Swift Package Manager)
- **RxSwift 6.9.0** - Reactive programming
- **ReactorKit 3.2.0** - Unidirectional architecture for MVVM
- **Alamofire 5.10.2** - Networking
- **SnapKit 5.7.1** - Auto Layout DSL
- **NMapsMap 3.21.0** - Naver Maps SDK
- **KakaoSDK 2.24.0** - Kakao login integration
- **Tabman 3.2.0** - Tab bar management
- **PanModal 1.2.7** - Modal presentation
- **Pageboy 4.2.0** - Page view controller

### Development Tools
- **SwiftLint** - Code style enforcement (config: `.swiftlint.yml`)
- **Fastlane** - Automated deployment to TestFlight

## ReactorKit Pattern

ViewControllers follow the ReactorKit pattern with strict unidirectional data flow:

### Action → Mutation → State Flow

1. **Action:** User interactions (button taps, text input)
2. **Mutation:** State change events (often async)
3. **State:** Single source of truth for UI

### Example
```swift
// User taps button
button.rx.tap
    .map { Reactor.Action.buttonTapped }
    .bind(to: reactor.action)

// Reactor processes action → mutation
func mutate(action: Action) -> Observable<Mutation> {
    case .buttonTapped:
        return useCase.execute()
            .map { Mutation.setData($0) }
}

// Reactor reduces mutation → new state
func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    case .setData(let data):
        newState.data = data
    return newState
}

// View binds to state
reactor.state.map { $0.data }
    .bind(to: label.rx.text)
```

### @Pulse for One-Time Events
Use `@Pulse` for events that shouldn't replay (navigation, alerts):

```swift
struct State {
    @Pulse var presentTarget: PresentTarget?
}

// Binding with distinctUntilChanged for Pulse
reactor.pulse(\.$presentTarget)
    .compactMap { $0 }
    .bind(to: /* navigation handler */)
```

## Authentication

### Token Management
- Access tokens managed via `KeyChainService`
- `TokenInterceptor` (DataLayer) automatically injects tokens into requests
- Refresh logic handled in interceptor

### Login Flow
1. User selects Kakao/Apple login
2. `LoginReactor` calls `KakaoLoginUseCase` or `AppleLoginUseCase`
3. Repository handles OAuth flow, receives tokens
4. Tokens stored in KeyChain via `AuthAPIRepository`
5. User navigated to main app

## SwiftLint Configuration

Located at `.swiftlint.yml`:

**Disabled rules:**
- type_body_length, function_body_length, file_length, line_length
- force_cast, force_try
- cyclomatic_complexity
- identifier_name

**Enabled opt-in rules:**
- sorted_imports
- direct_return
- file_header
- weak_delegate

## Common Patterns

### Observable Chaining
```swift
repository.fetchData()
    .map { $0.toDomain() }
    .do(onNext: { /* side effect */ })
    .catchAndReturn(defaultValue)
    .subscribe(onNext: { /* handle */ })
```

### Error Handling
Network errors are defined in `DataLayer/Data/Data/Network/Common/NetworkError.swift`

### Shared State
Some features use singletons for shared state (e.g., FilterModel, CategoryModel in SearchFeature). Use cautiously - prefer passing state through Reactors when possible.

### Navigation
- Factories create ViewControllers for navigation
- Reactors use `@Pulse var presentTarget: PresentTarget?` for navigation events
- ViewControllers bind to `reactor.pulse(\.$presentTarget)` to handle navigation

## Project Structure

```
Poppool/
├── CoreLayer/                # Infrastructure (DI, Network, Storage)
├── DomainLayer/              # Business logic (Protocols & UseCases)
├── DataLayer/                # Data sources (API, Repositories)
├── PresentationLayer/        # UI (Features, Screens, Design System)
│   ├── DesignSystem/         # Shared UI components
│   ├── Presentation/         # Main app screens
│   ├── SearchFeature/        # Modular search feature
│   ├── LoginFeature/         # Modular login feature
│   └── PageNotFoundFeature/  # Error screen
├── Poppool/                  # Main app target
│   ├── Application/          # AppDelegate, SceneDelegate
│   └── Resource/             # Assets, Info.plist
├── Poppool.xcodeproj/
├── Poppool.xcworkspace/      # ALWAYS use workspace, not .xcodeproj
├── fastlane/                 # Deployment automation
└── .swiftlint.yml            # Code style configuration
```

## Git Workflow

**Main branch:** `develop` (use this for PRs)

Feature branches follow naming: `feat/#{issue-number}-{description}`

## Notes

- The workspace contains multiple local Swift Packages for each layer
- Each feature in PresentationLayer can have its own .xcodeproj for modularity
- Always use `Poppool.xcworkspace`, never `Poppool.xcodeproj` directly
- API secrets are stored in a `Secrets` class (not committed to repo)
- The app uses Naver Maps SDK (not Apple Maps or Google Maps)
- Build numbers are auto-incremented by Fastlane using timestamp format (YYMMDD.HHMM)
