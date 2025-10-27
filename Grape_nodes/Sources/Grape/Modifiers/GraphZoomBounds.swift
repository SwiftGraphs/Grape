import SwiftUI

public struct GraphZoomBounds: Equatable {
    public var minimumScale: CGFloat
    public var maximumScale: CGFloat

    @inlinable
    public init(minimumScale: CGFloat = 1e-2, maximumScale: CGFloat = .infinity) {
        self.minimumScale = minimumScale
        self.maximumScale = maximumScale
    }
}

private struct GraphZoomBoundsKey: EnvironmentKey {
    static let defaultValue = GraphZoomBounds()
}

extension EnvironmentValues {
    @inlinable
    public var graphZoomBounds: GraphZoomBounds {
        get { self[GraphZoomBoundsKey.self] }
        set { self[GraphZoomBoundsKey.self] = newValue }
    }
}

extension View {
    @inlinable
    public func graphZoomBounds(min minimumScale: CGFloat, max maximumScale: CGFloat) -> some View {
        self.environment(
            \.graphZoomBounds,
            GraphZoomBounds(minimumScale: minimumScale, maximumScale: maximumScale)
        )
    }
}
