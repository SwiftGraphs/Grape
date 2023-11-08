import Observation
import SwiftUI
import ForceSimulation


@Observable
public class ForceDirectedGraph2DProxy<NodeID, ForceField> where NodeID: Hashable, ForceField: ForceProtocol, ForceField.Vector == SIMD2<Double>{

    @ObservationIgnored
    @usableFromInline
    weak var layoutEngine: ForceDirectedGraph2DLayoutEngine<ForceField>?
    
    public var lastRenderedSize: CGSize = .init()
    
    public var draggingNodeID: NodeID? = nil

    public init() {

    }

    public func start() {
        layoutEngine?.start()
    }

    public func stop() {
        layoutEngine?.stop()
    }
}
