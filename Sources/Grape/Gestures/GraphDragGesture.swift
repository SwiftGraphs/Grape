import ForceSimulation
import SwiftUI

public enum GraphDragState<NodeID: Hashable> {
    case node(NodeID)
    case background(SIMD2<Double>)
}

#if !os(tvOS)

// NOTE: `@inlinable` annotations were removed from this file to remain source-compatible
// with the SDK 27 change where `@State` became a macro: the macro now synthesizes a
// `private` backing store (`_dragState`), which an `@inlinable` function may not reference
// ("Property '_dragState' is private and cannot be referenced from an '@inlinable' function").
// Removing `@inlinable` only disables cross-module inlining (an optimization) and does not
// change behavior.
@usableFromInline
struct GraphDragModifier<NodeID: Hashable>: ViewModifier {

    public var dragGesture: some Gesture {
        DragGesture(
            minimumDistance: Self.minimumDragDistance,
            coordinateSpace: .local
        )
        .onChanged(onChanged)
        .onEnded(onEnded)
    }

    public func body(content: Content) -> some View {
        content.gesture(dragGesture)
    }

    @State
    public var dragState: GraphDragState<NodeID>?

    @usableFromInline
    let graphProxy: GraphProxy

    @usableFromInline
    let action: ((GraphDragState<NodeID>?) -> Void)?

    init(
        graphProxy: GraphProxy,
        action: ((GraphDragState<NodeID>?) -> Void)? = nil
    ) {
        self.graphProxy = graphProxy
        self.action = action
    }

    static var minimumDragDistance: CGFloat { 3.0 }

    static var minimumAlphaAfterDrag: CGFloat { 0.5 }

    public func onEnded(
        value: DragGesture.Value
    ) {
        if dragState != nil {
            switch dragState {
            case .node(let nodeID):
                graphProxy.setNodeFixation(nodeID: nodeID, fixation: nil)
            case .background(let start):
                let delta = value.location.simd - start
                graphProxy.modelTransform.translate += delta
                dragState = .background(value.location.simd)
            case .none:
                break
            }
            dragState = .none
        }

        if let action {
            action(dragState)
        }
    }

    public func onChanged(
        value: DragGesture.Value
    ) {
        if dragState == nil {
            if let nodeID = graphProxy.node(of: NodeID.self, at: value.startLocation) {
                dragState = .node(nodeID)
                graphProxy.setNodeFixation(nodeID: nodeID, fixation: value.startLocation)
            } else {
                dragState = .background(value.location.simd)
            }
        } else {
            switch dragState {
            case .node(let nodeID):
                graphProxy.setNodeFixation(nodeID: nodeID, fixation: value.location)
            case .background(let start):
                let delta = value.location.simd - start
                graphProxy.modelTransform.translate += delta
                dragState = .background(value.location.simd)
            case .none:
                break
            }
        }

        if let action {
            action(dragState)
        }
    }
}

extension View {

    /// Attach a drag gesture to an overlay or a background view created with ``SwiftUICore/View/graphOverlay(alignment:content:)``.
    /// - Parameters:
    ///  - proxy: The graph proxy that provides the graph context.
    ///  - type: The type of the node ID. The drag gesture will look for the node ID of this type.
    ///  - action: The action to perform when the drag gesture changes.
    public func withGraphDragGesture<NodeID>(
        _ proxy: GraphProxy,
        of type: NodeID.Type,
        action: ((GraphDragState<NodeID>?) -> Void)? = nil
    ) -> some View {
        self.modifier(GraphDragModifier(graphProxy: proxy, action: action))
    }
}

#endif
