import Observation

public class ForceDirectedGraphState: Observation.Observable {

    @usableFromInline
    internal var _$modelTransform: ViewportTransform


    @usableFromInline
    internal var _$isRunning: Bool



    @inlinable
    public var modelTransform: ViewportTransform {
        get {
            access(keyPath: \.modelTransform)
            return _$modelTransform
        }
        set {
            withMutation(keyPath: \.modelTransform) {
                _$modelTransform = newValue
            }
        }
    }

    @inlinable
    public var isRunning: Bool {
        get {
            access(keyPath: \.isRunning)
            return _$isRunning
        }
        set {
            withMutation(keyPath: \.isRunning) {
                _$isRunning = newValue
            }
        }
    }

    @inlinable
    public init(
        initialIsRunning: Bool = true,
        initialModelTransform: ViewportTransform = .identity
    ) {
        self._$modelTransform = initialModelTransform
        self._$isRunning = initialIsRunning
    }

    // MARK: - Observation

    @usableFromInline
    let _$observationRegistrar = Observation.ObservationRegistrar()

    @inlinable
    nonisolated func access<Member>(
        keyPath: KeyPath<ForceDirectedGraphState, Member>
    ) {
        _$observationRegistrar.access(self, keyPath: keyPath)
    }

    @inlinable
    nonisolated func withMutation<Member, MutationResult>(
        keyPath: KeyPath<ForceDirectedGraphState, Member>,
        _ mutation: () throws -> MutationResult
    ) rethrows -> MutationResult {
        try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
    }
}
