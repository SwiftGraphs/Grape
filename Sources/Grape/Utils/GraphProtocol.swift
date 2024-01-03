import ForceSimulation

protocol GraphProtocol<Node, Edge> {
    associatedtype Node: Identifiable
    associatedtype Edge: Identifiable where Edge.ID == EdgeID<Node.ID>

    @inlinable
    var nodes: [Node] { get set }

    @inlinable
    var links: [Edge] { get set }
}

extension GraphProtocol {
    @inlinable
    mutating func pruneLinks() {
        let nodeDictionary = Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, $0) })
        let nodeSet = Set(nodes.map { $0.id })
        // let linkSet = Set(links.map { $0.id })

        // let nodesOccuredInLinkSet = Set(links.map { $0.id.source } + links.map { $0.id.target })

        let validLinks = links.filter {
            nodeSet.contains($0.id.source) && nodeSet.contains($0.id.target)
        }

        self.nodes = nodeSet.map { nodeDictionary[$0]! }

        self.links = validLinks
    }

    @inlinable
    func isPruned() -> Bool {
        guard nodes.count == Set(nodes.map { $0.id }).count else {
            return false
        }

        guard links.count == Set(links.map { $0.id }).count else {
            return false
        }

        guard
            (links.allSatisfy { l in
                nodes.contains(where: { $0.id == l.id.source })
                    && nodes.contains(where: { $0.id == l.id.target })
            })
        else {
            return false
        }
        return true
    }

    @inlinable
    func difference(from other: Self) -> (nodeDiff: CollectionDifference<Node>, edgeDiff: CollectionDifference<Edge>) {

        #if DEBUG
            assert(isPruned())
        #endif

        let nodeDiff = nodes.difference(from: other.nodes) { $0.id == $1.id }
        let edgeDiff = links.difference(from: other.links) { $0.id == $1.id }

        return (nodeDiff, edgeDiff)
    }
}
