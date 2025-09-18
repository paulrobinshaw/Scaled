# Services Directory

This directory contains all business logic, data operations, and external integrations.

## SLC Principle: Simple, Lovable, Complete

Following our SLC approach (NOT MVP), services should be:
- **Simple**: Clear APIs with intuitive method names and parameters
- **Lovable**: Reliable, fast, with excellent error handling and recovery
- **Complete**: Full functionality including caching, retry logic, offline support where appropriate

No shortcuts or "temporary" solutions - build services that are production-ready from day one.

## Purpose

Services handle:
- Business logic and rules
- API/network communications
- Data persistence
- Complex calculations
- External system integrations
- Coordination between models

## Architecture Pattern

Services act as the bridge between Views and external systems:

```swift
@MainActor
class UserService: ObservableObject {
    @Published private(set) var currentUser: User?
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    private let networkClient: NetworkClient
    private let storage: UserStorage

    init(networkClient: NetworkClient = .shared,
         storage: UserStorage = .shared) {
        self.networkClient = networkClient
        self.storage = storage
    }

    func login(email: String, password: String) async {
        isLoading = true
        error = nil

        do {
            let user = try await networkClient.login(email: email, password: password)
            currentUser = user
            try await storage.save(user)
        } catch {
            self.error = error
        }

        isLoading = false
    }
}
```

## Guidelines

### DO:
- Use protocol-oriented design for testability
- Implement proper error handling
- Use async/await for asynchronous operations
- Keep services focused on a single domain
- Use dependency injection
- Make services @MainActor when they update UI state
- Cache data appropriately

### DON'T:
- Create "Manager" classes that do everything
- Mix concerns (separate network, storage, business logic)
- Ignore thread safety
- Return raw network responses (transform to models)
- Create circular dependencies

## Service Types

Common service patterns:

### Network Service
```swift
protocol NetworkService {
    func fetch<T: Decodable>(_ type: T.Type, from endpoint: Endpoint) async throws -> T
    func send<T: Encodable>(_ data: T, to endpoint: Endpoint) async throws
}
```

### Storage Service
```swift
protocol StorageService {
    func save<T: Codable>(_ object: T, for key: String) async throws
    func load<T: Codable>(_ type: T.Type, for key: String) async throws -> T?
    func delete(for key: String) async throws
}
```

### Business Logic Service
```swift
class PricingService {
    func calculateDiscount(for items: [Item], with coupon: Coupon?) -> Decimal {
        // Business rules here
    }
}
```

## Organization

```
Services/
├── Network/
│   ├── APIClient.swift
│   ├── Endpoints.swift
│   └── URLSession+Extensions.swift
├── Storage/
│   ├── UserDefaults+Service.swift
│   ├── KeychainService.swift
│   └── CoreDataService.swift
├── Authentication/
│   ├── AuthenticationService.swift
│   └── TokenManager.swift
└── Business/
    ├── PricingService.swift
    └── ValidationService.swift
```

## Testing

Services should be thoroughly tested:
- Unit tests for business logic
- Mock external dependencies
- Test error handling paths
- Verify state changes
- Test async operations

```swift
class UserServiceTests: XCTestCase {
    var sut: UserService!
    var mockNetwork: MockNetworkClient!

    override func setUp() {
        mockNetwork = MockNetworkClient()
        sut = UserService(networkClient: mockNetwork)
    }

    func testLoginSuccess() async {
        // Test implementation
    }
}
```