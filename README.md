# Pokemon App 開發者文件

這是一份關於 Pokemon App 的開發者文件，旨在為 AI 助理和後續維護的開發者提供指引。

## 1. 專案總覽

本專案是一個基於 [PokeAPI](https://pokeapi.co/) 開發的 iOS 應用程式，主要功能包含展示寶可夢的分類、列表和詳細資訊。使用者可以瀏覽不同種類的寶可夢，查看牠們的詳細資料，並將喜歡的寶可夢加入收藏。

## 2. App 架構

本專案採用 **MVVM (Model-View-ViewModel)** 架構模式，以確保職責分離、提高程式碼的可讀性和可維護性。各元件職責如下：

- **Model**：定義從 API 接收到的資料結構，以及 App 內部的狀態資料。
- **View**：負責 UI 的呈現，在 `UIKit` 中對應 `UIViewController` 和 `UIView`，在 `SwiftUI` 中對應 `View`。View 層會綁定 ViewModel 的狀態來更新畫面。
- **ViewModel**：包含 UI 的狀態和業務邏輯。它會從 `Model` 層獲取資料，經過處理後提供給 `View` 顯示。它不直接與 `View` 互動，而是透過 `Combine` 框架進行資料綁定。

## 3. 專案結構

```
Pokemon/
├── App/              # App 進入點與路由管理
├── Assets.xcassets/  # 圖片、顏色等資源
├── Components/       # 可重用的 UI 元件
├── Core/             # 核心共用模組
│   ├── Model/        # 資料模型
│   ├── Networking/   # 網路層
│   ├── Storage/      # 本地儲存
│   └── Utilities/    # 工具類
├── Feature/          # 主要功能模組
│   ├── Home/         # 首頁 (UIKit)
│   ├── PockmonList/  # 寶可夢列表 (SwiftUI)
│   └── PokemonDetail/ # 寶可夢詳細頁 (SwiftUI)
└── PokemonTests/     # 單元測試與 UI 測試
```


## 4. 核心程式碼說明

### 網路層

網路請求的核心是 `PokeAPIClient`，它定義了所有與 PokeAPI 互動的介面。這種基於 Protocol 的設計使得網路層具有良好的擴展性和可測試性，例如在單元測試中可以輕易地用 `MockPokeAPIClient` 來取代真實的 API 請求。

```swift
// Core/Networking/PokemonAPI/PokeAPIClient.swift
protocol PokeAPIClientType {
    func fetchPokemonList(limit: Int, offset: Int) async throws -> PokemonListResponse
    func fetchPokemonDetail(id: Int) async throws -> PokemonDetailResponse
    // ... 其他 API
}

final class PokeAPIClient: PokeAPIClientType {
    private let httpClient: HTTPClient // 可替換的 HTTP 客戶端
    // ...
}
```

### 資料儲存

收藏功能由 `FavoriteStorage` 類別管理，它是一個 Singleton，方便在 App 的任何地方存取。`FavoriteStorage` 使用 `UserDefaults` 來儲存收藏的寶可夢 ID，並透過 `Combine` 的 `CurrentValueSubject` 來發布收藏狀態的變更。任何關心收藏狀態的 ViewModel 都可以訂閱 `valuesPublisher` 來即時更新 UI。

```swift
// Core/Storage/FavoriteStorage.swift
final class FavoriteStorage {
    private let subject: CurrentValueSubject<Set<Int>, Never>

    var valuesPublisher: AnyPublisher<Set<Int>, Never> {
        subject.eraseToAnyPublisher()
    }

    func toggle(_ pokemonID: Int) {
        // ... 更新 subject 和 UserDefaults
    }
}
```

### UI 實作與頁面導航

本專案混合使用了 `UIKit` 和 `SwiftUI` 來建構 UI。

- **首頁 (`UIKit`)**：`HomeViewController` 使用 `UICollectionViewDiffableDataSource` 來管理複雜的 Collection View，並搭配 `SnapKit` 來進行 Auto Layout。

- **列表頁與詳細頁 (`SwiftUI`)**：`PokemonListView` 和 `PokemonDetailView` 皆使用 `SwiftUI` 實現，並透過 `@StateObject` 來管理各自的 ViewModel。

- **頁面導航**：由 `MainRouter` 統一管理，它是一個 `ObservableObject`，透過 `NavigationStack` 的 `path` 來控制 `SwiftUI` 視圖的推入和彈出。

```swift
// App/MainRouter.swift
final class MainRouter: ObservableObject {
    @Published var path: [AppRoute] = []

    func push(_ route: AppRoute) {
        path.append(route)
    }
}
```

## 5. 測試

專案包含了單元測試和 UI 測試，以確保程式碼的品質和功能的穩定性。

- **單元測試 (`PokemonTests`)**：針對 ViewModel 和核心邏輯（如 `FavoriteStorage`）進行測試。測試中使用了 `MockPokeAPIClient` 來模擬網路行為，避免了實際的網路依賴。
- **UI 測試 (`PokemonUITests`)**：對主要的使用者流程進行自動化測試，確保 UI 的互動符合預期。

## 6. 使用套件

本專案使用了以下第三方套件：

- [**SnapKit**](https://github.com/SnapKit/SnapKit)：一個強大的 Auto Layout DSL，用於簡化 `UIKit` 的佈局程式碼。
- [**Kingfisher**](https://github.com/onevcat/Kingfisher)：一個強大且純 Swift 的圖片下載和快取套件。
- [**Lookin**](https://lookin.work/)：一個用於 iOS App UI 偵錯的工具，可以即時查看和修改 UI 元件的屬性。