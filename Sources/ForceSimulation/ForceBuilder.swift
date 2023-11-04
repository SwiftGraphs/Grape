//
//  File.swift
//
//
//  Created by li3zhen1 on 11/4/23.
//

import simd


extension Dimension {

    @resultBuilder
    struct ForceBuilder {
        static func buildPartialBlock<F: ForceProtocol>(first: F) -> Field<EmptyForce, F> {
            return .init(first)
        }

        static func buildPartialBlock<FL: ForceProtocol, FR: ForceProtocol>(
            accumulated: FL, next: FR
        ) -> Field<FL, FR> {
            return .init(left: accumulated, right: next)
        }

        static func buildExpression(_ expression: Center<V>) -> CenterForce {
            return CenterForce.create(from: expression)
        }

        static func buildExpression(_ expression: ManyBody) -> ManyBodyForce {
            return ManyBodyForce()
        }
    }

}


typealias Float2D<ID: Hashable> = Dimension<ID, simd_double2>

extension Float2D {
    struct MyComposition: ForceComposition {
        var composition: some ForceProtocol {
            ManyBody()
            ManyBody()
        }
    }
}


// extension Float2D {
func test() {
    let f = Float2D.Simulation(nodeIds: [0, 3], force: Float2D<Int>.MyComposition().composition)
}
// }
