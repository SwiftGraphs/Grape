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

public class LinkForce<VID> : Force where VID : Hashable {

    var random = LinearCongruentialGenerator()

    public class LinkLookup {
        public let source: [VID: [VID]]
        public let target: [VID: [VID]]
        public let count: [VID: Int]

        init(_ source: [VID: [VID]], _ target: [VID: [VID]], _ count: [VID: Int]) {
            self.source = source
            self.target = target
            self.count = count
        }
    }
    var links: [EdgeID<VID>] 
    public var linkLookup: LinkLookup {
        get {
            var sources: [VID: [VID]] = [:]
            var targets: [VID: [VID]] = [:]
            var count: [VID: Int] = [:]
            for link in self.links {
                sources[link.source, default: []].append(link.target)
                targets[link.target, default: []].append(link.source)
                count[link.source, default: 0] += 1
                count[link.target, default: 0] += 1
            }
            return LinkLookup(sources, targets, count)
        }
    }




    /// Stiffness accessor
    public enum LinkStiffness {
        case constant(Float)
        case varied( (EdgeID<VID>, /*inout*/ LinkLookup) -> Float )
    }
    var stiffness: LinkStiffness
    var calculatedStiffness: [Float] {
        get {
            return self.stiffness.calculated(self.links, self.linkLookup)
        }
    }



    /// Length accessor
    public enum LinkLength {
        case constant(Float)
        case varied( (EdgeID<VID>, /*inout*/ LinkLookup) -> Float )
    }
    var length: LinkLength = .constant(30)
    var calculatedLength: [Float] {
        get {
            return self.length.calculated(self.links, self.linkLookup)
        }
    }


    /// Bias
    var calculatedBias: [Float] {
        get {
            links.map { l in
                Float(linkLookup.count[l.source, default: 0]) / Float(
                    linkLookup.count[l.target, default: 0] + linkLookup.count[l.source, default: 0]
                )
            }
        }
    }


    weak var simulation: Simulation<VID>?


    
    var iterations: Int

    

    internal init(
        _ links: [EdgeID<VID>],
        stiffness: LinkStiffness? = nil, 
        iterations: Int = 1
    ) {
        self.links = links
        self.iterations = iterations

        self.stiffness = stiffness ?? defaultStiffness
    }

    internal init(
        _ links: [(VID, VID)],
        stiffness: LinkStiffness? = nil,
        iterations: Int = 1
    ) {
        self.links = links.map { EdgeID($0.0, $0.1) }
        self.iterations = iterations
        self.stiffness = stiffness ?? defaultStiffness
    }

    public func apply(alpha: Float) {
        guard let sim = self.simulation else { return }
        for _ in 0..<self.iterations {
            var position: Vector2f
            var l: Float
            for (i, link) in self.links.enumerated() {
                let sourceId = link.source
                let targetId = link.target

                /// This could throw
                // let source = sim[dangerouslyGetById: sourceId]
                // let target = sim[dangerouslyGetById: targetId]
                let b = self.calculatedBias[i]

                if let source = sim.getNode(sourceId),
                   let target = sim.getNode(targetId) {

                    position = (target.position + target.velocity - source.position - source.velocity)
                        .jiggled(with: &random)

                    l = position.length()
                    

                    l = (l - self.calculatedLength[i]) / l * alpha * self.calculatedStiffness[i]

                    position *= l

                    sim.updateNode(sourceId) { n in
                        n.velocity += position * b
                    }
                    sim.updateNode(targetId) { n in
                        n.velocity -= position * (1 - b)
                    }
                    // sim[dangerouslyGetById: sourceId].velocity += position * b
                    // sim[dangerouslyGetById: targetId].velocity -= position * (1 - b)

                }
                
            }
        }
    }

    public func initialize() {
        guard let sim = self.simulation else { return }
        for link in self.links {
            
        }

    }


    public let defaultStiffness: LinkStiffness = .varied{ link, lookup in
        1 / Float(
            min(
                lookup.count[link.source, default: 0],
                lookup.count[link.target, default: 0]
            )
        )
    }

    
}

extension Simulation {

    @discardableResult
    public func createLinkForce(
        name: String,
        links: [EdgeID<NodeID>]
    ) -> LinkForce<NodeID> {
        let linkForce = LinkForce<NodeID>(links)
        linkForce.simulation = self
        self.forces[name] = linkForce
        return linkForce
    }

    @discardableResult
    public func createLinkForce(
        name: String,
        links: [(NodeID, NodeID)]
    ) -> LinkForce<NodeID> {
        let linkForce = LinkForce<NodeID>(links)
        linkForce.simulation = self
        self.forces[name] = linkForce
        return linkForce
    }

    @discardableResult
    public func createLinkForce(
        name: String,
        links: [EdgeID<NodeID>], 
        stiffness: Float
    ) -> LinkForce<NodeID> {
        let linkForce = LinkForce<NodeID>(links, stiffness: .constant(stiffness))
        linkForce.simulation = self
        self.forces[name] = linkForce
        return linkForce
    }

    @discardableResult
    public func createLinkForce(
        name: String,
        links: [(NodeID, NodeID)], 
        stiffness: Float
    ) -> LinkForce<NodeID> {
        let linkForce = LinkForce<NodeID>(links, stiffness: .constant(stiffness))
        linkForce.simulation = self
        self.forces[name] = linkForce
        return linkForce
    }


    @discardableResult
    public func createLinkForce(
        name: String,
        links: [EdgeID<NodeID>], 
        stiffness: @escaping(EdgeID<NodeID>, LinkForce<NodeID>.LinkLookup) -> Float
    ) -> LinkForce<NodeID> {
        let linkForce = LinkForce<NodeID>(links, stiffness: .varied(stiffness))
        linkForce.simulation = self
        self.forces[name] = linkForce
        return linkForce
    }

    @discardableResult
    public func createLinkForce(
        name: String,
        links: [(NodeID, NodeID)], 
        stiffness: @escaping(EdgeID<NodeID>, LinkForce<NodeID>.LinkLookup) -> Float
    ) -> LinkForce<NodeID> {
        let linkForce = LinkForce<NodeID>(links, stiffness: .varied(stiffness))
        linkForce.simulation = self
        self.forces[name] = linkForce
        return linkForce
    }
    
}


extension LinkForce.LinkStiffness {
    func calculated(_ links: [EdgeID<VID>], _ linkLookup: LinkForce.LinkLookup) -> [Float] {
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
    func calculated(_ links: [EdgeID<VID>], _ linkLookup: LinkForce.LinkLookup) -> [Float] {
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