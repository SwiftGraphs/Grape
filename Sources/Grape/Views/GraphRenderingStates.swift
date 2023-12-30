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
    var stroke: [GraphContentEffect.Stroke] = []

    @inlinable
    var currentStroke: GraphContentEffect.Stroke? { stroke.last }

    @usableFromInline
    var opacity: [Double] = []

    @inlinable
    var currentOpacity: Double? { opacity.last }


    @usableFromInline
    var symbolShape: [Path] = []

    @inlinable
    var currentSymbolShape: Path? { symbolShape.last }

    @usableFromInline
    var symbolSize: [CGSize] = []

    @inlinable
    var currentSymbolSize: CGSize? { symbolSize.last }

    @usableFromInline
    let defaultShading: GraphicsContext.Shading

    @usableFromInline
    let defaultSymbolSize = CGSize(width: 6, height: 6)

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
