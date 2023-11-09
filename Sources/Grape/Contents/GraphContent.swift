import SwiftUI
import ForceSimulation

public protocol GraphContent {}

protocol GraphLike {
    associatedtype Node: Identifiable
    associatedtype Edge: Identifiable where Edge.ID == EdgeID<Node.ID>
    var nodes: [Node] { get }
    var links: [Edge] { get }
}

extension GraphContent {
    @inlinable
    public func foregroundStyle<S>(_ style: S) -> Self where S: ShapeStyle {
        return self
    }

    @inlinable
    func opacity(_ value: Double) -> Self {
        return self
    }
}
