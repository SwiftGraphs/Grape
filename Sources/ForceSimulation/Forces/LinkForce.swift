extension Kinetics {

    public final class LinkForce: ForceProtocol {
        @usableFromInline
        internal var kinetics: Kinetics! = nil

        @inlinable
        public func apply() {

        }

        @usableFromInline
        internal var links: [EdgeID<Int>]

        @usableFromInline
        internal var linkLookup: LinkLookup<Int> = .init(links: [])

        @inlinable
        public func bindKinetics(_ kinetics: Kinetics) {
            self.kinetics = kinetics
            self.linkLookup = .init(
                links: self.links.filter {
                    $0.source < kinetics.validCount && $0.target < kinetics.validCount
                }
            )
        }

        @inlinable
        internal init(links: [EdgeID<Int>]) {
            self.links = links
        }
    }
}

public struct LinkLookup<NodeID: Hashable> {
    public let sourceToTarget: [NodeID: [NodeID]]
    public let targetToSource: [NodeID: [NodeID]]

    @inlinable
    public init(links: [EdgeID<NodeID>]) {
        var sourceToTarget: [NodeID: [NodeID]] = [:]
        var targetToSource: [NodeID: [NodeID]] = [:]
        for link in links {
            sourceToTarget[link.source, default: []].append(link.target)
            targetToSource[link.target, default: []].append(link.source)
        }
        self.sourceToTarget = sourceToTarget
        self.targetToSource = targetToSource
    }

}
