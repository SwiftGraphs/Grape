import SwiftUI


public protocol GraphContent<NodeID> {
    associatedtype NodeID: Hashable

    @inlinable
    func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<NodeID>)
}


