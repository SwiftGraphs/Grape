import ForceSimulation
import Foundation
import Observation
import SwiftUI

@MainActor
public protocol _AnyGraphProxyProtocol {
    @inlinable
    func node(
        at locationInViewportCoordinate: CGPoint
    ) -> AnyHashable?

    @inlinable
    func node<ID: Hashable>(of type: ID.Type, at locationInViewportCoordinate: CGPoint) -> ID?

    @inlinable
    func setNodeFixation<ID: Hashable>(nodeID: ID, fixation: CGPoint?, minimumAlpha: Double)

    @inlinable
    var kineticAlpha: Double { get nonmutating set }

    @inlinable
    var finalTransform: ViewportTransform { get }

    @inlinable
    var modelTransform: ViewportTransform { get nonmutating set }

    @inlinable
    var lastTransformRecord: ViewportTransform? { get nonmutating set }

    @inlinable
    var obsoleteState: ObsoleteState { get nonmutating set }
}

extension ForceDirectedGraphModel: _AnyGraphProxyProtocol {

    @inlinable
    public func node<ID>(of type: ID.Type, at locationInViewportCoordinate: CGPoint) -> ID? where ID: Hashable {
        if type.self == NodeID.self {
            return findNode(at: locationInViewportCoordinate) as! ID?
        } else {
            return nil
        }
    }

    @inlinable
    public func node(at locationInViewportCoordinate: CGPoint) -> AnyHashable? {

        // Find from view annotation first
        if let nodeIDFromViewAnnotation = findNodeFromViewAnnotation(
            at: finalTransform.invert(locationInViewportCoordinate.simd)
        ) {
            if case .node(let nodeID) = nodeIDFromViewAnnotation {
                return AnyHashable(nodeID)
            }
        }

        if let nodeID = findNode(at: locationInViewportCoordinate) {
            return AnyHashable(nodeID)
        } else {
            return nil
        }
    }

    @inlinable
    public func setNodeFixation<ID>(nodeID: ID, fixation: CGPoint?, minimumAlpha: Double) {
        guard let nodeID = nodeID as? NodeID else {
            return
        }

        simulationContext.storage.kinetics.alpha = max(
            simulationContext.storage.kinetics.alpha,
            minimumAlpha
        )

        let newLocationInSimulation: SIMD2<Double>? =
            if let fixation {
                finalTransform.invert(fixation.simd)
            } else {
                nil
            }
        if let nodeIndex = simulationContext.nodeIndexLookup[nodeID] {
            simulationContext.storage.kinetics.fixation[nodeIndex] = newLocationInSimulation
        }
    }

    @inlinable
    public var kineticAlpha: Double {
        get {
            simulationContext.storage.kinetics.alpha
        }
        _modify {
            yield &simulationContext.storage.kinetics.alpha
        }
    }
}

public struct ObsoleteState {
    @usableFromInline
    var cgSize: CGSize

    @inlinable
    public init(cgSize: CGSize) {
        self.cgSize = cgSize
    }
}

@MainActor
public final class ForceDirectedGraphModel<NodeID: Hashable> {

    @usableFromInline
    var graphRenderingContext: _GraphRenderingContext<NodeID>

    @usableFromInline
    var simulationContext: SimulationContext<NodeID>

    @inlinable
    public var modelTransform: ViewportTransform {
        // @storageRestrictions(initializes: _modelTransform)
        // init(initialValue) {
        //     _modelTransform = initialValue
        // }

        get {
            stateMixinRef.modelTransform
        }

        set {
            // _modelTransform = newValue
            stateMixinRef.modelTransform = newValue
        }

    }

    /// Moves the zero-centered simulation to final view
    // @usableFromInline
    public var finalTransform: ViewportTransform = .identity

    @usableFromInline
    var viewportPositions: UnsafeArray<SIMD2<Double>>

    @usableFromInline
    var draggingNodeID: NodeID? = nil

    @usableFromInline
    var backgroundDragStart: SIMD2<Double>? = nil

    @inlinable
    var isDragStartStateRecorded: Bool {
        return draggingNodeID != nil || backgroundDragStart != nil
    }

    // records the transform right before a magnification gesture starts
    public var lastTransformRecord: ViewportTransform? = nil

    @usableFromInline
    var rasterizedSymbols: [(GraphRenderingStates<NodeID>.StateID, CGRect)] = []

