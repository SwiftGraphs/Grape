import SwiftUI

public struct _GraphRenderingContext<NodeID: Hashable>: Equatable {

    @usableFromInline
    internal var symbols: [Text] = []

    @usableFromInline
    internal var operations: [RenderingOperation] = []

    @inlinable
    internal init() {

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
