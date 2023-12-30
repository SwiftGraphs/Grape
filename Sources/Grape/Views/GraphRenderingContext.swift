import SwiftUI

public struct _GraphRenderingContext<NodeID: Hashable> {
    @usableFromInline
    enum TextResolvingStatus: Equatable {
        case pending(Text)
        case resolved(CGImage?)
    }

    @usableFromInline
    internal var resolvedTexts: [GraphRenderingStates<NodeID>.StateID: String] = [:]

    @usableFromInline
    internal var textOffsets:
        [GraphRenderingStates<NodeID>.StateID: (alignment: Alignment, offset: SIMD2<Double>)] = [:]

    @usableFromInline
    internal var symbols: [String: TextResolvingStatus] = [:]

    @usableFromInline
    internal var nodeOperations: [RenderOperation<NodeID>.Node] = []

    @usableFromInline
    internal var linkOperations: [RenderOperation<NodeID>.Link] = []

    @inlinable
    internal init() {

    }

    @usableFromInline
    internal var states = GraphRenderingStates<NodeID>()
}

extension _GraphRenderingContext: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.symbols == rhs.symbols
            && lhs.nodeOperations == rhs.nodeOperations
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
