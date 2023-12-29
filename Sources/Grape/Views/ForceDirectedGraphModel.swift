import ForceSimulation
import Foundation
import Observation
import SwiftUI

//@Observable
public final class ForceDirectedGraphModel<NodeID: Hashable> {

    @usableFromInline
    var graphRenderingContext: _GraphRenderingContext<NodeID>

    @usableFromInline
    var simulationContext: SimulationContext<NodeID>

    @usableFromInline
    var modelTransform: ViewportTransform = .identity

    @usableFromInline
    var _$changeMessage = "N/A"

    @usableFromInline
    var _$currentFrame: KeyFrame = 0

    @inlinable
    var changeMessage: String {
        @storageRestrictions(initializes: _$changeMessage)
        init(initialValue) {
            _$changeMessage = initialValue
        }

        get {
            access(keyPath: \.changeMessage)
            return _$changeMessage
        }

        set {
            withMutation(keyPath: \.changeMessage) {
                _$changeMessage = newValue
            }
        }
    }

    @inlinable
    var currentFrame: KeyFrame = 0
    {
        @storageRestrictions(initializes: _$currentFrame)
        init(initialValue) {
            _$currentFrame = initialValue
        }

        get {
            access(keyPath: \.currentFrame)
            return _$currentFrame
        }
        set {
            withMutation(keyPath: \.currentFrame) {
                _$currentFrame = newValue
            }
        }
    }

    /** Observation ignored params */

    @usableFromInline
    let ticksPerSecond: Double

    @usableFromInline
    var scheduledTimer: Timer? = nil

    @usableFromInline
    var _onTicked: ((KeyFrame) -> Void)? = nil

    @usableFromInline
    var _onNodeDragStateChanged: (() -> Void)? = nil

    @usableFromInline
    var _onNodeFocusStateChanged: (() -> Void)? = nil

    @usableFromInline
    var _onViewportTransformChanged: ((ViewportTransform, Bool) -> Void)? = nil

    @usableFromInline
    var _onSimulationStabilized: (() -> Void)? = nil

    @usableFromInline
    var _onEmitNode: ((NodeID) -> SIMD2<Double>)? = nil

    @inlinable
    init(
        _ graphRenderingContext: _GraphRenderingContext<NodeID>,
        _ forceField: consuming SealedForce2D,
        ticksPerSecond: Double = 60.0
    ) {
        self.graphRenderingContext = graphRenderingContext
        self.ticksPerSecond = ticksPerSecond
        self.simulationContext = .create(
            for: consume graphRenderingContext,
            with: consume forceField
        )
    }

    @inlinable
    deinit {
        stop()
    }

    @usableFromInline
    let _$observationRegistrar = Observation.ObservationRegistrar()
}

extension GraphicsContext.Shading {
    @inlinable
    static var defaultLinkShading: Self {
        return .color(.gray)
    }

    @inlinable
    static var defaultNodeShading: Self {
        return .color(.green)
    }
}

extension StrokeStyle {
    @inlinable
    static var defaultLinkStyle: Self {
        return StrokeStyle(lineWidth: 1.0)
    }
}

// Render related
extension ForceDirectedGraphModel {

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
            simulationContext.storage.tick()
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
    func render(
        _ graphicsContext: inout GraphicsContext,
        _ size: CGSize
    ) {
        // should not invoke `access`, but actually does now ?
        print("Rendering frame \(_$currentFrame.rawValue)")

        let transform = modelTransform.translate(by: size.simd / 2)

        var viewportPositions = [SIMD2<Double>]()
        viewportPositions.reserveCapacity(simulationContext.storage.kinetics.position.count)
        for i in simulationContext.storage.kinetics.position.range {
            viewportPositions.append(
                transform.apply(to: simulationContext.storage.kinetics.position[i])
            )
        }

        do {
            for op in graphRenderingContext.operations {
                switch op {
                case .link(let link, let shading, let strokeStyle, let pathBuilder):
                    let source = simulationContext.nodeIndexLookup[link.id.source]!
                    let target = simulationContext.nodeIndexLookup[link.id.target]!

                    let sourcePos = viewportPositions[source]
                    let targetPos = viewportPositions[target]

                    let p =
                        if let pathBuilder = pathBuilder {
                            pathBuilder(sourcePos, targetPos)
                        } else {
                            Path { path in
                                path.move(to: sourcePos.cgPoint)
                                path.addLine(to: targetPos.cgPoint)
                            }
                        }
                    graphicsContext.stroke(p, with: shading ?? .defaultLinkShading, style: strokeStyle ?? .defaultLinkStyle)
                    break
                default:
                    break
                }
            }
        }

        do {
            

            for op in graphRenderingContext.operations {
                switch op {
                case .node(let node, let shading, let strokeStyle, let pathBuilder):
                    let id = simulationContext.nodeIndexLookup[node.id]!
                    let pos = viewportPositions[id] - node.radius
                    let rect = CGRect(
                        origin: pos.cgPoint,
                        size: CGSize(
                            width: node.radius * 2, height: node.radius * 2
                        )
                    )
                    graphicsContext.fill(
                        Path(ellipseIn: rect), with: shading ?? .defaultNodeShading
                    )
                default:
                    break
                }
            }
        }

    }

    @inlinable
    func revive(
        for newContext: _GraphRenderingContext<NodeID>,
        with newForceField: consuming SealedForce2D
    ) {
        self.changeMessage =
            "gctx \(graphRenderingContext.nodes.count) -> \(newContext.nodes.count)"

        self.simulationContext.revive(for: newContext, with: newForceField)
        self.graphRenderingContext = newContext
        debugPrint("[REVIVED]")
    }

}
