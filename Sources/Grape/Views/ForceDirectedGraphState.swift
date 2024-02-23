import Observation

// public typealias ForceDirectedGraphState = ForceDirectedGraphMixedState<Void>

// extension ForceDirectedGraphMixedState where Mixin == Void {
//     @inlinable
//     convenience init(
//         initialIsRunning: Bool = true,
//         initialModelTransform: ViewportTransform = .identity
//     ) {
//         self.init(
//             initialMixin: (),
//             initialIsRunning: initialIsRunning,
//             initialModelTransform: initialModelTransform
//         )
//     }
// }

public class ForceDirectedGraphState: Observation.Observable {

    @usableFromInline
    internal var _$modelTransform: ViewportTransform

    @usableFromInline
    internal var _$isRunning: Bool

    @inlinable
    public var modelTransform: ViewportTransform {
        get {
            _reg.access(self, keyPath: \.modelTransform)
            return _$modelTransform
        }
        set {
            _reg.withMutation(of: self, keyPath: \.modelTransform) {
                _$modelTransform = newValue
            }
        }
    }

    @inlinable
    public var isRunning: Bool {
        get {
            _reg.access(self, keyPath: \.isRunning)
            return _$isRunning
        }
        set {
            _reg.withMutation(of: self, keyPath: \.isRunning) {
                _$isRunning = newValue
            }
        }
    }

    @inlinable
    public init(
        initialIsRunning: Bool = true,
        initialModelTransform: ViewportTransform = .identity
    ) {
        self._reg = Observation.ObservationRegistrar()
        self._$modelTransform = initialModelTransform
        self._$isRunning = initialIsRunning
    }

    // MARK: - Observation

    @usableFromInline
    let _reg: Observation.ObservationRegistrar
}
