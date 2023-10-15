//
//  File.swift
//  
//
//  Created by li3zhen1 on 10/8/23.
//

import Foundation
import QuadTree

infix operator ~=: ComparisonPrecedence

extension String {
    func removeWhitespace() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }

    static func ~= (lhs:Self, rhs:Self) -> Bool {
        return lhs.removeWhitespace() == rhs.removeWhitespace()
    }
    
}



extension Float {
    static let tolerance: Self = 1e-5
    static func ~= (lhs:Self, rhs: Self) -> Bool {
        return abs(lhs-rhs) <= tolerance
    }
}


extension Double {
    static let tolerance: Self = 1e-5
    static func ~= (lhs:Self, rhs: Self) -> Bool {
        return abs(lhs-rhs) <= tolerance
    }
}


extension Quad {

    static func ~= (lhs:Self, rhs: Self) -> Bool {
        return (lhs.x0 ~= rhs.x0) &&
            (lhs.x1 ~= rhs.x1) &&
            (lhs.y0 ~= rhs.y0) &&
            (lhs.y1 ~= rhs.y1)
    }
}

extension VectorLike where Scalar == Double {
    static func ~= (lhs:Self, rhs: Self) -> Bool {
        for i in lhs.indices {
            if !(lhs[i] ~= rhs[i]) {
                return false
            }
        }
        return true
    }
}

extension NDBox where V.Scalar == Double {

    static func ~= (lhs:Self, rhs: Self) -> Bool {
        return (lhs.p0 ~= rhs.p0) && (lhs.p1 ~= rhs.p1)
    }
}


extension NdBox where Coordinate.Scalar == Double {

    static func ~= (lhs:Self, rhs: Self) -> Bool {
        return (lhs.p0 ~= rhs.p0) && (lhs.p1 ~= rhs.p1)
    }
}
