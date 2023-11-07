extension Kinetics {

    public enum LinkStiffness {
        case constant(Vector.Scalar)
        case varied((EdgeID<Int>, LinkLookup<Int>) -> Vector.Scalar)
        case weightedByDegree(k: (EdgeID<Int>, LinkLookup<Int>) -> Vector.Scalar)

        @inlinable
        func calculate(for link: [EdgeID<Int>], in lookup: LinkLookup<Int>) -> [Vector.Scalar] {
            switch self {
            case .constant(let m):
                return Array(repeating: m, count: link.count)
            case .varied(let f):
                return link.map { l in f(l, lookup) }
            case .weightedByDegree(let f):
                return link.map { l in f(l, lookup) }
            }
        }
    }

    public enum LinkLength {
        case constant(Vector.Scalar)
        case varied((EdgeID<Int>, LinkLookup<Int>) -> Vector.Scalar)

        @inlinable
        func calculate(for link: [EdgeID<Int>], in lookup: LinkLookup<Int>) -> [Vector.Scalar] {
            switch self {
            case .constant(let m):
                return Array(repeating: m, count: link.count)
            case .varied(let f):
                return link.map { l in f(l, lookup) }
            }
        }
    }

    public final class LinkForce: ForceProtocol {
        @usableFromInline
        internal var kinetics: Kinetics! = nil

        @usableFromInline
        var linkStiffness: LinkStiffness

        @usableFromInline
        var calculatedStiffness: [Vector.Scalar] = []

        @usableFromInline
        var linkLength: LinkLength

        @usableFromInline
        var calculatedLength: [Vector.Scalar] = []

        /// Bias
        @usableFromInline
        var calculatedBias: [Vector.Scalar] = []

        @inlinable
        public func apply() {
            // guard let sim = self.simulation else { return }

            // let alpha = sim.alpha

            for _ in 0..<iterationsPerTick {
                for i in links.indices {

                    let s = links[i].source
                    let t = links[i].target

                    let sp = kinetics.position[s]
                    let tp = kinetics.position[t]

                    let b = self.calculatedBias[i]

                    #if DEBUG
                        assert(b != 0)
                    #endif

                    var vec =
                        (tp + kinetics.velocity[t] - sp - kinetics.velocity[s])
                        .jiggled()

                    var l = (vec).length()

                    l = (l - self.calculatedLength[i]) / l * kinetics.alpha * self.calculatedStiffness[i]

                    vec *= l

                    // same as d3
                    kinetics.velocity[t] -= vec * b
                    kinetics.velocity[s] += vec * (1 - b)
                }
            }
        }

        @usableFromInline
        internal var links: [EdgeID<Int>]

        @usableFromInline
        internal var linkLookup: LinkLookup<Int> = .init(links: [])

        @inlinable
        public func bindKinetics(_ kinetics: Kinetics) {
            self.kinetics = kinetics
            self.links = self.links.filter {
                $0.source < kinetics.validCount && $0.target < kinetics.validCount
            }
            self.linkLookup = .init(links: self.links)
            self.calculatedBias = self.links.map { l in
                Vector.Scalar(self.linkLookup.count[l.source, default: 0])
                    / Vector.Scalar(
                        linkLookup.count[l.target, default: 0]
                            + linkLookup.count[l.source, default: 0])
            }

            self.calculatedStiffness = self.linkStiffness.calculate(
                for: self.links, in: self.linkLookup)
            self.calculatedLength = self.linkLength.calculate(for: self.links, in: self.linkLookup)
        }

        @usableFromInline var iterationsPerTick: UInt

        @inlinable
        internal init(
            _ links: [EdgeID<Int>],
            stiffness: LinkStiffness,
            originalLength: LinkLength = .constant(30),
            iterationsPerTick: UInt = 1
        ) {
            self.links = links
            self.iterationsPerTick = iterationsPerTick
            self.linkStiffness = stiffness
            self.linkLength = originalLength

        }
    }
}

public struct LinkLookup<NodeID: Hashable> {
    public let sourceToTarget: [NodeID: [NodeID]]
    public let targetToSource: [NodeID: [NodeID]]
    public let count: [NodeID: Int]

    @inlinable
    public init(links: [EdgeID<NodeID>]) {
        var sourceToTarget: [NodeID: [NodeID]] = [:]
        var targetToSource: [NodeID: [NodeID]] = [:]
        var count: [NodeID: Int] = [:]
        for link in links {
            sourceToTarget[link.source, default: []].append(link.target)
            targetToSource[link.target, default: []].append(link.source)
            count[link.source, default: 0] += 1
            count[link.target, default: 0] += 1
        }
        self.sourceToTarget = sourceToTarget
        self.targetToSource = targetToSource
        self.count = count
    }

}
