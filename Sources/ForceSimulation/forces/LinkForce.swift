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

public class LinkForce<N> : Force where N : Identifiable {

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
    var links: [EdgeID<N.ID>] 
    public var linkLookup: LinkLookup {
        get {
            var sources: [N.ID: [N.ID]] = [:]
            var targets: [N.ID: [N.ID]] = [:]
            var count: [N.ID: Int] = [:]
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
        case varied( (EdgeID<N.ID>, /*inout*/ LinkLookup) -> Float )
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
        case varied( (EdgeID<N.ID>, /*inout*/ LinkLookup) -> Float )
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


    weak var simulation: Simulation<N>?


    
    var iterations: Int

    

    internal init(
        _ links: [EdgeID<N.ID>],
        stiffness: LinkStiffness? = nil, 
        iterations: Int = 1
    ) {
        self.links = links
        self.iterations = iterations

        self.stiffness = stiffness ?? defaultStiffness
    }

    internal init(
        _ links: [(N.ID, N.ID)],
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
                        .jiggled()

                    l = position.length()
                    

                    l = (l - self.calculatedLength[i]) / l * alpha * self.calculatedStiffness[i]

                    position *= l

                    sim.updateNode(nodeId: sourceId) { n in
                        n.velocity += position * b
                    }
                    sim.updateNode(nodeId: targetId) { n in
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
        links: [EdgeID<N.ID>]
    ) -> LinkForce<N> {
        let linkForce = LinkForce<N>(links)
        linkForce.simulation = self
        self.forces[name] = linkForce
        return linkForce
    }

    @discardableResult
    public func createLinkForce(
        name: String,
        links: [(N.ID, N.ID)]
    ) -> LinkForce<N> {
        let linkForce = LinkForce<N>(links)
        linkForce.simulation = self
        self.forces[name] = linkForce
        return linkForce
    }

    @discardableResult
    public func createLinkForce(
        name: String,
        links: [EdgeID<N.ID>],
        stiffness: Float
    ) -> LinkForce<N> {
        let linkForce = LinkForce<N>(links, stiffness: .constant(stiffness))
        linkForce.simulation = self
        self.forces[name] = linkForce
        return linkForce
    }

    @discardableResult
    public func createLinkForce(
        name: String,
        links: [(N.ID, N.ID)],
        stiffness: Float
    ) -> LinkForce<N> {
        let linkForce = LinkForce<N>(links, stiffness: .constant(stiffness))
        linkForce.simulation = self
        self.forces[name] = linkForce
        return linkForce
    }


    @discardableResult
    public func createLinkForce(
        name: String,
        links: [EdgeID<N.ID>],
        stiffness: @escaping(EdgeID<N.ID>, LinkForce<N>.LinkLookup) -> Float
    ) -> LinkForce<N> {
        let linkForce = LinkForce<N>(links, stiffness: .varied(stiffness))
        linkForce.simulation = self
        self.forces[name] = linkForce
        return linkForce
    }

    @discardableResult
    public func createLinkForce(
        name: String,
        links: [(N.ID, N.ID)],
        stiffness: @escaping(EdgeID<N.ID>, LinkForce<N>.LinkLookup) -> Float
    ) -> LinkForce<N> {
        let linkForce = LinkForce<N>(links, stiffness: .varied(stiffness))
        linkForce.simulation = self
        self.forces[name] = linkForce
        return linkForce
    }
    
}


extension LinkForce.LinkStiffness {
    func calculated(_ links: [EdgeID<N.ID>], _ linkLookup: LinkForce.LinkLookup) -> [Float] {
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
    func calculated(_ links: [EdgeID<N.ID>], _ linkLookup: LinkForce.LinkLookup) -> [Float] {
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
