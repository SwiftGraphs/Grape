import ForceSimulation
import SwiftUI

#if !os(tvOS)
    @MainActor
    extension ForceDirectedGraph {
        @inlinable
        static var minimumAlphaAfterDrag: CGFloat { 0.5 }
        @inlinable
        internal func onDragChange(
            _ value: SwiftUI.DragGesture.Value
        ) {
            if !model.isDragStartStateRecorded {
                if let nodeID = model.findNode(at: value.startLocation) {
                    model.draggingNodeID = nodeID
                } else {
                    model.backgroundDragStart = value.location.simd
                }
                assert(model.isDragStartStateRecorded == true)
            }

            guard let nodeID = model.draggingNodeID else {
                if let dragStart = model.backgroundDragStart {
                    let delta = value.location.simd - dragStart
                    model.modelTransform.translate += delta
                    model.backgroundDragStart = value.location.simd
                }
                return
            }

            if model.simulationContext.storage.kinetics.alpha < Self.minimumAlphaAfterDrag {
                model.simulationContext.storage.kinetics.alpha = Self.minimumAlphaAfterDrag
            }

            let newLocationInSimulation = model.finalTransform.invert(value.location.simd)

            if let nodeIndex = model.simulationContext.nodeIndexLookup[nodeID] {
                model.simulationContext.storage.kinetics.fixation[
                    nodeIndex
                ] = newLocationInSimulation
            }

            guard let action = model._onNodeDragChanged else { return }
            action(nodeID, value.location)

        }

        @inlinable
        internal func onDragEnd(
            _ value: SwiftUI.DragGesture.Value
        ) {

            guard let nodeID = model.draggingNodeID else {
                if let dragStart = model.backgroundDragStart {
                    let delta = value.location.simd - dragStart
                    model.modelTransform.translate += delta
                    model.backgroundDragStart = nil
                }
                return
            }
            if model.simulationContext.storage.kinetics.alpha < Self.minimumAlphaAfterDrag {
                model.simulationContext.storage.kinetics.alpha = Self.minimumAlphaAfterDrag
            }

            model.draggingNodeID = nil

            guard let nodeIndex = model.simulationContext.nodeIndexLookup[nodeID] else { return }
            if model._onNodeDragEnded == nil {
                model.simulationContext.storage.kinetics.fixation[
                    nodeIndex
                ] = nil
            } else if let action = model._onNodeDragEnded, action(nodeID, value.location) {
                model.simulationContext.storage.kinetics.fixation[
                    nodeIndex
                ] = nil
            }
        }

        @inlinable
        static var minimumDragDistance: CGFloat { 3.0 }
    }
    @MainActor
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
#endif

#if os(iOS) || os(macOS)
    @MainActor extension ForceDirectedGraph {

        @inlinable
        static var minimumScaleDelta: CGFloat { 0.001 }

        @inlinable
        static var minimumScale: CGFloat { 1e-2 }

        @inlinable
        static var maximumScale: CGFloat { .infinity }

        @inlinable
        static var magnificationDecay: CGFloat { 0.1 }

        @inlinable
        internal func clamp(
            _ value: CGFloat,
            min: CGFloat,
            max: CGFloat
        ) -> CGFloat {
            Swift.min(Swift.max(value, min), max)
        }

        @inlinable
        internal func onMagnifyChange(
            _ value: MagnifyGesture.Value
        ) {
            var startTransform: ViewportTransform
            if let t = self.model.lastTransformRecord {
                startTransform = t
            } else {
                self.model.lastTransformRecord = self.model.modelTransform
                startTransform = self.model.modelTransform
            }

            let alpha = (startTransform.translate(by: self.model.obsoleteState.cgSize.simd / 2))
                .invert(value.startLocation.simd)

            let newScale = clamp(
                value.magnification * startTransform.scale,
                min: Self.minimumScale,
                max: Self.maximumScale)

            let newTranslate = (startTransform.scale - newScale) * alpha + startTransform.translate

            let newModelTransform = ViewportTransform(
                translate: newTranslate,
                scale: newScale
            )
            self.model.modelTransform = newModelTransform

            guard let action = self.model._onGraphMagnified else { return }
            action()
        }

        @inlinable
        internal func onMagnifyEnd(
            _ value: MagnifyGesture.Value
        ) {
            var startTransform: ViewportTransform
            if let t = self.model.lastTransformRecord {
                startTransform = t
            } else {
                self.model.lastTransformRecord = self.model.modelTransform
                startTransform = self.model.modelTransform
            }

            let alpha = (startTransform.translate(by: self.model.obsoleteState.cgSize.simd / 2))
                .invert(value.startLocation.simd)

            let newScale = clamp(
                value.magnification * startTransform.scale,
                min: Self.minimumScale,
                max: Self.maximumScale)

            let newTranslate = (startTransform.scale - newScale) * alpha + startTransform.translate
            let newModelTransform = ViewportTransform(
                translate: newTranslate,
                scale: newScale
            )
            self.model.lastTransformRecord = nil
            self.model.modelTransform = newModelTransform
            guard let action = self.model._onGraphMagnified else { return }
            action()
        }
    }
#endif

@MainActor
extension ForceDirectedGraph {
    @inlinable
    public func onTicked(
        perform action: @escaping (UInt) -> Void
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
    public func onNodeDragChanged(
        perform action: @escaping (NodeID, CGPoint) -> Void
    ) -> Self {
        self.model._onNodeDragChanged = action
        return self
    }

    @inlinable
    public func onNodeDragEnded(
        shouldBeFixed action: @escaping (NodeID, CGPoint) -> Bool
    ) -> Self {
        self.model._onNodeDragEnded = action
        return self
    }

    @inlinable
    public func onGraphMagnified(
        perform action: @escaping () -> Void
    ) -> Self {
        return self
    }

}
