import XCTest
@testable import QuadTree


final class NdTreeTests: XCTestCase {
    
    func testNdBoxSwap() {
        let box = NdBox(p0: SIMD3<Float>.one, p1: SIMD3<Float>.zero)
        assert(box.p0 == .zero)
    }
    
    func testNdBoxGetCorner() {
        let box = NdBox(p0: SIMD3<Float>.one, p1: SIMD3<Float>.zero)
        
        
        
        let direction = OctDirection(rawValue: 3)
        assert(box.getCorner(of: direction) == .init(0, 1, 1))
        
        
        let direction2 = OctDirection(rawValue: 4)
        assert(box.getCorner(of: direction2) == .init(1, 0, 0))
        
        
    }
}
