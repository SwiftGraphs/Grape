import SwiftUI

public struct NodeMark<NodeID: Hashable>: GraphContent & Identifiable {

    public enum LabelDisplayStrategy {
        case auto
        case specified(Bool)
        case byPageRank((Double) -> Bool)
    }

    public enum LabelPositioning {
        case bottomOfMark
        case topOfMark
        case startAfterMark
        case endBeforeMark
    }

    public var id: NodeID

    public var fill: Color
    public var strokeColor: Color?
    public var strokeWidth: Double
    public var radius: Double
    // public var label: String?
    // public var labelColor: Color
    // public var labelDisplayStrategy: LabelDisplayStrategy
    // public var labelPositioning: LabelPositioning
    @inlinable
    public init(
        id: NodeID,
        fill: Color = .accentColor,
        radius: Double = 4.0,
        label: String? = nil,
        labelColor: Color = .accentColor,
        labelDisplayStrategy: LabelDisplayStrategy = .auto,
        labelPositioning: LabelPositioning = .bottomOfMark,
        strokeColor: Color? = nil,
        strokeWidth: Double = 1
    ) {
        self.id = id
        self.fill = fill
        self.radius = radius
        // self.label = label
        // self.labelColor = labelColor
        // self.labelDisplayStrategy = labelDisplayStrategy
        // self.labelPositioning = labelPositioning

        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
    }

    @inlinable
    public func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<NodeID>) {
        context.operations.append(
            .node(
                self,
                context.states.currentShading,
                context.states.currentStroke,
                nil
            )
        )
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
