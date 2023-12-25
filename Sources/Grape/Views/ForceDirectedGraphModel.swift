import Foundation
import Observation

@Observable
final class ForceDirectedGraphModel<NodeID: Hashable> {
    @ObservationIgnored
    var graphRenderingContext: _GraphRenderingContext<NodeID>

    var changeMessage = "N/A"

    // @ObservationIgnored
    var currentFrame: KeyFrame = 0

    @ObservationIgnored
    let ticksPerSecond: Double

    @ObservationIgnored
    var scheduledTimer: Timer? = nil

    @ObservationIgnored
    var _onTicked: ((KeyFrame) -> Void)? = nil

    @ObservationIgnored
    var _onNodeDragStateChanged: (() -> Void)? = nil

    @ObservationIgnored
    var _onNodeFocusStateChanged: (() -> Void)? = nil

    @ObservationIgnored
    var _onViewportTransformChanged: ((ViewportTransform, Bool) -> Void)? = nil

    @ObservationIgnored
    var _onSimulationStabilized: (() -> Void)? = nil

    init(
        _ graphRenderingContext: _GraphRenderingContext<NodeID>,
        ticksPerSecond: Double = 60.0
    ) {
        self.graphRenderingContext = graphRenderingContext
        self.ticksPerSecond = ticksPerSecond
    }

    func start() {
        guard self.scheduledTimer == nil else { return }
        self.scheduledTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0 / ticksPerSecond,
            repeats: true
        ) { [weak self] _ in
            self?.tick()
        }
    }

    func tick() {
        withMutation(keyPath: \.currentFrame) {
            currentFrame.advance()
        }
        _onTicked?(currentFrame)
    }

    func stop() {
        self.scheduledTimer?.invalidate()
        self.scheduledTimer = nil
    }

    deinit {
        stop()
    }

    func revive(with newContext: _GraphRenderingContext<NodeID>) {
        self.changeMessage =
            "gctx \(graphRenderingContext.nodes.count) -> \(newContext.nodes.count)"
        self.graphRenderingContext = newContext
    }
}
