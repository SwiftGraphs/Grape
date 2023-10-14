//
//  NdTree.swift
//
//
//  Created by li3zhen1 on 10/10/23.
//

public struct NdBox<Coordinate> where Coordinate: VectorLike {
    public var p0: Coordinate
    public var p1: Coordinate

    @inlinable public init(p0: Coordinate, p1: Coordinate) {
        #if DEBUG
            assert(p0 != p1, "NdBox was initialized with 2 same anchor")
        #endif
        var p0 = p0
        var p1 = p1
        for i in p0.indices {
            if p1[i] < p0[i] {
                swap(&p0[i], &p1[i])
            }
        }
        self.p0 = p0
        self.p1 = p1
        // TODO: use Mask
    }

    @inlinable internal init(pMin: Coordinate, pMax: Coordinate) {
        #if DEBUG
            assert(pMin != pMax, "NdBox was initialized with 2 same anchor")
        #endif
        self.p0 = pMin
        self.p1 = pMax
    }

    @inlinable public init() {
        p0 = .zero
        p1 = .zero
    }

    public init(_ p0: Coordinate, _ p1: Coordinate) {
        self.init(p0: p0, p1: p1)
    }

}

extension NdBox {
    @inlinable var area: Coordinate.Scalar {
        var result: Coordinate.Scalar = 1
        let delta = p1 - p0
        for i in delta.indices {
            result *= delta[i]
        }
        return result
    }

    @inlinable var vec: Coordinate { p1 - p0 }

    @inlinable var center: Coordinate { (p1 + p0) / Coordinate.Scalar(2) }

    @inlinable func contains(_ point: Coordinate) -> Bool {
        for i in point.indices {
            if p0[i] > point[i] || point[i] >= p1[i] {
                return false
            }
        }
        return true
        //        return (p0 <= point) && (point < p1)
    }
}

extension NdBox {
    @inlinable func getCorner(of direction: Int) -> Coordinate {
        var corner = Coordinate.zero
        for i in 0..<Coordinate.scalarCount {
            corner[i] = ((direction >> i) & 0b1) == 1 ? p1[i] : p0[i]
        }
        return corner
    }
}

public protocol NdTreeDelegate {
    typealias NodeIndex = Int
    typealias BoxStorageIndex = Int
    associatedtype Coordinate: VectorLike
    @inlinable mutating func didAddNode(
        _ nodeIndex: NodeIndex,
        at position: Coordinate,
        in indexOfBoxStorage: BoxStorageIndex)
    @inlinable mutating func didRemoveNode(
        _ nodeIndex: NodeIndex,
        at position: Coordinate,
        in indexOfBoxStorage: BoxStorageIndex)
    init()
}

