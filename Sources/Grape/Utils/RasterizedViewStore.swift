import SwiftUI

@usableFromInline
struct ViewRasteriazationStore<T: Hashable & Equatable, V: View> {
    @usableFromInline
    enum RasteriazationEntry {
        case pending(V)
        case resolved(V, CGImage?)
    }

    @usableFromInline
    internal var resolvedViews: [T: RasteriazationEntry] = [:]

    @inlinable
    internal init() {

    }
}

extension ViewRasteriazationStore {
    @MainActor
    @inlinable
    func resolve(
        _ key: T,
        in environment: EnvironmentValues
    ) -> CGImage? {
        switch self.resolvedViews[key] {
        case .pending(let view):
            let cgImage = view.environment(\.self, environment).toCGImage(with: environment)
            debugPrint("[RESOLVE VIEW]")
            return cgImage
        case .resolved(_, let cgImage):
            return cgImage
        case .none:
            return nil
        }
    }
}
