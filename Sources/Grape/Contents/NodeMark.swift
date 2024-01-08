import SwiftUI
import simd

public struct NodeMark<NodeID: Hashable>: GraphContent & Identifiable {

    // public enum LabelDisplayStrategy {
    //     case auto
    //     case specified(Bool)
    //     case byPageRank((Double) -> Bool)
    // }

    // public enum LabelPositioning {
    //     case bottomOfMark
    //     case topOfMark
    //     case startAfterMark
    //     case endBeforeMark
    // }

    public var id: NodeID

    // public var fill: Color
    // public var strokeColor: Color?
    // public var strokeWidth: Double
    public var radius: Double
    // public var label: String?
    // public var labelColor: Color
    // public var labelDisplayStrategy: LabelDisplayStrategy
    // public var labelPositioning: LabelPositioning
    @inlinable
    public init(
        id: NodeID,
        radius: Double = 4.0
    ) {
        self.id = id
        self.radius = radius
    }

    @inlinable
    public func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<NodeID>) {
        context.nodeOperations.append(
            .init(
                self,
                context.states.currentShading,
                context.states.currentStroke,
                context.states.currentSymbolShape
            )
        )
        context.states.currentID = .node(id)
        context.nodeRadiusSquaredLookup[id] = simd_length_squared(
            context.states.currentSymbolSizeOrDefault.simd)
    }
}

extension NodeMark: CustomDebugStringConvertible {
    @inlinable
    public var debugDescription: String {
        return "Node(id: \(id))"
    }
}

extension NodeMark: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id && lhs.radius == rhs.radius
    }
}
