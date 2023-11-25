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
            case .weightedByDegree(let k):
                return link.map { l in
                    k(l, lookup)
                        / Vector.Scalar(
                            min(
                                lookup.count[l.source, default: 0],
                                lookup.count[l.target, default: 0]
                            )
                        )
                }
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

    /// A force that represents links between nodes.
    ///
    /// The complexity is `O(e)`, where `e` is the number of links.
    /// See [Link Force - D3](https://d3js.org/d3-force/link).
    public struct LinkForce: ForceProtocol {
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
            let positionBufferPointer = kinetics.position.mutablePointer
            let velocityBufferPointer = kinetics.velocity.mutablePointer
            for _ in 0..<iterationsPerTick {
                for i in links.indices {

                    let s = links[i].source
                    let t = links[i].target

                    let b = self.calculatedBias[i]

                    assert(b != 0)

                    var vec =
                        (positionBufferPointer[t] + velocityBufferPointer[t] 
                        - positionBufferPointer[s] - velocityBufferPointer[s])
                        .jiggled()

                    var l = vec.length()

                    l =
                        (l - self.calculatedLength[i]) / l * kinetics.alpha
                        * self.calculatedStiffness[i]

                    vec *= l

                    // same as d3
                    velocityBufferPointer[t] -= vec * b
                    velocityBufferPointer[s] += vec * (1 - b)
                }
            }
        }

        @usableFromInline
        internal var links: [EdgeID<Int>]! = nil

        @usableFromInline
        internal var linkLookup: LinkLookup<Int> = .init(links: [])

        @inlinable
        public mutating func bindKinetics(_ kinetics: Kinetics) {
            self.kinetics = kinetics
            self.links = kinetics.links
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
        public init(
            // _ links: [EdgeID<Int>],
            stiffness: LinkStiffness,
            originalLength: LinkLength = .constant(30),
            iterationsPerTick: UInt = 1
        ) {
            // self.links = links
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
