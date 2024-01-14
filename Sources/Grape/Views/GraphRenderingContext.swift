import SwiftUI

public struct _GraphRenderingContext<NodeID: Hashable> {
    @usableFromInline
    enum ViewResolvingState<V> where V: View {
        case pending(V)
        case resolved(V, CGImage?)
    }

    @usableFromInline
    internal var resolvedTexts: [GraphRenderingStates<NodeID>.StateID: String] = [:]

    @usableFromInline
    internal var resolvedViews:
        [GraphRenderingStates<NodeID>.StateID: ViewResolvingState<AnyView>] = [:]

    @usableFromInline
    internal var textOffsets:
        [GraphRenderingStates<NodeID>.StateID: (alignment: Alignment, offset: SIMD2<Double>)] = [:]

    @usableFromInline
    internal var symbols: [String: ViewResolvingState<Text>] = [:]

    @usableFromInline
    internal var nodeOperations: [RenderOperation<NodeID>.Node] = []

    @usableFromInline
    internal var nodeRadiusSquaredLookup: [NodeID: Double] = [:]

    @usableFromInline
    internal var linkOperations: [RenderOperation<NodeID>.Link] = []

    @inlinable
    internal init() {

    }

    @usableFromInline
    internal var states = GraphRenderingStates<NodeID>()

    @inlinable
    func updateEnvironment(with newEnvironment: EnvironmentValues) {

    }
}

extension _GraphRenderingContext.ViewResolvingState {
    @MainActor
    @inlinable
    func resolve(in environment: EnvironmentValues) -> CGImage? {
        switch self {
        case .pending(let view):
            let cgImage = view.environment(\.self, environment).toCGImage(with: environment)
            // debugPrint("[RESOLVE VIEW]")
            return cgImage
        case .resolved(_, let cgImage):
            return cgImage
        }
    }
}

extension _GraphRenderingContext: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.nodeOperations == rhs.nodeOperations
            && lhs.linkOperations == rhs.linkOperations
    }
}

extension _GraphRenderingContext {
    @inlinable
    internal var nodes: [NodeMark<NodeID>] {
        nodeOperations.map(\.mark)
    }

    @inlinable
    internal var edges: [LinkMark<NodeID>] {
        linkOperations.map(\.mark)
    }
}
