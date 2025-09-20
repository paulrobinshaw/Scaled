import SwiftUI

@main
struct ScaledApp: App {
    private let dependencies = AppDependencies.live()

    var body: some Scene {
        WindowGroup {
            RootScene(dependencies: dependencies)
                .environment(\.appDependencies, dependencies)
        }
    }
}

private struct AppDependenciesKey: EnvironmentKey {
    static let defaultValue: AppDependencies = .preview()
}

extension EnvironmentValues {
    var appDependencies: AppDependencies {
        get { self[AppDependenciesKey.self] }
        set { self[AppDependenciesKey.self] = newValue }
    }
}
