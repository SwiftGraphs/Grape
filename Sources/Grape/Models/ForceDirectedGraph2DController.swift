import Observation
import SwiftUI


@Observable
public class ForceDirectedGraph2DProxy<NodeID> {

    @ObservationIgnored
    @usableFromInline
    weak var layoutEngine: ForceDirectedGraph2DLayoutEngine?
    
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