    @usableFromInline
    let velocityDecay: Double

    // cache this so text size don't change on monitor switch
    @usableFromInline
    var lastRasterizedScaleFactor: Double = 2.0

    @usableFromInline
    var _$changeMessage = "N/A"

    @usableFromInline
    var _$currentFrame: UInt = 0

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
    var currentFrame: UInt {
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
    @MainActor
    var scheduledTimer: Timer? = nil

    @usableFromInline
    var _onTicked: ((UInt) -> Void)? = nil

    @usableFromInline
    var _onViewportTransformChanged: ((ViewportTransform, Bool) -> Void)? = nil

    @usableFromInline
    var _onSimulationStabilized: (() -> Void)? = nil

    @usableFromInline
    var _emittingNewNodesWith: (NodeID) -> KineticState

    // records the transform right before a magnification gesture starts
    public var obsoleteState = ObsoleteState(cgSize: .zero)

    @usableFromInline
    internal var stateMixinRef: ForceDirectedGraphState

    @inlinable
    init(
        _ graphRenderingContext: _GraphRenderingContext<NodeID>,
        forceDescriptor: SealedForceDescriptor<NodeID>,
        stateMixin: ForceDirectedGraphState,
        emittingNewNodesWith: @escaping (NodeID) -> KineticState = { _ in
            .init(position: .zero)
        },
        ticksPerSecond: Double,
        velocityDecay: Double
    ) {
        self.graphRenderingContext = graphRenderingContext
        self.ticksPerSecond = ticksPerSecond
        self._emittingNewNodesWith = emittingNewNodesWith
        self.velocityDecay = velocityDecay
        let _simulationContext = SimulationContext.create(
            for: graphRenderingContext,
            makeForceField: forceDescriptor._makeForceField,
            velocityDecay: velocityDecay
        )

        _simulationContext.updateAllKineticStates(emittingNewNodesWith)

        self.simulationContext = _simulationContext

        self.viewportPositions = .createUninitializedBuffer(
            count: self.simulationContext.storage.kinetics.position.count
        )
        self.currentFrame = 0
        self.stateMixinRef = stateMixin
    }

    @inlinable
    convenience init(
        _ graphRenderingContext: _GraphRenderingContext<NodeID>,
        forceDescriptor: SealedForceDescriptor<NodeID>,
        stateMixin: ForceDirectedGraphState,
        emittingNewNodesWith: @escaping (NodeID) -> KineticState = { _ in
            .init(position: .zero)
        },
        ticksPerSecond: Double
    ) {
        self.init(
            graphRenderingContext,
            forceDescriptor: forceDescriptor,
            stateMixin: stateMixin,
            emittingNewNodesWith: emittingNewNodesWith,
            ticksPerSecond: ticksPerSecond,
            velocityDecay: 30 / ticksPerSecond
        )
    }

    @inlinable
    func trackStateMixin() {
        Task { @MainActor [self] in
            switch stateMixinRef.ticksOnAppear {
            case .iteration(let count):
                simulationContext.storage.tick(ticks: .iteration(count))
            case .untilReachingAlpha(let alpha):
                simulationContext.storage.tick(ticks: .untilReachingAlpha(alpha))
            }
            withMutation(keyPath: \.currentFrame) {
                currentFrame += 1
            }
        }

        if stateMixinRef.isRunning {
            start()
        } else {
            stop()
        }
        continuouslyTrackingRunning()
        continuouslyTrackingTransform()
    }

    @inlinable
    func continuouslyTrackingRunning() {
        withObservationTracking { [weak self] in
            guard let self else { return }
            self.updateModelRunningState(isRunning: self.stateMixinRef.isRunning)
        } onChange: { @Sendable [weak self] in
            guard let self else { return }
            Task { @MainActor [weak self] in
                self?.continuouslyTrackingRunning()
            }
        }
    }

    @inlinable
    func continuouslyTrackingTransform() {
        withObservationTracking { [weak self] in
            guard let self else { return }
            // FIXME: mutation cycle?
            _ = self.stateMixinRef.modelTransform
            // stateMixinRef.access(keyPath: \.modelTransform)
        } onChange: { [weak self] in
            guard let self else { return }
            Task { @MainActor [weak self] in
                self?.continuouslyTrackingTransform()
            }
        }
    }

    @inlinable
    func updateModelRunningState(isRunning: Bool) {
        if stateMixinRef.isRunning {
            DispatchQueue.main.async { [weak self] in
                self?.start()
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.stop()
            }
        }
    }

    @inlinable
    deinit {
        print("deinit")

        let _ = MainActor.assumeIsolated {
            scheduledTimer?.invalidate()
        }
    }

    @usableFromInline
    let _$observationRegistrar = Observation.ObservationRegistrar()

}

extension GraphicsContext.Shading {
    @inlinable
    static var defaultLinkShading: Self {
        return .color(.displayP3, red: 0.5, green: 0.5, blue: 0.5, opacity: 0.3)
    }

