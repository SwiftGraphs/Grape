import SwiftUI

public struct _GraphRenderingContext<NodeID: Hashable> {

}

public protocol GraphContent<NodeID> {
    associatedtype NodeID: Hashable

    @inlinable
    func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<NodeID>)
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



// extension ForEach {
//     struct GraphContentWrapper: GraphContent {

//     }
// }