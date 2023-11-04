//
//  LinkForce.swift
//
//
//  Created by li3zhen1 on 10/16/23.
//

extension Force {
    /// A force that represents links between nodes.
    /// The complexity is `O(e)`, where `e` is the number of links.
    /// See [Link Force - D3](https://d3js.org/d3-force/link).
    final public class LinkForce<NodeID, V>: ForceProtocol
    where NodeID: Hashable, V: VectorLike, V.Scalar: SimulatableFloatingPoint {
        ///
        public enum LinkStiffness {
            case constant(V.Scalar)
            case varied((EdgeID<NodeID>, LinkLookup<NodeID>) -> V.Scalar)
            case weightedByDegree(k: (EdgeID<NodeID>, LinkLookup<NodeID>) -> V.Scalar)
        }
        @usableFromInline var linkStiffness: LinkStiffness
        @usableFromInline var calculatedStiffness: [V.Scalar] = []

        ///
        public typealias LengthScalar = V.Scalar
        public enum LinkLength {
            case constant(LengthScalar)
            case varied((EdgeID<NodeID>, LinkLookup<NodeID>) -> LengthScalar)
        }
        @usableFromInline var linkLength: LinkLength
        @usableFromInline var calculatedLength: [LengthScalar] = []

        /// Bias
        @usableFromInline var calculatedBias: [V.Scalar] = []

        /// Binding to simulation
        ///
        @usableFromInline weak var simulation: SimulationState<NodeID, V>?

        @inlinable
        public func bindSimulation(_ simulation: SimulationState<NodeID, V>?) {

            self.simulation = simulation
            guard let sim = self.simulation else { return }

            linksOfIndices = links.map { l in
                EdgeID(
                    sim.nodeIdToIndexLookup[l.source, default: 0],
                    sim.nodeIdToIndexLookup[l.target, default: 0]
                )
            }

            self.lookup = .buildFromLinks(linksOfIndices)

            self.calculatedBias = linksOfIndices.map { l in
                V.Scalar(lookup.count[l.source, default: 0])
                    / V.Scalar(
                        lookup.count[l.target, default: 0] + lookup.count[l.source, default: 0])
            }

            let lookupWithOriginalID = LinkLookup.buildFromLinks(links)
            self.calculatedLength = linkLength.calculated(
                for: self.links, connectionLookupTable: lookupWithOriginalID)
            self.calculatedStiffness = linkStiffness.calculated(
                for: self.links, connectionLookupTable: lookupWithOriginalID)
        }

        @usableFromInline var iterationsPerTick: UInt

        @usableFromInline internal var linksOfIndices: [EdgeID<Int>] = []
        @usableFromInline var links: [EdgeID<NodeID>]

        @usableFromInline var lookup = LinkLookup<Int>(sources: [:], targets: [:], count: [:])

        @inlinable internal init(
            _ links: [EdgeID<NodeID>],
            stiffness: LinkStiffness,
            originalLength: LinkLength = .constant(30),
            iterationsPerTick: UInt = 1
        ) {
            self.links = links
            self.iterationsPerTick = iterationsPerTick
            self.linkStiffness = stiffness
            self.linkLength = originalLength
        }

        @inlinable public func apply() {

            guard let sim = self.simulation else { return }

            let alpha = sim.alpha

            for _ in 0..<iterationsPerTick {
                for i in links.indices {

                    let s = linksOfIndices[i].source
                    let t = linksOfIndices[i].target

                    let _source = sim.nodePositions[s]
                    let _target = sim.nodePositions[t]

                    let b = self.calculatedBias[i]

                    #if DEBUG
                        assert(b != 0)
                    #endif

                    var vec = (_target + sim.nodeVelocities[t] - _source - sim.nodeVelocities[s])
                        .jiggled()

                    var l = vec.length()

                    l = (l - self.calculatedLength[i]) / l * alpha * self.calculatedStiffness[i]

                    vec *= l

                    // same as d3
                    sim.nodeVelocities[t] -= vec * b
                    sim.nodeVelocities[s] += vec * (1 - b)

                    //                sim.nodeVelocities[s] += vec * b
                    //                sim.nodeVelocities[t] -= vec * (1 - b)

                }
            }
        }

    }

}
/// Create a link force that represents links between nodes. It works like
/// there is a spring between each pair of nodes.
/// The complexity is `O(e)`, where `e` is the number of links.
/// See [Collide Force - D3](https://d3js.org/d3-force/collide)
/// - Parameters:
///  - links: The links between nodes.
///  - stiffness: The stiffness of the spring (or links).
///  - originalLength: The original length of the spring (or links).
// @discardableResult
// @inlinable public func withLinkForce(
//     _ links: [EdgeID<NodeID>],
//     stiffness: LinkForce.LinkStiffness = .weightedByDegree { _, _ in 1.0 },
//     originalLength: LinkForce.LinkLength = .constant(30.0),
//     iterationsPerTick: UInt = 1
// ) -> LinkForce {
//     let linkForce = LinkForce(
//         links, stiffness: stiffness, originalLength: originalLength)
//     linkForce.simulation = self
//     linkForce.didSetSimulation(sim: self)
//     self.forces.append(linkForce)
//     return linkForce
// }