    @inlinable
    static var defaultNodeShading: Self {
        return .color(.primary)
    }
}

extension StrokeStyle {
    @inlinable
    static var defaultLinkStyle: Self {
        return StrokeStyle(lineWidth: 1.0)
    }
}

// Render related
@MainActor
extension ForceDirectedGraphModel {

    @inlinable
    func start(minAlpha: Double = 0.6) {
        guard self.scheduledTimer == nil else { return }
        print("Simulation started")
        if simulationContext.storage.kinetics.alpha < minAlpha {
            simulationContext.storage.kinetics.alpha = minAlpha
        }

        self.scheduledTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0 / ticksPerSecond,
            repeats: true
        ) { [weak self] _ in
            if let capturedSelf = self {
                Task { @MainActor [weak capturedSelf] in
                    capturedSelf?.tick()
                }
            }
        }
    }

    @inlinable
    func tick() {
        withMutation(keyPath: \.currentFrame) {
            simulationContext.storage.tick()
            currentFrame += 1
        }
        _onTicked?(currentFrame)
    }

    @inlinable
    func stop() {
        print("Simulation stopped")
        self.scheduledTimer?.invalidate()
        self.scheduledTimer = nil
    }

    @inlinable
    func render(
        _ graphicsContext: inout GraphicsContext,
        _ size: CGSize
    ) {
        // should not invoke `access`, but actually does now ?
        // print("Rendering frame \(_$currentFrame.rawValue)")
        obsoleteState.cgSize = size

        let transform = modelTransform.translate(by: size.simd / 2)
        // debugPrint(transform.scale)

        // var viewportPositions = [SIMD2<Double>]()
        // viewportPositions.reserveCapacity(simulationContext.storage.kinetics.position.count)
        for i in simulationContext.storage.kinetics.position.range {
            viewportPositions[i] = transform.apply(
                to: simulationContext.storage.kinetics.position[i])
        }

        self.finalTransform = transform

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
                    {
                        let sourceNodeRadius =
                            sqrt(graphRenderingContext.nodeHitSizeAreaLookup[op.mark.id.source] ?? 0) / 2
                        let targetNodeRadius =
                            sqrt(graphRenderingContext.nodeHitSizeAreaLookup[op.mark.id.target] ?? 0) / 2
                        let angle = atan2(targetPos.y - sourcePos.y, targetPos.x - sourcePos.x)
                        let sourceOffset = SIMD2<Double>(
                            cos(angle) * sourceNodeRadius, sin(angle) * sourceNodeRadius
                        )
                        let targetOffset = SIMD2<Double>(
                            cos(angle) * targetNodeRadius, sin(angle) * targetNodeRadius
                        )

                        let sourcePosWithOffset = sourcePos + sourceOffset
                        let targetPosWithOffset = targetPos - targetOffset
                        // return pathBuilder(sourcePosWithOffset, targetPosWithOffset)
                        return pathBuilder(sourcePosWithOffset, targetPosWithOffset)
                    }()
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

            graphicsContext.transform = .init(translationX: pos.x, y: pos.y)

            let finalizedPath: Path =
                switch op.pathOrSymbolSize {
                case .path(let path): path
                case .symbolSize(let size):
                    Path(
                        ellipseIn: CGRect(
                            origin: CGPoint(x: -size.width / 2, y: -size.height / 2),
                            size: size
                        )
                    )
                }

            graphicsContext.fill(
                finalizedPath,
                with: op.fill ?? .defaultNodeShading
            )
            if let strokeEffect = op.stroke {
                switch strokeEffect.color {
                case .color(let color):
                    graphicsContext.stroke(
                        finalizedPath,
                        with: .color(color),
                        style: strokeEffect.style ?? .defaultLinkStyle
                    )
                case .clip:
                    graphicsContext.blendMode = .clear
                    graphicsContext.stroke(
                        finalizedPath,
                        with: .color(.black),
                        style: strokeEffect.style ?? .defaultLinkStyle
                    )
                    graphicsContext.blendMode = .normal
                }
            }
        }
        // return
        var newRasterizedSymbols = [(GraphRenderingStates<NodeID>.StateID, CGRect)]()
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
                    graphRenderingContext.symbols[resolvedTextContent] = .resolved(
                        text, cgImage)
                    rasterizedSymbol = cgImage
                case .resolved(_, let cgImage):
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

