import XCTest
@testable import QuadTree


final class NdTreeTests: XCTestCase {
    
    func testNdBoxSwap() {
        let box = NdBox(p0: SIMD3<Double>.one, p1: SIMD3<Double>.zero)
        assert(box.p0 == .zero)
    }
    
    func testNdBoxGetCorner() {
        let box = NdBox(p0: SIMD3<Double>.one, p1: SIMD3<Double>.zero)
        
        
        
        let direction = 3
        assert(box.getCorner(of: direction) == .init(1, 1, 0))
        
        
        let direction2 = 4
        assert(box.getCorner(of: direction2) == .init(0, 0, 1))
        
        
    }
    
    func test2DCreatePoint() {
        
    }
}
