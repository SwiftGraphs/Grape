import Observation


@Observable
public class ForceDirectedGraph2DController<NodeID> {

    @ObservationIgnored
    @usableFromInline
    weak var layoutEngine: ForceDirectedGraph2DLayoutEngine?

    public init() {

    }

    public func start() {
        layoutEngine?.start()
    }

    public func stop() {
        layoutEngine?.stop()
    }
}