//
//  LinkForce.swift
//
//
//  Created by li3zhen1 on 10/16/23.
//

import NDTree

enum LinkForceError: Error {
    case useBeforeSimulationInitialized
}

/// A force that represents links between nodes.
/// The complexity is `O(e)`, where `e` is the number of links.
/// See [Link Force - D3](https://d3js.org/d3-force/link).
final public class LinkForce<NodeID, V>: ForceLike
where NodeID: Hashable, V: VectorLike, V.Scalar == Double {

    ///
    public enum LinkStiffness {
        case constant(Double)
        case varied((EdgeID<NodeID>, LinkLookup<NodeID>) -> Double)
        case weightedByDegree(k: (EdgeID<NodeID>, LinkLookup<NodeID>) -> Double)
    }
    var linkStiffness: LinkStiffness
    var calculatedStiffness: [Double] = []

    ///
    public typealias LengthScalar = V.Scalar
    public enum LinkLength {
        case constant(LengthScalar)
        case varied((EdgeID<NodeID>, LinkLookup<NodeID>) -> LengthScalar)
    }
    var linkLength: LinkLength
    var calculatedLength: [LengthScalar] = []

    /// Bias
    var calculatedBias: [Double] = []

    /// Binding to simulation
    ///
    weak var simulation: Simulation<NodeID, V>? {
        didSet {

            guard let sim = simulation else { return }

            linksOfIndices = links.map { l in
                EdgeID(
                    sim.nodeIdToIndexLookup[l.source, default: 0],
                    sim.nodeIdToIndexLookup[l.target, default: 0]
                )
            }

            self.lookup = .buildFromLinks(linksOfIndices)

            self.calculatedBias = linksOfIndices.map { l in
                Double(lookup.count[l.source, default: 0])
                    / Double(
                        lookup.count[l.target, default: 0] + lookup.count[l.source, default: 0])
            }

            let lookupWithOriginalID = LinkLookup.buildFromLinks(links)
            self.calculatedLength = linkLength.calculated(
                for: self.links, connectionLookupTable: lookupWithOriginalID)
            self.calculatedStiffness = linkStiffness.calculated(
                for: self.links, connectionLookupTable: lookupWithOriginalID)
        }
    }

    var iterationsPerTick: UInt

    internal var linksOfIndices: [EdgeID<Int>] = []
    var links: [EdgeID<NodeID>]

    public struct LinkLookup<_NodeID> where _NodeID: Hashable {
        let sources: [_NodeID: [_NodeID]]
        let targets: [_NodeID: [_NodeID]]
        let count: [_NodeID: Int]
    }
    private var lookup = LinkLookup<Int>(sources: [:], targets: [:], count: [:])

    internal init(
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

    public func apply(alpha: Double) {
        guard let sim = self.simulation else { return }

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

extension LinkForce.LinkLookup {
    static func buildFromLinks(_ links: [EdgeID<_NodeID>]) -> Self {
        var sources: [_NodeID: [_NodeID]] = [:]
        var targets: [_NodeID: [_NodeID]] = [:]
        var count: [_NodeID: Int] = [:]
        for link in links {
            sources[link.source, default: []].append(link.target)
            targets[link.target, default: []].append(link.source)
            count[link.source, default: 0] += 1
            count[link.target, default: 0] += 1
        }
        return Self(sources: sources, targets: targets, count: count)
    }
}

protocol PrecalculatableEdgeProperty {
    associatedtype NodeID: Hashable
    associatedtype V: VectorLike where V.Scalar == Double
    func calculated(
        for links: [EdgeID<NodeID>], connectionLookupTable: LinkForce<NodeID, V>.LinkLookup<NodeID>
    ) -> [Double]
}

extension LinkForce.LinkLength: PrecalculatableEdgeProperty {
    func calculated(
        for links: [EdgeID<NodeID>], connectionLookupTable: LinkForce<NodeID, V>.LinkLookup<NodeID>
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

extension LinkForce.LinkStiffness: PrecalculatableEdgeProperty {
    func calculated(
        for links: [EdgeID<NodeID>],
        connectionLookupTable lookup: LinkForce<NodeID, V>.LinkLookup<NodeID>
    ) -> [Double] {
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
                    / Double(
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

    /// Create a link force that represents links between nodes. It works like
    /// there is a spring between each pair of nodes.
    /// The complexity is `O(e)`, where `e` is the number of links.
    /// See [Collide Force - D3](https://d3js.org/d3-force/collide)
    /// - Parameters:
    ///  - links: The links between nodes.
    ///  - stiffness: The stiffness of the spring (or links).
    ///  - originalLength: The original length of the spring (or links).
    @discardableResult
    public func createLinkForce(
        _ links: [EdgeID<NodeID>],
        stiffness: LinkForce<NodeID, V>.LinkStiffness = .weightedByDegree { _, _ in 1.0 },
        originalLength: LinkForce<NodeID, V>.LinkLength = .constant(30),
        iterationsPerTick: UInt = 1
    ) -> LinkForce<NodeID, V> {
        let linkForce = LinkForce<NodeID, V>(
            links, stiffness: stiffness, originalLength: originalLength)
        linkForce.simulation = self
        self.forces.append(linkForce)
        return linkForce
    }

    /// Create a link force that represents links between nodes. It works like
    /// there is a spring between each pair of nodes.
    /// The complexity is `O(e)`, where `e` is the number of links.
    /// See [Link Force - D3](https://d3js.org/d3-force/link).
    /// - Parameters:
    ///  - links: The links between nodes.
    ///  - stiffness: The stiffness of the spring (or links).
    ///  - originalLength: The original length of the spring (or links).
    @discardableResult
    public func createLinkForce(
        _ linkTuples: [(NodeID, NodeID)],
        stiffness: LinkForce<NodeID, V>.LinkStiffness = .weightedByDegree { _, _ in 1.0 },
        originalLength: LinkForce<NodeID, V>.LinkLength = .constant(30),
        iterationsPerTick: UInt = 1
    ) -> LinkForce<NodeID, V> {
        let links = linkTuples.map { EdgeID($0.0, $0.1) }
        let linkForce = LinkForce<NodeID, V>(
            links, stiffness: stiffness, originalLength: originalLength)
        linkForce.simulation = self
        self.forces.append(linkForce)
        return linkForce
    }
}
