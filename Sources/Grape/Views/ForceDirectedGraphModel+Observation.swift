import Observation

extension ForceDirectedGraphModel: Observation.Observable {

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