                        let rect = CGRect(
                            x: pos.x + offset.x + textImageOffset.x,  // - physicalWidth / 2,
                            y: -pos.y - offset.y - textImageOffset.y,  // - physicalHeight
                            width: physicalWidth,
                            height: physicalHeight
                        )
                        cgContext.draw(
                            rasterizedSymbol,
                            in: rect
                        )

                        newRasterizedSymbols.append((symbolID, rect))
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

                        let rect = CGRect(
                            x: center.x + offset.x + textImageOffset.x,  // - physicalWidth / 2,
                            y: -center.y - offset.y - textImageOffset.y,  // - physicalHeight
                            width: physicalWidth,
                            height: physicalHeight
                        )
                        cgContext.draw(
                            rasterizedSymbol,
                            in: rect
                        )

                        newRasterizedSymbols.append((symbolID, rect))
                    }
                }
            }

            for (symbolID, viewResolvingResult) in graphRenderingContext.resolvedViews {

                // Look for rasterized symbol's image
                var rasterizedSymbol: CGImage? = nil
                switch viewResolvingResult {
                case .pending(let view):
                    let resolved = viewResolvingResult.resolve(in: graphicsContext.environment)
                    graphRenderingContext.resolvedViews[symbolID] = .resolved(view, resolved)
                    rasterizedSymbol = resolved
                case .resolved(_, let cgImage):

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

                        let rect = CGRect(
                            x: pos.x + offset.x + textImageOffset.x,  // - physicalWidth / 2,
                            y: -pos.y - offset.y - textImageOffset.y,  // - physicalHeight
                            width: physicalWidth,
                            height: physicalHeight
                        )

                        cgContext.draw(
                            rasterizedSymbol,
                            in: rect
                        )

                        newRasterizedSymbols.append((symbolID, rect))
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

                        let rect = CGRect(
                            x: center.x + offset.x + textImageOffset.x,  // - physicalWidth / 2,
                            y: -center.y - offset.y - textImageOffset.y,  // - physicalHeight
                            width: physicalWidth,
                            height: physicalHeight
                        )

                        cgContext.draw(
                            rasterizedSymbol,
                            in: rect
                        )

                        newRasterizedSymbols.append((symbolID, rect))
                    }
                }
            }
        }

        rasterizedSymbols = newRasterizedSymbols
    }

    @inlinable
    static var textRasterizationAntialias: Double {
        return 1.5
    }

    @inlinable
    func revive(
        for newContext: _GraphRenderingContext<NodeID>,
        forceDescriptor: SealedForceDescriptor<NodeID>,
        alpha: Double
    ) {
        var newContext = newContext
        self.simulationContext.revive(
            for: newContext,
            makeForceField: forceDescriptor._makeForceField,
            velocityDecay: velocityDecay,
            emittingNewNodesWith: self._emittingNewNodesWith
        )
        self.simulationContext.storage.kinetics.alpha = alpha

        newContext.resolvedTexts = self.graphRenderingContext.resolvedTexts.merging(
            newContext.resolvedTexts
        ) { old, new in
            new
        }

        newContext.resolvedViews = self.graphRenderingContext.resolvedViews.merging(
            newContext.resolvedViews
        ) { _, new in
            new
        }

        newContext.symbols = self.graphRenderingContext.symbols.merging(
            newContext.symbols
        ) { old, new in
            old
        }

        self.graphRenderingContext = newContext

        /// Resize
        if self.simulationContext.storage.kinetics.position.count != self.viewportPositions.count {
            self.viewportPositions = .createUninitializedBuffer(
                count: self.simulationContext.storage.kinetics.position.count
            )
        }
        debugPrint(
            "Graph state revived. Note this might cause expensive rerendering when combined with `annotation` with non-text views and unstable id."
        )
    }

}
