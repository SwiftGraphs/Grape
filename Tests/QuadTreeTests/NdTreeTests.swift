import XCTest
@testable import QuadTree

extension SIMD3<Double>: ComponentComparable {
    public static func < (lhs: SIMD3<Scalar>, rhs: SIMD3<Scalar>) -> Bool {
        return lhs.x < rhs.x && lhs.y < rhs.y && lhs.z < rhs.z
    }

    public static func > (lhs: SIMD3<Scalar>, rhs: SIMD3<Scalar>) -> Bool {
        return lhs.x > rhs.x && lhs.y > rhs.y && lhs.z > rhs.z
    }

    public static func <= (lhs: SIMD3<Scalar>, rhs: SIMD3<Scalar>) -> Bool {
        return lhs.x <= rhs.x && lhs.y <= rhs.y && lhs.z <= rhs.z
    }

    public static func >= (lhs: SIMD3<Scalar>, rhs: SIMD3<Scalar>) -> Bool {
        return lhs.x >= rhs.x && lhs.y >= rhs.y && lhs.z >= rhs.z
    }

}

final class NdTreeTests: XCTestCase {
    
    func testNdBoxSwap() {
        let box = NdBox(p0: SIMD3<Double>.one, p1: SIMD3<Double>.zero)
        assert(box.p0 == .zero)
    }
    
    func testNdBoxGetCorner() {
        let box = NdBox(p0: SIMD3<Double>.one, p1: SIMD3<Double>.zero)
        
        
        
        let direction = OctDirection(rawValue: 3)
        assert(box.getCorner(of: direction) == .init(0, 1, 1))
        
        
        let direction2 = OctDirection(rawValue: 4)
        assert(box.getCorner(of: direction2) == .init(1, 0, 0))
        
        
    }
}
