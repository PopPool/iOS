<div align="center">

# Poppool

<img width="800" alt="Poppool hero" src="https://github.com/user-attachments/assets/d381d6b0-bc95-46ef-9e85-ae886548a2c4" />

<br><br>

<img src="https://img.shields.io/badge/Xcode-16.2-blue?logo=Xcode"/>
<img src="https://img.shields.io/badge/Swift-5.9-red?logo=swift"/>
<img src="https://img.shields.io/badge/iOS-16.0+-black?logo=apple"/>

<h4>흩어져 있는 팝업스토어 정보를 모아 지도와 검색, 그리고 커뮤니티 기능으로 제공하는 iOS 애플리케이션입니다.</h4>
<h6>서버 이전 작업으로 인한 서비스 일시 중단 (7/27 ~ )</h6>

</div>

<div align="center">

|[준영](https://github.com/dongglehada)|[기현](https://github.com/zzangzzangguy)|[영훈](https://github.com/0Hooni)|
|:-----:|:-----:|:-----:|
|<img width="200px" src="https://avatars.githubusercontent.com/u/112812473?v=4"/>|<img width="200px" src="https://avatars.githubusercontent.com/u/122965360?v=4"/>|<img width="200px" src="https://avatars.githubusercontent.com/u/37678646?v=4"/>|

</div>

---

## 목차

1. [프로젝트 한눈에 보기](#프로젝트-한눈에-보기)
2. [주요 기능](#주요-기능)
3. [아키텍처](#아키텍처)
4. [모듈 구성](#모듈-구성)
5. [기술 스택](#기술-스택)
6. [시작하기](#시작하기)
7. [협업 규칙](#협업-규칙)

---

## 프로젝트 한눈에 보기

Poppool은 팝업 스토어 방문을 즐기는 사용자를 위해 제작된 애플리케이션으로, 네이버 지도 기반의 지도를 중심으로 팝업 스토어를 탐색하고 자세한 정보를 확인할 수 있도록 구성되었습니다. ReactorKit과 Rx 기반 설계로 화면 간 의존성을 낮추면서도 실시간 상호작용을 부드럽게 제공하며, 자체 구축한 DI 컨테이너를 통해 모듈 간 결합도를 관리합니다.

## 주요 기능

### 1. 지도 탐색
- 네이버 지도 SDK(NMapsMap)를 연동하여 실시간 위치, 마커 클러스터링, 카테고리 기반 필터를 제공하고, 팝업 상세 정보를 캐러셀로 노출합니다.【F:Poppool/PresentationLayer/Presentation/Presentation/Scene/Map/MapView/MapViewController.swift†L1-L199】
- 지도 영역 이동 시 ViewPort에 맞춘 스토어 데이터를 가져오고, 선택한 마커에 대한 상세 화면으로 네비게이션합니다.【F:Poppool/PresentationLayer/Presentation/Presentation/Scene/Map/MapView/MapViewController.swift†L92-L180】

### 2. 팝업 검색 및 필터링
- ReactorKit 기반 검색 화면에서 최근 검색어, 카테고리 태그, 필터 시트를 제공하며 북마크·페이지네이션을 포함한 풍부한 액션을 정의합니다.【F:Poppool/PresentationLayer/SearchFeature/SearchFeature/PopupSearch/Reactor/PopupSearchReactor.swift†L10-L159】
- 키워드 기반 팝업 목록을 유스케이스로부터 전달받아 상태를 갱신하고, 프리패칭으로 스크롤 경험을 개선합니다.【F:Poppool/PresentationLayer/SearchFeature/SearchFeature/PopupSearch/Reactor/PopupSearchReactor.swift†L92-L159】

### 3. 도메인 로직과 데이터 접근
- 지도 관련 유스케이스는 선택한 카테고리와 지도 영역을 받아 저장소에서 데이터를 가져오며, 위치 기반 필터링 로직을 제공합니다.【F:Poppool/DomainLayer/Domain/Domain/UseCaseImpl/MapUseCaseImpl.swift†L8-L70】
- 데이터 레이어는 Alamofire Provider를 통해 API를 호출하고, 응답 DTO를 도메인 모델로 변환합니다.【F:Poppool/DataLayer/Data/Data/RepositoryImpl/MapRepositoryImpl.swift†L8-L73】【F:Poppool/DataLayer/Data/Data/Network/Provider/ProviderImpl.swift†L5-L190】

### 4. 디자인 시스템
- 공통 버튼, 레이블, 검색바 등 재사용 가능한 UI 컴포넌트를 정의하여 화면 간 일관성을 유지합니다.【F:Poppool/PresentationLayer/DesignSystem/DesignSystem/Components/PPButton.swift†L5-L132】

## 아키텍처

- **모듈화된 클린 아키텍처**: Presentation, Domain, Data, Core(Infrastructure) 레이어로 나누어 책임을 분리하였으며, 각 레이어는 Interface 모듈을 통해 서로 통신합니다.【F:Poppool/Poppool/Application/AppDelegate.swift†L4-L108】
- **의존성 주입 컨테이너**: 커스텀 DIContainer와 `@Dependency` 프로퍼티 래퍼를 사용해 런타임에 의존성을 등록/해결합니다.【F:Poppool/CoreLayer/Infrastructure/Infrastructure/DIContainer/DIContainer.swift†L3-L65】【F:Poppool/CoreLayer/Infrastructure/Infrastructure/DIContainer/DependencyWrapper.swift†L3-L28】
- **리액티브 상태 관리**: ReactorKit과 RxSwift를 통해 화면 상태를 선언적으로 기술하고, 사용자 액션을 명확히 분류합니다.【F:Poppool/PresentationLayer/SearchFeature/SearchFeature/PopupSearch/Reactor/PopupSearchReactor.swift†L10-L160】

## 모듈 구성

| 계층 | 주요 모듈 | 설명 |
| --- | --- | --- |
| Presentation | `Presentation`, `LoginFeature`, `SearchFeature`, `DesignSystem` | 화면, 네비게이션, 공통 UI 컴포넌트 정의【F:Poppool/Poppool/Application/AppDelegate.swift†L4-L14】 |
| Domain | `Domain`, `DomainInterface` | 엔터티, 리포지토리/유스케이스 인터페이스와 구현 제공【F:Poppool/Poppool/Application/AppDelegate.swift†L4-L14】 |
| Data | `Data` | 네트워크 통신, DTO 변환, 저장소 구현 관리【F:Poppool/Poppool/Application/AppDelegate.swift†L4-L108】 |
| Core | `Infrastructure` | 로깅, 네트워크, DI 등 공통 인프라 제공【F:Poppool/CoreLayer/Infrastructure/Infrastructure/DIContainer/DIContainer.swift†L3-L65】 |

## 기술 스택

- **Language & Tooling**: Swift 5.9, Xcode 16.2
- **Reactive**: ReactorKit, RxSwift, RxCocoa【F:Poppool/PresentationLayer/SearchFeature/SearchFeature/PopupSearch/Reactor/PopupSearchReactor.swift†L6-L8】
- **UI/UX**: SnapKit, FloatingPanel, NMapsMap, Custom Design System【F:Poppool/PresentationLayer/Presentation/Presentation/Scene/Map/MapView/MapViewController.swift†L9-L16】
- **Networking**: Alamofire 기반 Provider, TokenInterceptor, RxSwift Observables【F:Poppool/DataLayer/Data/Data/Network/Provider/ProviderImpl.swift†L5-L190】
- **Third-Party Services**: Kakao SDK, Naver Maps 인증 설정을 앱 실행 시 초기화합니다.【F:Poppool/Poppool/Application/AppDelegate.swift†L15-L31】

## 시작하기

1. 저장소를 클론합니다.
   ```bash
   git clone https://github.com/PopPool/iOS.git
   ```
2. 필요한 서브모듈 또는 Swift Package Dependencies를 Xcode에서 Resolve합니다.
3. `Poppool.xcworkspace`를 열고, `Secrets` 구조체에 필요한 API 키(카카오, 네이버 지도 등)를 설정합니다.【F:Poppool/Poppool/Application/AppDelegate.swift†L22-L31】
4. iOS 16 이상 시뮬레이터 혹은 기기에서 빌드 및 실행합니다.

## 협업 규칙

- 새로운 의존성은 `DIContainer.register`를 통해 등록하고, 필요한 곳에서는 `@Dependency` 래퍼로 주입받습니다.【F:Poppool/CoreLayer/Infrastructure/Infrastructure/DIContainer/DIContainer.swift†L31-L65】【F:Poppool/Poppool/Application/AppDelegate.swift†L40-L109】
- 화면 상태는 ReactorKit을 통해 Action/Mutation/State 패턴으로 정의하며, RxSwift DisposeBag을 이용해 메모리를 관리합니다.【F:Poppool/PresentationLayer/SearchFeature/SearchFeature/PopupSearch/Reactor/PopupSearchReactor.swift†L10-L159】
- 네트워크 로깅과 에러 처리는 Provider 레벨에서 공통적으로 처리하고, 도메인에서는 순수 모델만 노출합니다.【F:Poppool/DataLayer/Data/Data/Network/Provider/ProviderImpl.swift†L22-L190】【F:Poppool/DataLayer/Data/Data/RepositoryImpl/MapRepositoryImpl.swift†L16-L73】

---

> 💡 **Tip**: 지도, 검색, 마이페이지 등 주요 기능은 각각 독립적인 모듈로 분리되어 있으니, 기능 추가 시 해당 모듈의 Interface 프로토콜을 우선 확인하면 빠르게 진입할 수 있습니다.

