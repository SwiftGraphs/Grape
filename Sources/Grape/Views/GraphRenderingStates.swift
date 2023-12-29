import SwiftUI

@usableFromInline
internal struct GraphRenderingStates<NodeID: Hashable> {

    @usableFromInline
    enum StateID: Hashable {
        case node(NodeID)
        case link(NodeID, NodeID)
    }

    @usableFromInline
    var currentID: StateID? = nil

    @usableFromInline
    var shading: [GraphicsContext.Shading] = []

    @inlinable
    var currentShading: GraphicsContext.Shading? { shading.last }

    @usableFromInline
    var stroke: [StrokeStyle] = []

    @inlinable
    var currentStroke: StrokeStyle? { stroke.last }

    @usableFromInline
    var opacity: [Double] = []

    @inlinable
    var currentOpacity: Double? { opacity.last }


    @usableFromInline
    var shape: [Path] = []

    @inlinable
    var currentShape: Path? { shape.last }

    @usableFromInline
    let defaultShading: GraphicsContext.Shading

    @inlinable
    init(
        defaultShading: GraphicsContext.Shading = .color(.blue),
        reservingCapacity capacity: Int = 128
    ) {
        shading.reserveCapacity(capacity)
        stroke.reserveCapacity(capacity)
        opacity.reserveCapacity(capacity)

        self.defaultShading = defaultShading
    }
}
