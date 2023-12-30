import ForceSimulation
import Foundation
import Observation
import SwiftUI

// @Observable
public final class ForceDirectedGraphModel<NodeID: Hashable> {

    @usableFromInline
    var graphRenderingContext: _GraphRenderingContext<NodeID>

    @usableFromInline
    var simulationContext: SimulationContext<NodeID>

    @usableFromInline
    var modelTransform: ViewportTransform = .identity

    @usableFromInline
    var viewportPositions: UnsafeArray<SIMD2<Double>>

    // cache this so text size don't change on monitor switch
    @usableFromInline
    var lastRasterizedScaleFactor: Double = 2.0

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
    var _emittingNewNodesWith: (NodeID) -> KineticState

    @inlinable
    init(
        _ graphRenderingContext: _GraphRenderingContext<NodeID>,
        _ forceField: consuming SealedForce2D,
        emittingNewNodesWith: @escaping (NodeID) -> KineticState = { _ in
            .init(position: .zero)
        },
        ticksPerSecond: Double
    ) {
        self.graphRenderingContext = graphRenderingContext
        self.ticksPerSecond = ticksPerSecond
        self._emittingNewNodesWith = emittingNewNodesWith
        let _simulationContext = SimulationContext.create(
            for: consume graphRenderingContext,
            with: consume forceField
        )
        _simulationContext.updateAllKineticStates(emittingNewNodesWith)

        self.simulationContext = consume _simulationContext

        self.viewportPositions = .createUninitializedBuffer(
            count: self.simulationContext.storage.kinetics.position.count
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
    @MainActor
    func render(
        _ graphicsContext: inout GraphicsContext,
        _ size: CGSize
    ) {
        // should not invoke `access`, but actually does now ?
        print("Rendering frame \(_$currentFrame.rawValue)")

        let transform = modelTransform.translate(by: size.simd / 2)

        // var viewportPositions = [SIMD2<Double>]()
        // viewportPositions.reserveCapacity(simulationContext.storage.kinetics.position.count)
        for i in simulationContext.storage.kinetics.position.range {
            viewportPositions[i] = transform.apply(
                to: simulationContext.storage.kinetics.position[i])
        }

        for op in graphRenderingContext.linkOperations {

            guard let source = simulationContext.nodeIndexLookup[op.mark.id.source],
                let target = simulationContext.nodeIndexLookup[op.mark.id.target]
            else {
                continue
            }

            let sourcePos = viewportPositions[source]
            let targetPos = viewportPositions[target]

            let p =
                if let pathBuilder = op.path {
                    pathBuilder(sourcePos, targetPos)
                } else {
                    Path { path in
                        path.move(to: sourcePos.cgPoint)
                        path.addLine(to: targetPos.cgPoint)
                    }
                }
            if let strokeEffect = op.stroke {
                switch strokeEffect.color {
                case .color(let color):
                    graphicsContext.stroke(
                        p,
                        with: .color(color),
                        style: strokeEffect.style ?? .defaultLinkStyle
                    )
                case .clip:
                    break
                }
            } else {
                graphicsContext.stroke(
                    p, with: .defaultLinkShading,
                    style: .defaultLinkStyle
                )
            }
        }

        for op in graphRenderingContext.nodeOperations {
            guard let id = simulationContext.nodeIndexLookup[op.mark.id] else {
                continue
            }
            let pos = viewportPositions[id]
            if let path = op.path {
                graphicsContext.transform = .init(translationX: pos.x, y: pos.y)
                graphicsContext.fill(
                    path,
                    with: op.fill ?? .defaultNodeShading
                )
                if let strokeEffect = op.stroke {
                    switch strokeEffect.color {
                    case .color(let color):
                        graphicsContext.stroke(
                            path,
                            with: .color(color),
                            style: strokeEffect.style ?? .defaultLinkStyle
                        )
                    case .clip:
                        graphicsContext.blendMode = .clear
                        graphicsContext.stroke(
                            path,
                            with: .color(.black),
                            style: strokeEffect.style ?? .defaultLinkStyle
                        )
                        graphicsContext.blendMode = .normal
                    }
                }
            } else {
                graphicsContext.transform = .identity
                let rect = CGRect(
                    origin: (pos - op.mark.radius).cgPoint,
                    size: CGSize(
                        width: op.mark.radius * 2, height: op.mark.radius * 2
                    )
                )
                graphicsContext.fill(
                    Path(ellipseIn: rect),
                    with: op.fill ?? .defaultNodeShading
                )
            }
        }
        // return
        graphicsContext.transform = .identity.concatenating(CGAffineTransform(scaleX: 1, y: -1))
        graphicsContext.withCGContext { cgContext in

            for (symbolID, resolvedTextContent) in graphRenderingContext.resolvedTexts {

                guard let resolvedStatus = graphRenderingContext.symbols[resolvedTextContent]
                else { continue }

                // Look for rasterized symbol's image
                var rasterizedSymbol: CGImage? = nil
                switch resolvedStatus {
                case .pending(let text):
                    let env = graphicsContext.environment
                    let cgImage = text.toCGImage(
                        with: env,
                        antialias: Self.textRasterizationAntialias
                    )
                    lastRasterizedScaleFactor = env.displayScale
                    graphRenderingContext.symbols[resolvedTextContent] = .resolved(cgImage)
                    rasterizedSymbol = cgImage
                case .resolved(let cgImage):
                    rasterizedSymbol = cgImage
                }

                guard let rasterizedSymbol = rasterizedSymbol else {
                    continue
                }

                // Start drawing
                switch symbolID {
                case .node(let nodeID):
                    guard let id = simulationContext.nodeIndexLookup[nodeID] else {
                        continue
                    }
                    let pos = viewportPositions[id]
                    if let textOffsetParams = graphRenderingContext.textOffsets[symbolID] {
                        let offset = textOffsetParams.offset

                        let physicalWidth =
                            Double(rasterizedSymbol.width) / lastRasterizedScaleFactor
                            / Self.textRasterizationAntialias
                        let physicalHeight =
                            Double(rasterizedSymbol.height) / lastRasterizedScaleFactor
                            / Self.textRasterizationAntialias

                        let textImageOffset = textOffsetParams.alignment.textImageOffsetInCGContext(
                            width: physicalWidth, height: physicalHeight)

                        cgContext.draw(
                            rasterizedSymbol,
                            in: .init(
                                x: pos.x + offset.x + textImageOffset.x,  // - physicalWidth / 2,
                                y: -pos.y - offset.y - textImageOffset.y,  // - physicalHeight
                                width: physicalWidth,
                                height: physicalHeight
                            )
                        )
                    }

                case .link(let fromID, let toID):
                    guard let from = simulationContext.nodeIndexLookup[fromID],
                        let to = simulationContext.nodeIndexLookup[toID]
                    else {
                        continue
                    }
                    let center = (viewportPositions[from] + viewportPositions[to]) / 2
                    if let textOffsetParams = graphRenderingContext.textOffsets[symbolID] {
                        let offset = textOffsetParams.offset

                        let physicalWidth =
                            Double(rasterizedSymbol.width) / lastRasterizedScaleFactor
                            / Self.textRasterizationAntialias
                        let physicalHeight =
                            Double(rasterizedSymbol.height) / lastRasterizedScaleFactor
                            / Self.textRasterizationAntialias

                        let textImageOffset = textOffsetParams.alignment.textImageOffsetInCGContext(
                            width: physicalWidth, height: physicalHeight)

                        cgContext.draw(
                            rasterizedSymbol,
                            in: .init(
                                x: center.x + offset.x + textImageOffset.x,  // - physicalWidth / 2,
                                y: -center.y - offset.y - textImageOffset.y,  // - physicalHeight
                                width: physicalWidth,
                                height: physicalHeight
                            )
                        )

                    }
                }
            }
        }

    }

    @inlinable
    static var textRasterizationAntialias: Double {
        return 1.5
    }

    @inlinable
    func revive(
        for newContext: _GraphRenderingContext<NodeID>,
        with newForceField: consuming SealedForce2D
    ) {
        self.changeMessage =
            "gctx \(graphRenderingContext.nodes.count) -> \(newContext.nodes.count)"

        self.simulationContext.revive(
            for: newContext,
            with: newForceField,
            emittingNewNodesWith: self._emittingNewNodesWith
        )
        self.graphRenderingContext = newContext

        /// Resize
        if self.simulationContext.storage.kinetics.position.count != self.viewportPositions.count {
            self.viewportPositions = .createUninitializedBuffer(
                count: self.simulationContext.storage.kinetics.position.count
            )
        }
        debugPrint("[REVIVED]")
    }

}
