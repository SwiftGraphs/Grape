import SwiftUI
import ForceSimulation

public protocol GraphContent<NodeID> {
    associatedtype NodeID: Hashable
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