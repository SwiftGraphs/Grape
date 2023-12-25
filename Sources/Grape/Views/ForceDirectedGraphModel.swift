import Foundation
import Observation


public final class ForceDirectedGraphModel<NodeID: Hashable> {
    @ObservationIgnored
    @usableFromInline
    var graphRenderingContext: _GraphRenderingContext<NodeID>

    @usableFromInline
    var changeMessage = "N/A"

    // @ObservationIgnored
    @usableFromInline
    var currentFrame: KeyFrame = 0

    @ObservationIgnored
    @usableFromInline
    let ticksPerSecond: Double

    @ObservationIgnored
    @usableFromInline
    var scheduledTimer: Timer? = nil

    @ObservationIgnored
    @usableFromInline
    var _onTicked: ((KeyFrame) -> Void)? = nil

    @ObservationIgnored
    @usableFromInline
    var _onNodeDragStateChanged: (() -> Void)? = nil

    @ObservationIgnored
    @usableFromInline
    var _onNodeFocusStateChanged: (() -> Void)? = nil

    @ObservationIgnored
    @usableFromInline
    var _onViewportTransformChanged: ((ViewportTransform, Bool) -> Void)? = nil

    @ObservationIgnored
    @usableFromInline
    var _onSimulationStabilized: (() -> Void)? = nil

    @inlinable
    init(
        _ graphRenderingContext: _GraphRenderingContext<NodeID>,
        ticksPerSecond: Double = 60.0
    ) {
        self.graphRenderingContext = graphRenderingContext
        self.ticksPerSecond = ticksPerSecond
    }
    @inlinable
    func start() {
        guard self.scheduledTimer == nil else { return }
        self.scheduledTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0 / ticksPerSecond,
            repeats: true
        ) { [weak self] _ in

            self?.tick()
        }
    }

    @inlinable
    func tick() {
        withMutation(keyPath: \.currentFrame) {
            currentFrame.advance()
        }
        _onTicked?(currentFrame)
    }
    @inlinable
    func stop() {
        self.scheduledTimer?.invalidate()
        self.scheduledTimer = nil
    }
    @inlinable
    deinit {
        stop()
    }

    @inlinable
    func revive(with newContext: _GraphRenderingContext<NodeID>) {
        self.changeMessage =
            "gctx \(graphRenderingContext.nodes.count) -> \(newContext.nodes.count)"
        self.graphRenderingContext = newContext
    }







    @ObservationIgnored
    @usableFromInline
    let _$observationRegistrar = Observation.ObservationRegistrar()
    
    @inlinable
    nonisolated func access<Member>(
        keyPath: KeyPath<ForceDirectedGraphModel, Member>
    ) {
        _$observationRegistrar.access(self, keyPath: keyPath)
    }
    
    @inlinable
    nonisolated func withMutation<Member, MutationResult>(
        keyPath: KeyPath<ForceDirectedGraphModel, Member>,
        _ mutation: () throws -> MutationResult
    ) rethrows -> MutationResult {
        try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
    }
}

extension ForceDirectedGraphModel: Observation.Observable {

}
