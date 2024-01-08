import ForceSimulation
import SwiftUI

public struct LinkMark<NodeID: Hashable>: GraphContent & Identifiable {

    // public enum LabelDisplayStrategy {
    //     case auto
    //     case specified(Bool)
    //     case byPageRank((Double, Double) -> Bool)
    // }

    // public enum LabelPositioning {
    //     case auto
    // }

    // public enum ArrowStyle {
    //     case none
    //     case triangle
    // }

    public var id: EdgeID<NodeID>

    // public var label: String?
    // public var labelColor: Color
    // public var labelDisplayStrategy: LabelDisplayStrategy
    // public var labelPositioning: LabelPositioning

    // public var strokeColor: Color
    // public var strokeWidth: Double
    // public var strokeDashArray: [Double]?

    // public var arrowStyle: ArrowStyle

    @inlinable
    public init(
        from: NodeID,
        to: NodeID
        // label: String? = nil,
        // labelColor: Color = .gray,
        // labelDisplayStrategy: LabelDisplayStrategy = .auto,
        // labelPositioning: LabelPositioning = .auto,
        // strokeColor: Color = .gray.opacity(0.2),
        // strokeWidth: Double = 1.0,
        // strokeDashArray: [Double]? = nil,
        // arrowStyle: ArrowStyle = .none
    ) {
        self.id = .init(source: from, target: to)
        // self.label = label
        // self.labelColor = labelColor
        // self.labelDisplayStrategy = labelDisplayStrategy
        // self.labelPositioning = labelPositioning
        // self.strokeColor = strokeColor
        // self.strokeWidth = strokeWidth
        // self.strokeDashArray = strokeDashArray
        // self.arrowStyle = arrowStyle
    }

    @inlinable
    public func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<NodeID>) {
        context.linkOperations.append(
            .init(
                self, 
                context.states.currentStroke, 
                nil
            )
        )
        context.states.currentID = .link(id.source, id.target)
    }
}

extension LinkMark: CustomDebugStringConvertible {
    @inlinable
    public var debugDescription: String {
        return
            "LinkMark(\(id.source) -> \(id.target))"
    }
}

extension LinkMark: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
