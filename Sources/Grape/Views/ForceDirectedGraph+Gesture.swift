import SwiftUI

extension ForceDirectedGraph {
    @inlinable
    internal func onDragChange(
        _ value: SwiftUI.DragGesture.Value
    ) {

    }

    @inlinable
    internal func onDragEnd(
        _ value: SwiftUI.DragGesture.Value
    ) {

    }

    @inlinable
    static var minimumDragDistance: CGFloat { 3.0 }
}

extension ForceDirectedGraph {
    @inlinable
    internal func onTapGesture(
        _ location: CGPoint
    ) {
        guard let action = self.model._onNodeTapped else { return }
        let nodeID = self.model.findNode(at: location)
        action(nodeID)
    }
}
