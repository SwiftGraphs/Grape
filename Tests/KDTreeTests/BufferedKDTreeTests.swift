import XCTest
@testable import ForceSimulation


class BufferedKDTreeTests: XCTestCase {
    func testEmptyTree() {
        let tree = BufferedKDTree<Int>(box: KDBox([0, 0], [1, 1]))
        assert(tree.debugDescription ~= "[]")
        assert(tree.delegate.count == 0)
    }
}