//
//  File.swift
//
//
//  Created by li3zhen1 on 10/1/23.
//

import Foundation
import QuadTree

enum LinkForceError: Error {
    case useBeforeSimulationInitialized
}

final public class LinkForce<N>: Force where N: Identifiable {

    public class LinkLookup {
        public let source: [N.ID: [N.ID]]
        public let target: [N.ID: [N.ID]]
        public let count: [N.ID: Int]

        init(_ source: [N.ID: [N.ID]], _ target: [N.ID: [N.ID]], _ count: [N.ID: Int]) {
            self.source = source
            self.target = target
            self.count = count
        }
    }
    var links: [EdgeID<N.ID>] {
        didSet {

            var sources: [N.ID: [N.ID]] = [:]
            var targets: [N.ID: [N.ID]] = [:]
            var count: [N.ID: Int] = [:]
            for link in self.links {
                sources[link.source, default: []].append(link.target)
                targets[link.target, default: []].append(link.source)
                count[link.source, default: 0] += 1
                count[link.target, default: 0] += 1
            }
            self.linkLookup = LinkLookup(sources, targets, count)

            calculatedBias = links.map { l in
                Double(linkLookup.count[l.source, default: 0])
                    / Double(
                        linkLookup.count[l.target, default: 0]
                            + linkLookup.count[l.source, default: 0]
                    )
            }

            calculatedLength = self.length.calculated(self.links, self.linkLookup)

            calculatedStiffness = self.stiffness.calculated(self.links, self.linkLookup)

        }
    }

    public var linkLookup = LinkLookup([:], [:], [:])

    /// Stiffness accessor
    public enum LinkStiffness {
        case constant(Double)
        case varied((EdgeID<N.ID>, /*inout*/ LinkLookup) -> Double)
    }
    var stiffness: LinkStiffness
    var calculatedStiffness: [Double] = []

    /// Length accessor
    public enum LinkLength {
        case constant(Double)
        case varied((EdgeID<N.ID>, /*inout*/ LinkLookup) -> Double)
    }
    var length: LinkLength
    var calculatedLength: [Double] = []

    /// Bias
    var calculatedBias: [Double] = []
    weak var simulation: Simulation<N>?

    var iterations: Int

    internal init(
        _ links: [EdgeID<N.ID>],
        stiffness: LinkStiffness? = nil,
        originalLength: LinkLength = .constant(30),
        iterations: Int = 1
    ) {
        self.links = links
        self.iterations = iterations
        self.stiffness = stiffness ?? defaultStiffness
        self.length = originalLength

        var sources: [N.ID: [N.ID]] = [:]
        var targets: [N.ID: [N.ID]] = [:]
        var count: [N.ID: Int] = [:]
        for link in self.links {
            sources[link.source, default: []].append(link.target)
            targets[link.target, default: []].append(link.source)
            count[link.source, default: 0] += 1
            count[link.target, default: 0] += 1
        }
        self.linkLookup = LinkLookup(sources, targets, count)

        calculatedBias = links.map { l in
            Double(linkLookup.count[l.source, default: 0])
                / Double(
                    linkLookup.count[l.target, default: 0] + linkLookup.count[l.source, default: 0]
                )
        }

        calculatedLength = self.length.calculated(self.links, self.linkLookup)
        calculatedStiffness = self.stiffness.calculated(self.links, self.linkLookup)
    }

    public func apply(alpha: Double) {
        guard let sim = self.simulation else { return }

        var position: Vector2f
        var l: Double

        for _ in 0..<iterations {

            for i in links.indices {
                let sourceId = links[i].source
                let targetId = links[i].target

                if let sourceNodeIndexInSim = sim.nodeIndexLookup[sourceId],
                    let targetNodeIndexInSim = sim.nodeIndexLookup[targetId]
                {
                    let source = sim.simulationNodes[sourceNodeIndexInSim]
                    let target = sim.simulationNodes[targetNodeIndexInSim]

                    let b = self.calculatedBias[i]

                    position =
                        (target.position + target.velocity - source.position - source.velocity)
                        .jiggled()

                    l = position.length()

                    l = (l - self.calculatedLength[i]) / l * alpha * self.calculatedStiffness[i]

                    position *= l

                    sim.simulationNodes[sourceNodeIndexInSim].velocity += position * b
                    sim.simulationNodes[targetNodeIndexInSim].velocity -= position * (1 - b)
                }

                //                if let source = sim.getNode(sourceId),
                //                   let target = sim.getNode(targetId) {
                //
                //                    position = (target.position + target.velocity - source.position - source.velocity)
                //                        .jiggled()
                //
                //                    l = position.length()
                //
                //
                //                    l = (l - self.calculatedLength[i]) / l * alpha * self.calculatedStiffness[i]
                //
                //                    position *= l
                //
                //                    sim.updateNode(nodeId: sourceId) { n in
                //                        n.velocity += position * b
                //                    }
                //                    sim.updateNode(nodeId: targetId) { n in
                //                        n.velocity -= position * (1 - b)
                //                    }
                //
                //                }
            }

        }
    }

