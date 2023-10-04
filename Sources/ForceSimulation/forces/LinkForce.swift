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
        case calculated( (EdgeID<VID>, /*inout*/ LinkLookup) -> Float )
    }
    var stiffness: LinkStiffness
    var calculatedStiffness: [Float] {
        get {
            return self.stiffness.precalculate(self.links, self.linkLookup)
        }
    }



    /// Length accessor
    public enum LinkLength {
        case constant(Float)
        case calculated( (EdgeID<VID>, /*inout*/ LinkLookup) -> Float )
    }
    var length: LinkLength = .constant(30)
    var calculatedLength: [Float] {
        get {
            return self.length.precalculate(self.links, self.linkLookup)
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


    var simulation: Simulation<VID>?


    
    var iterations: Int

    

    internal init(
        _ links: [EdgeID<VID>],
        stiffness: LinkStiffness? = nil, 
        iterations: Int = 1
    ) {
        self.links = links
        self.iterations = iterations

        self.stiffness = stiffness ?? defaultStrength
    }

    internal init(
        _ links: [(VID, VID)],
        stiffness: LinkStiffness? = nil,
        iterations: Int = 1
    ) {
        self.links = links.map { EdgeID($0.0, $0.1) }
        self.iterations = iterations
        self.stiffness = stiffness ?? defaultStrength
    }


    func apply(alpha: Float) {
        guard let sim = self.simulation else { return }
        for _ in 0..<self.iterations {
            var position: Vector2f
            var l: Float
            for (i, link) in self.links.enumerated() {
                let sourceId = link.source
                let targetId = link.target
                let source = sim[node: sourceId]
                let target = sim[node: targetId]
                let b = self.calculatedBias[i]

                // if let source = sim[node: sourceId],
                //    let target = sim[node: targetId] {

                    position = target.position + target.velocity - source.position - source.velocity
                    l = position.length()
                    

                    l = (l - self.calculatedLength[i]) / l * alpha * self.calculatedStiffness[i]

                    position *= l

                    sim[node: sourceId].velocity += position * b
                    sim[node: targetId].velocity -= position * (1 - b)

                // }
                
            }
        }
    }

    func initialize() {
        guard let sim = self.simulation else { return }
        for link in self.links {
            
        }

    }


    public let defaultStrength: LinkStiffness = .calculated{ link, lookup in
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
    public func createLinkForce(_ links: [EdgeID<NodeID>]) -> LinkForce<NodeID> {
        let linkForce = LinkForce<NodeID>(links)
        linkForce.simulation = self
        return linkForce
    }

    @discardableResult
    public func createLinkForce(_ links: [(NodeID, NodeID)]) -> LinkForce<NodeID> {
        let linkForce = LinkForce<NodeID>(links)
        linkForce.simulation = self
        return linkForce
    }
}


extension LinkForce.LinkStiffness {
    func precalculate(_ links: [EdgeID<VID>], _ linkLookup: LinkForce.LinkLookup) -> [Float] {
        switch self {
        case .constant(let value):
            return links.map { _ in value }
        case .calculated(let f):
            return links.map { link in
                f(link, linkLookup)
            }
        }
    }
}

extension LinkForce.LinkLength {
    func precalculate(_ links: [EdgeID<VID>], _ linkLookup: LinkForce.LinkLookup) -> [Float] {
        switch self {
        case .constant(let value):
            return links.map { _ in value }
        case .calculated(let f):
            return links.map { link in
                f(link, linkLookup)
            }
        }
    }
}