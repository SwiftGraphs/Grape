import SwiftUI

public struct _GraphRenderingContext<NodeID: Hashable> {

    @usableFromInline
    internal var symbols: [GraphRenderingStates<NodeID>.StateID: Text] = [:]

    // @usableFromInline
    // internal var operations: [RenderingOperation<NodeID>] = []
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
    }
}

extension _GraphRenderingContext {
    @inlinable
    internal var nodes: [NodeMark<NodeID>] {
        nodeOperations.map(\.mark)
        // operations.compactMap { operation in
        //     switch operation {
        //     case .node(let node, _, _, _):
        //         return node
        //     default:
        //         return nil
        //     }
        // }
    }

    @inlinable
    internal var edges: [LinkMark<NodeID>] {
        linkOperations.map(\.mark)
        // operations.compactMap { operation in
        //     switch operation {
        //     case .link(let link, _, _, _):
        //         return link
        //     default:
        //         return nil
        //     }
        // }
    }
}