/// Create a link force that represents links between nodes. It works like
/// there is a spring between each pair of nodes.
/// The complexity is `O(e)`, where `e` is the number of links.
/// See [Link Force - D3](https://d3js.org/d3-force/link).
/// - Parameters:
///  - links: The links between nodes.
///  - stiffness: The stiffness of the spring (or links).
///  - originalLength: The original length of the spring (or links).
// @discardableResult
// @inlinable public func withLinkForce(
//     _ linkTuples: [(NodeID, NodeID)],
//     stiffness: LinkForce.LinkStiffness = .weightedByDegree { _, _ in 1.0 },
//     originalLength: LinkForce.LinkLength = .constant(30.0),
//     iterationsPerTick: UInt = 1
// ) -> LinkForce {
//     let links = linkTuples.map { EdgeID($0.0, $0.1) }
//     let linkForce = LinkForce(
//         links, stiffness: stiffness, originalLength: originalLength)
//     linkForce.simulation = self
//     linkForce.didSetSimulation(sim: self)
//     self.forces.append(linkForce)
//     return linkForce
// }

extension LinkLookup {
    @inlinable static func buildFromLinks(_ links: [EdgeID<NodeID>]) -> Self {
        var sources: [NodeID: [NodeID]] = [:]
        var targets: [NodeID: [NodeID]] = [:]
        var count: [NodeID: Int] = [:]
        for link in links {
            sources[link.source, default: []].append(link.target)
            targets[link.target, default: []].append(link.source)
            count[link.source, default: 0] += 1
            count[link.target, default: 0] += 1
        }
        return LinkLookup(sources: sources, targets: targets, count: count)
    }
}

extension Force.LinkForce.LinkLength {
    @inlinable func calculated(
        for links: [EdgeID<NodeID>],
        connectionLookupTable: LinkLookup<NodeID>
    ) -> [V.Scalar] {
        switch self {
        case .constant(let value):
            return links.map { _ in value }
        case .varied(let f):
            return links.map { link in
                f(link, connectionLookupTable)
            }
        }
    }
}

extension Force.LinkForce.LinkStiffness {
    @inlinable func calculated(
        for links: [EdgeID<NodeID>],
        connectionLookupTable lookup: LinkLookup<NodeID>
    ) -> [V.Scalar] {
        switch self {
        case .constant(let value):
            return links.map { _ in value }
        case .varied(let f):
            return links.map { link in
                f(link, lookup)
            }
        case .weightedByDegree(let k):
            return links.map { link in
                k(link, lookup)
                    / V.Scalar(
                        min(
                            lookup.count[link.source, default: 0],
                            lookup.count[link.target, default: 0]
                        )
                    )
            }
        }
    }
}

extension Simulation {
    @inlinable
    public func withLinkForce(
        _ links: [EdgeID<NodeID>],
        stiffness: Force.LinkForce<NodeID, V>.LinkStiffness = .weightedByDegree { _, _ in 1.0 },
        originalLength: Force.LinkForce<NodeID, V>.LinkLength = .constant(30.0),
        iterationsPerTick: UInt = 1
    ) -> Simulation<
        NodeID, V, Force.ForceField<NodeID, V, F, Force.LinkForce<NodeID, V>>
    > where F.NodeID == NodeID, F.V == V {
        let f = Force.LinkForce(
            links, stiffness: stiffness, originalLength: originalLength,
            iterationsPerTick: iterationsPerTick)
        // f.bindSimulation(self.state)
        return with(f)
    }

    @inlinable
    public func withLinkForce(
        _ linkTuples: [(NodeID, NodeID)],
        stiffness: Force.LinkForce<NodeID, V>.LinkStiffness = .weightedByDegree { _, _ in 1.0 },
        originalLength: Force.LinkForce<NodeID, V>.LinkLength = .constant(30.0),
        iterationsPerTick: UInt = 1
    ) -> Simulation<
        NodeID, V, Force.ForceField<NodeID, V, F, Force.LinkForce<NodeID, V>>
    > where F.NodeID == NodeID, F.V == V {
        let links = linkTuples.map { EdgeID($0.0, $0.1) }
        let f = Force.LinkForce(
            links, stiffness: stiffness, originalLength: originalLength,
            iterationsPerTick: iterationsPerTick)
        //        f.bindSimulation(self.simulation)
        return with(f)
    }
}

public struct LinkLookup<NodeID> where NodeID: Hashable {
    @usableFromInline let sources: [NodeID: [NodeID]]
    @usableFromInline let targets: [NodeID: [NodeID]]
    @usableFromInline let count: [NodeID: Int]

    @inlinable init(
        sources: [NodeID: [NodeID]], targets: [NodeID: [NodeID]], count: [NodeID: Int]
    ) {
        self.sources = sources
        self.targets = targets
        self.count = count
    }
}
