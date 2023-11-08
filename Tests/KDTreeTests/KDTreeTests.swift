// @testable import ForceSimulation
// import XCTest

// final class KDTreeTests: XCTestCase {
//     func testCreatePointOnPerimeter() {
//         let q = t([[0, 0]])
//         assert(q.debugDescription ~= "{data: [0.0, 0.0]}")
//         assert(q.delegate.count == 1)

//         q.add(1, at: [1, 1])
//         assert(q.debugDescription ~= "[{data: [0.0, 0.0]},,, {data: [1.0, 1.0]}]")
//         assert(q.delegate.count == 2)

//         q.add(2, at: [1, 0])
//         assert(
//             q.debugDescription ~= "[{data: [0.0, 0.0]}, {data: [1.0, 0.0]},, {data: [1.0, 1.0]}]")
//         assert(q.delegate.count == 3)

//         q.add(3, at: [0, 1])
//         assert(
//             q.debugDescription
//                 ~= "[{data: [0.0, 0.0]}, {data: [1.0, 0.0]}, {data: [0.0, 1.0]}, {data: [1.0, 1.0]}]"
//         )
//         assert(q.delegate.count == 4)
//     }

//     func testCreatePointOnTop() {
//         let q = t(QuadBox([0, 0], [2, 2]), [[0, 0], [1, -1]])
//         assert(q.debugDescription ~= "[{data: [1.0, -1.0]},,{data: [0.0, 0.0]},]")
//         assert(q.delegate.count == 2)
//         assert(q.extent.p0 ~= [0, -2])
//         assert(q.extent.p1 ~= [4, 2])
//     }

//     func testCreatePointOnBottom() {
//         let q = t(QuadBox([0, 0], [2, 2]), [[0, 0], [1, 3]])
//         assert(q.delegate.count == 2)
//         assert(q.extent.p0 ~= [0, 0])
//         assert(q.extent.p1 ~= [4, 4])
//     }

//     func testCreatePointOnLeft() {
//         let q = t(QuadBox([0, 0], [2, 2]), [[0, 0], [-1, 1]])
//         assert(q.delegate.count == 2)
//         assert(q.extent.p0 ~= [-2, 0])
//         assert(q.extent.p1 ~= [2, 4])
//     }

//     func testCreateCoincidentPoints() {
//         let q = t(QuadBox([0, 0], [1, 1]), [[0, 0], [1, 0], [0, 1], [0, 1]])
//         assert(q.children![2].nodeIndices.count == 2)
//         assert(q.delegate.count == 4)
//     }

//     func testCreateFirstPoint() {
//         let q = t(QuadBox([1, 2], [2, 3]), [[1, 2]])
//         assert(q.extent.p0 ~= [1, 2])
//         assert(q.extent.p1 ~= [2, 3])
//         assert(q.debugDescription ~= "{data: [1.0, 2.0]}")
//         assert(q.delegate.count == 1)
//     }
// }