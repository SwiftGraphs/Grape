import SwiftUI

public struct _GraphRenderingContext<NodeID: Hashable> {

    @usableFromInline
    internal var symbols: [Text] = []

    @usableFromInline
    internal var operations: [RenderingOperation] = []

    @inlinable
    internal init() {
        
    }

    @usableFromInline
    internal var states: States = .init()
}

extension _GraphRenderingContext {
    @usableFromInline
    enum StateID: Hashable {
        case node(NodeID)
        case link(NodeID, NodeID)
    }
    @usableFromInline
    struct States {

        @usableFromInline
        var fill: [GraphicsContext.Shading] = []

        @usableFromInline
        var stroke: [GrapeEffect.Stroke] = []

        @usableFromInline
        var opacity: [Double] = []

        @usableFromInline
        var lastVisited: StateID? = nil

        @inlinable
        init(reservingCapacity capacity: Int = 128) {
            fill.reserveCapacity(capacity)
            stroke.reserveCapacity(capacity)
            opacity.reserveCapacity(capacity)
        }
    }
}

extension _GraphRenderingContext: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.symbols == rhs.symbols
            && lhs.operations == rhs.operations
    }
}

extension _GraphRenderingContext {
    @inlinable
    internal var nodes: [NodeMark<NodeID>] {
        operations.compactMap { operation in
            switch operation {
            case .node(let node):
                return node
            default:
                return nil
            }
        }
    }

    @inlinable
    internal var edges: [LinkMark<NodeID>] {
        operations.compactMap { operation in
            switch operation {
            case .link(let link):
                return link
            default:
                return nil
            }
        }
    }
}