    public let defaultStiffness: LinkStiffness = .varied { link, lookup in
        1
            / Double(
                min(
                    lookup.count[link.source, default: 0],
                    lookup.count[link.target, default: 0]
                )
            )
    }

}

extension LinkForce {
    internal static func create(
        _ links: [(N.ID, N.ID)],
        stiffness: LinkStiffness? = nil,
        originalLength: LinkLength = .constant(30),
        iterations: Int = 1
    ) -> LinkForce {
        return LinkForce(
            links.map { EdgeID($0.0, $0.1) }, stiffness: stiffness, originalLength: originalLength,
            iterations: iterations)
    }
}

extension Simulation {

    @discardableResult
    public func createLinkForce(
        links: [EdgeID<N.ID>]
    ) -> LinkForce<N> {
        let linkForce = LinkForce<N>(links)
        linkForce.simulation = self
        self.forces.append(linkForce)
        return linkForce
    }

    @discardableResult
    public func createLinkForce(
        links: [(N.ID, N.ID)]
    ) -> LinkForce<N> {
        let linkForce = LinkForce<N>.create(links)
        linkForce.simulation = self
        self.forces.append(linkForce)
        return linkForce
    }

    @discardableResult
    public func createLinkForce(
        links: [EdgeID<N.ID>],
        stiffness: Double,
        originalLength: Double
    ) -> LinkForce<N> {
        let linkForce = LinkForce<N>(
            links, stiffness: .constant(stiffness), originalLength: .constant(originalLength))
        linkForce.simulation = self
        self.forces.append(linkForce)
        return linkForce
    }

    @discardableResult
    public func createLinkForce(
        links: [(N.ID, N.ID)],
        stiffness: Double
    ) -> LinkForce<N> {
        let linkForce = LinkForce<N>.create(links, stiffness: .constant(stiffness))
        linkForce.simulation = self
        self.forces.append(linkForce)
        return linkForce
    }

    @discardableResult
    public func createLinkForce(
        links: [EdgeID<N.ID>],
        stiffness: LinkForce<N>.LinkStiffness? = nil,  //@escaping(EdgeID<N.ID>, LinkForce<N>.LinkLookup) -> Double,
        originalLength: LinkForce<N>.LinkLength = .constant(30)
    ) -> LinkForce<N> {
        let linkForce = LinkForce<N>(links, stiffness: stiffness, originalLength: originalLength)
        linkForce.simulation = self
        self.forces.append(linkForce)
        return linkForce
    }

    @discardableResult
    public func createLinkForce(
        links: [(N.ID, N.ID)],
        stiffness: LinkForce<N>.LinkStiffness? = nil,  //@escaping(EdgeID<N.ID>, LinkForce<N>.LinkLookup) -> Double,
        originalLength: LinkForce<N>.LinkLength = .constant(30)
    ) -> LinkForce<N> {
        let linkForce = LinkForce<N>.create(
            links, stiffness: stiffness, originalLength: originalLength)
        linkForce.simulation = self
        self.forces.append(linkForce)
        return linkForce
    }

}

extension LinkForce.LinkStiffness {
    func calculated(_ links: [EdgeID<N.ID>], _ linkLookup: LinkForce.LinkLookup) -> [Double] {
        switch self {
        case .constant(let value):
            return links.map { _ in value }
        case .varied(let f):
            return links.map { link in
                f(link, linkLookup)
            }
        }
    }
}

extension LinkForce.LinkLength {
    func calculated(_ links: [EdgeID<N.ID>], _ linkLookup: LinkForce.LinkLookup) -> [Double] {
        switch self {
        case .constant(let value):
            return links.map { _ in value }
        case .varied(let f):
            return links.map { link in
                f(link, linkLookup)
            }
        }
    }
}
