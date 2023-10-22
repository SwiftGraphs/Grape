//
//  File.swift
//
//
//  Created by li3zhen1 on 10/15/23.
//

import simd
@testable import NDTree

extension VectorLike {
    var compactDebugString: String {
        var result = "["
        for i in indices {
            if i != 0 {
                result += ", "
            }

            result += self[i].debugDescription
        }
        return result + "]"
    }
}

extension NDTree: CustomDebugStringConvertible where D.NodeID == Int {
    public var debugDescription: String {
        if let children {
            return "[\(children.map{$0.debugDescription}.joined(separator: ","))]"
        } else {
            if nodeIndices.count == 0 {
                return ""
            } else if nodeIndices.count == 1 {
                let p = nodePosition!
                return "{data: \(p.compactDebugString)}"
            } else {
                let p = nodePosition!

                var r1 = ""
                var r2 = ""

                for i in nodeIndices {
                    if i == nodeIndices.count - 1 {
                        r1 += "{data: \(p)"
                    } else {
                        r1 += "{data: \(p), next:"
                    }
                    r2 += "}"
                }

                return r1 + r2
            }
        }
    }
}


extension simd_double2 {
    var compactDebugString: String {
        return "[\(self.x), \(self.y)]"
    }
}



extension Quadtree: CustomDebugStringConvertible where D.NodeID == Int {
    public var debugDescription: String {
        if let children {
            return "[\(children.map{$0.debugDescription}.joined(separator: ","))]"
        } else {
            if nodeIndices.count == 0 {
                return ""
            } else if nodeIndices.count == 1 {
                let p = nodePosition!
                return "{data: \(p.compactDebugString)}"
            } else {
                let p = nodePosition!

                var r1 = ""
                var r2 = ""

                for i in nodeIndices {
                    if i == nodeIndices.count - 1 {
                        r1 += "{data: \(p)"
                    } else {
                        r1 += "{data: \(p), next:"
                    }
                    r2 += "}"
                }

                return r1 + r2
            }
        }
    }
}
