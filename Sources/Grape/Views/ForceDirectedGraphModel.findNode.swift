import ForceSimulation
import SwiftUI
import simd

extension ForceDirectedGraphModel {
    @inlinable
    internal func findNode(
        at locationInSimulationCoordinate: SIMD2<Double>
    ) -> NodeID? {
        for i in simulationContext.storage.kinetics.range.reversed() {
            let iNodeID = simulationContext.nodeIndices[i]
            guard
                let iRadius2 = graphRenderingContext.nodeRadiusSquaredLookup[
                    simulationContext.nodeIndices[i]
                ]
            else { continue }
            let iPos = simulationContext.storage.kinetics.position[i]
            

            if simd_length_squared(locationInSimulationCoordinate - iPos) <= iRadius2
            {
                return iNodeID
            }
        }
        return nil
    }


    @inlinable
    internal func findNode(
        at locationInViewportCoordinate: CGPoint
    ) -> NodeID? {
        let simulationLocation = self.finalTransform.invert(locationInViewportCoordinate.simd)
        return findNode(at: simulationLocation)
    }

}
