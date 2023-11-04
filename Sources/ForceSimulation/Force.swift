//
//  File.swift
//
//
//  Created by li3zhen1 on 11/4/23.
//

import simd

public struct Dimension<NodeID, V>
where NodeID: Hashable, V: SIMD, V.Scalar: FloatingPoint {}

public protocol ForceProtocol {
    associatedtype NodeID: Hashable
    associatedtype V: SIMD where V.Scalar: FloatingPoint

    func apply<S: Simulation>(_ simulation: S) where S.NodeID == NodeID, S.V == V
    func bind<S: Simulation>(_ simulation: S) where S.NodeID == NodeID, S.V == V
}

extension Dimension {
    public struct CenterForce: ForceProtocol {
        public func bind<S: Simulation>(_ simulation: S) where S.NodeID == NodeID, S.V == V {

        }
        public func apply<S: Simulation>(_ simulation: S) where S.NodeID == NodeID, S.V == V {

        }

        static public func create(from: Center) -> CenterForce {
            return CenterForce()
        }
    }

    public struct ManyBodyForce: ForceProtocol {
        public func bind<S: Simulation>(_ simulation: S) where S.NodeID == NodeID, S.V == V {

        }

        public func apply<S: Simulation>(_ simulation: S) where S.NodeID == NodeID, S.V == V {

        }
    }

    public struct EmptyForce: ForceProtocol {
        public func bind<S: Simulation>(_ simulation: S) where S.NodeID == NodeID, S.V == V {

        }
        public func apply<S: Simulation>(_ simulation: S) where S.NodeID == NodeID, S.V == V {

        }
    }

    public struct Field<F1, F2>: ForceProtocol
    where
        F1: ForceProtocol, F2: ForceProtocol,
        F1.NodeID == F2.NodeID,
        F1.NodeID == F2.NodeID,
        NodeID == F1.NodeID,
        NodeID == F2.NodeID,
        V == F1.V,
        V == F2.V
    {
        public typealias NodeID = F1.NodeID

        public typealias V = F1.V

        let left: F1?
        let right: F2

        init(left: F1, right: F2) {
            self.left = left
            self.right = right
        }

        init(@FieldBuilder _ buildField: () -> Field<F1, F2>) {
            let result = buildField()
            self.left = result.left
            self.right = result.right
        }

        public func apply<S: Simulation>(_ simulation: S) where S.NodeID == NodeID, S.V == V {
            left?.apply(simulation)
            right.apply(simulation)
        }

        public func bind<S: Simulation>(_ simulation: S) where S.NodeID == NodeID, S.V == V {
            right.bind(simulation)
        }
    }

}

extension Dimension.Field where F1 == Dimension.EmptyForce {
    init(_ right: F2) {
        self.left = nil
        self.right = right
    }
}

extension Dimension {

    @resultBuilder
    struct FieldBuilder {
        static func buildPartialBlock<F: ForceProtocol>(first: F) -> Field<EmptyForce, F> {
            return .init(first)
        }

        static func buildPartialBlock<FL: ForceProtocol, FR: ForceProtocol>(
            accumulated: FL, next: FR
        ) -> Field<FL, FR> {
            return .init(left: accumulated, right: next)
        }

        static func buildExpression(_ expression: Center) -> CenterForce {
            return CenterForce()
        }

        static func buildExpression(_ expression: ManyBody) -> ManyBodyForce {
            return ManyBodyForce()
        }
    }

}

public protocol Simulation {
    associatedtype CompositedForce: ForceProtocol
    associatedtype NodeID: Hashable
    associatedtype V: SIMD where V.Scalar: FloatingPoint

    var nodeIds: [NodeID] { get set }

    @Dimension<NodeID, V>.FieldBuilder
    var field: CompositedForce { get }
}

extension Dimension {

    public struct MySimulation<CompositedForce> where CompositedForce: ForceProtocol, CompositedForce.NodeID == NodeID, CompositedForce.V == V {


        public var nodeIds: [NodeID]
        public var field: CompositedForce
        
        init(
            nodeIds: [NodeID],
            @FieldBuilder _ buildForceDescriptor: () -> CompositedForce
        ) {
            self.field = buildForceDescriptor()
            
            self.nodeIds = nodeIds
        }

    }

}

// extension Dimension.MySimulation: Simulation {

//     public typealias CompositedForce = CompositedForce

//     public typealias NodeID = NodeID

//     public typealias V = V


// }

typealias Float2D<ID: Hashable> = Dimension<ID, simd_double2>

public protocol ForceDescriptor {

}

public struct Center: ForceDescriptor {}
public struct ManyBody: ForceDescriptor {}
public struct Collision: ForceDescriptor {}
public struct Link: ForceDescriptor {}
public struct Position: ForceDescriptor {}
public struct Radial: ForceDescriptor {}

public struct Empty: ForceDescriptor {}



// extension Float2D {
func test() {

    let f = Float2D.MySimulation(nodeIds: [0, 3]) {
        Center()
        ManyBody()
        Center()
        ManyBody()
    }
}
// }
