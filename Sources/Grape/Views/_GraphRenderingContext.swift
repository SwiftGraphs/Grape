import SwiftUI

public struct _GraphRenderingContext<NodeID: Hashable> {

    @usableFromInline
    internal var symbols: [GraphRenderingStates<NodeID>.StateID: Text] = [:]

    @usableFromInline
    internal var operations: [RenderingOperation<NodeID>] = []

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
            && lhs.operations == rhs.operations
    }
}

extension _GraphRenderingContext {
    @inlinable
    internal var nodes: [NodeMark<NodeID>] {
        operations.compactMap { operation in
            switch operation {
            case .node(let node, _, _, _):
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
            case .link(let link, _, _, _):
                return link
            default:
                return nil
            }
        }
    }
}
