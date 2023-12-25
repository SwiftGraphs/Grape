import SwiftUI

class GCRBox<NodeID: Hashable> {
    var graphContext: _GraphRenderingContext<NodeID>

    init(_ graphContext: _GraphRenderingContext<NodeID>) {
        self.graphContext = graphContext
    }
}

public struct KeyFrame {
    public var elapsed: UInt = 0

    @_transparent
    public init(rawValue: UInt) {
        self.elapsed = rawValue
    }

    @_transparent
    public mutating func advance(by delta: UInt = 1) {
        elapsed += delta
    }

    @_transparent
    public mutating func reset() {
        elapsed = 0
    }
}

extension KeyFrame: RawRepresentable, Equatable, Hashable, ExpressibleByIntegerLiteral {

    @_transparent
    public var rawValue: UInt {
        return elapsed
    }

    @_transparent
    public init(integerLiteral value: UInt) {
        self.init(rawValue: value)
    }
}

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

    init(
        _ graphRenderingContext: _GraphRenderingContext<NodeID>,
        ticksPerSecond: Double = 60.0
    ) {
        self.graphRenderingContext = graphRenderingContext
        self.ticksPerSecond = ticksPerSecond

        // let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {
        //     [weak self] timer in
        //     guard let self = self else {
        //         timer.invalidate()
        //         return
        //     }
        //     self.elapsedTime += 0.1
        // }

        // RunLoop.main.add(timer, forMode: .common)
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

public struct ForceDirectedGraph<NodeID: Hashable> {
 
    // the copy of the graph context to be used for comparison in `onChange`
    // should be not used for rendering
    let _graphRenderingContextShadow: _GraphRenderingContext<NodeID> 

    // Some state to be retained when the graph is updated
    @State 
    var clickCount = 0

    @State
    var model: ForceDirectedGraphModel<NodeID>
    
    @Binding
    var isRunning: Bool

    public init(
        _ isRunning: Binding<Bool> = .constant(true),
        @GraphContentBuilder<NodeID> _ graph: () -> some GraphContent<NodeID>
    ) {
        var gctx = _GraphRenderingContext<NodeID>()
        graph()._attachToGraphRenderingContext(&gctx)
        self._graphRenderingContextShadow = gctx
        self._isRunning = isRunning
        self.model = ForceDirectedGraphModel(gctx)

    }
}

