import SwiftUI

public struct _GraphRenderingContext<NodeID: Hashable> {

    @usableFromInline
    internal var resolvedTexts: [GraphRenderingStates<NodeID>.StateID: String] = [:]

    @usableFromInline
    internal var symbols: [String: CGImage?] = [:]

    // @inlinable
    // internal var resolvedSymbol: some View {
    //     // print("EVAL")
    //     let enumerated = Array(self.symbols.keys)
    //     return ForEach(enumerated, id: \.self) { 
    //         return self.symbols[$0]!.tag($0)
    //     }
    // }

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
