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




extension ForceDirectedGraph {
    @inlinable
    public func onTicked(
        perform action: @escaping (KeyFrame) -> Void
    ) -> Self {
        self.model._onTicked = action
        return self
    }

    @inlinable
    public func onNodeTapped(
        perform action: @escaping (NodeID?) -> Void
    ) -> Self {
        self.model._onNodeTapped = action
        return self
    }
    
    @inlinable
    public func onNodeDragged(
        perform action: @escaping () -> Void
    ) -> Self {
        self.model._onNodeDragStateChanged = action
        return self
    }
}

