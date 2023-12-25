import SwiftUI

public struct _GraphRenderingContext<NodeID: Hashable>: Equatable {

    // @usableFromInline var nodes: [NodeMark<NodeID>] = []
    // @usableFromInline var edges: [LinkMark<NodeID>] = []

    @usableFromInline
    enum RenderingOperation {
        case node(NodeMark<NodeID>)
        case link(LinkMark<NodeID>)
        case modifierBegin(AnyGraphContentModifier)
        case modifierEnd
    }

    @usableFromInline
    var operations: [RenderingOperation] = []

    @inlinable
    init() {

    }
    
}

extension _GraphRenderingContext.RenderingOperation: Equatable {
    @inlinable
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.node(let l), .node(let r)):
            return l == r
        case (.link(let l), .link(let r)):
            return l == r
        case (.modifierEnd, .modifierEnd):
            return true
        case (.modifierBegin(let l), .modifierBegin(let r)):
            return l == r
        default:
            return false
        }
    }
}

extension _GraphRenderingContext {
    @inlinable
    var nodes: [NodeMark<NodeID>] {
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
    var edges: [LinkMark<NodeID>] {
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