public final class NdTree<V, TD>
where V: VectorLike, TD: NdTreeDelegate, TD.Coordinate == V {

    public typealias Box = NdBox<V>

    public typealias NodeIndex = Int

    public typealias BoxStorageIndex = Int

    public private(set) var directionCount: Int

    public struct BoxStorage {
        // once initialized, should have V.entryCount elements
        public var childrenBoxStorageIndices: [BoxStorageIndex]? = nil
        public var nodeIndices: [NodeIndex]
        public var box: Box  // { didSet { center = box.center } }

        @inlinable init(
            box: Box,
            nodeIndices: [NodeIndex] = []
        ) {
            self.nodeIndices = nodeIndices
            self.box = box
            //            self.center = box.center

        }
    }

    public private(set) var nodePositions: [V]
    public private(set) var boxStorages: [BoxStorage]

    private var clusterDistance: V.Scalar
    private var clusterDistanceSquared: V.Scalar

    public private(set) var delegate: TD

    public init(
        initialBox: Box,
        estimatedNodeCount: Int,
        clusterDistance: V.Scalar
    ) where TD: NdTreeDelegate {
        self.clusterDistance = clusterDistance
        self.clusterDistanceSquared = clusterDistance * clusterDistance
        self.directionCount = 1 << V.scalarCount
        self.boxStorages = [.init(box: initialBox)]
        self.nodePositions = []
        self.boxStorages.reserveCapacity(4 * estimatedNodeCount)  // TODO: Probably too much? its ~29000 for 10000 random nodes
        self.nodePositions.reserveCapacity(estimatedNodeCount)

        self.delegate = TD()
    }

    @discardableResult
    public func add(
        at point: V
    ) -> Int {
        nodePositions.append(point)
        cover(point, boxStorageIndex: 0)
        let nodeIndex = nodePositions.count - 1
        add(nodeIndex: nodeIndex, at: point, boxStorageIndex: 0)
        return nodeIndex
    }

    @discardableResult
    public func addAll(
        _ points: [V]
    ) -> Range<Int> {
        nodePositions.append(contentsOf: points)
        for i in points.indices {
            cover(points[i], boxStorageIndex: 0)
            add(nodeIndex: i, at: points[i], boxStorageIndex: 0)
        }
        return nodePositions.count - points.count ..< nodePositions.count
    }

    private func add(
        nodeIndex: NodeIndex,
        at point: V,
        boxStorageIndex: BoxStorageIndex
    ) {

        defer {
            delegate.didAddNode(nodeIndex, at: point, in: boxStorageIndex)
        }

        guard let childrenBoxStorageIndices = boxStorages[boxStorageIndex].childrenBoxStorageIndices
        else {
            if boxStorages[boxStorageIndex].nodeIndices.isEmpty
                || nodePositions[boxStorages[boxStorageIndex].nodeIndices.first!] == point
                || (nodePositions[boxStorages[boxStorageIndex].nodeIndices.first!]).distanceSquared(
                    to: point) < self.clusterDistanceSquared
            {

                boxStorages[boxStorageIndex].nodeIndices.append(nodeIndex)

                return
            } else {

                let _box = boxStorages[boxStorageIndex].box
                var newChildren = Array(repeating: BoxStorage(box: _box), count: directionCount)

                let pCenter = _box.center
                for j in newChildren.indices {
                    for i in 0..<V.scalarCount {
                        let isOnTheHigherRange = (j >> i) & 0b1
                        if isOnTheHigherRange != 0 {
                            newChildren[j].box.p0[i] = pCenter[i]
                        } else {
                            newChildren[j].box.p1[i] = pCenter[i]
                        }
                    }
                }

                let currentBoxStorageCount = self.boxStorages.count
                let _nodeIndices = boxStorages[boxStorageIndex].nodeIndices
                if !_nodeIndices.isEmpty {
                    // put the indices to new
                    let index = getIndexShiftInSubdivision(
                        nodePositions[_nodeIndices.first!],
                        relativeTo: pCenter
                    )

                    newChildren[index].nodeIndices = _nodeIndices

                    for ni in _nodeIndices {
                        delegate.didAddNode(
                            ni, at: nodePositions[ni], in: currentBoxStorageCount + index)
                    }

                    // this node will not have children any more
                    boxStorages[boxStorageIndex].nodeIndices = []
                }
                self.boxStorages.append(contentsOf: newChildren)
                boxStorages[boxStorageIndex].childrenBoxStorageIndices = Array(
                    currentBoxStorageCount..<currentBoxStorageCount + directionCount)

                let indexShiftForNewNode = getIndexShiftInSubdivision(
                    point,
                    relativeTo: pCenter
                )

                add(
                    nodeIndex: nodeIndex, 
                    at: point,
                    boxStorageIndex:
                        boxStorages[boxStorageIndex].childrenBoxStorageIndices![
                            indexShiftForNewNode
                        ]
                )

                return
            }
        }
        let indexShiftForNewNode = getIndexShiftInSubdivision(
            point,
            relativeTo: boxStorages[boxStorageIndex].box.center
        )

        #if DEBUG
            assert(boxStorages[childrenBoxStorageIndices[indexShiftForNewNode]].box.contains(point))
        #endif

        add(
            nodeIndex: nodeIndex, at: point,
            boxStorageIndex:
                childrenBoxStorageIndices[indexShiftForNewNode]
        )
        return
    }

    private func cover(_ point: V, boxStorageIndex: BoxStorageIndex) {

        if boxStorages[boxStorageIndex].box.contains(point) { return }
        repeat {
            let _box = boxStorages[boxStorageIndex].box
            let indexShift = getIndexShiftInSubdivision(point, relativeTo: _box.p0)

            let nailedDirectionIndexShift = (directionCount - 1) - indexShift

            let nailedCorner = _box.getCorner(of: nailedDirectionIndexShift)
            let expandedCorner = _box.getCorner(of: indexShift) * 2 - nailedCorner

            let newRootBox = Box(p0: nailedCorner, p1: expandedCorner)

            let copyOfCurrentBoxStorage = boxStorages[boxStorageIndex]

            boxStorages[boxStorageIndex].box = newRootBox

            #if DEBUG
                assert(
                    copyOfCurrentBoxStorage.box.p0 != boxStorages[boxStorageIndex].box.p0
                        || copyOfCurrentBoxStorage.box.p1 != boxStorages[boxStorageIndex].box.p1
                )
            #endif

            appendDividedChildren(boxStorageIndex: boxStorageIndex)
            boxStorages[
                boxStorages[boxStorageIndex].childrenBoxStorageIndices![
                    getIndexShiftInSubdivision(point, relativeTo: expandedCorner)
                    // <- to the center of the new box
                ]
            ] = copyOfCurrentBoxStorage

        } while !boxStorages[boxStorageIndex].box.contains(point)
    }

    private func getIndexShiftInSubdivision(_ point: V, relativeTo originalPoint: V) -> Int {
        var index = 0
        for i in 0..<V.scalarCount {
            if point[i] >= originalPoint[i] {  // isOnHigherRange in this dimension
                index |= (1 << i)
            }
        }
        return index
    }

    private func appendDividedChildren(boxStorageIndex: BoxStorageIndex) {
        let _box = boxStorages[boxStorageIndex].box
        var newChildren = Array(repeating: BoxStorage(box: _box), count: directionCount)
        let pCenter = _box.center

        for j in newChildren.indices {
            for i in 0..<V.scalarCount {
                let isOnTheHigherRange = (j >> i) & 0b1

                // TODO: use simd mask
                if isOnTheHigherRange != 0 {
                    newChildren[j].box.p0[i] = pCenter[i]
                } else {
                    newChildren[j].box.p1[i] = pCenter[i]
                }
            }
        }

        let _boxStorage = boxStorages[boxStorageIndex]
        if !_boxStorage.nodeIndices.isEmpty {
            // put the indices to new
            let point = nodePositions[_boxStorage.nodeIndices.first!]
            let index = getIndexShiftInSubdivision(point, relativeTo: pCenter)
            newChildren[index].nodeIndices = _boxStorage.nodeIndices
            // this node will not have children any more
            boxStorages[boxStorageIndex].nodeIndices = []
        }
        
        self.boxStorages.append(contentsOf: newChildren)
        boxStorages[boxStorageIndex].childrenBoxStorageIndices = Array(boxStorages.count-directionCount..<boxStorages.count)
    }
}


extension NdTree {
    public var extent: Box { boxStorages[0].box }
    
}



extension NdBox: CustomDebugStringConvertible {
    @inlinable public var debugDescription: String {
        return "[\(p0), \(p1)]"
    }
    
}
