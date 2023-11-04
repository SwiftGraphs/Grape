import simd

public protocol _Simulation {
    associatedtype Forces: ForceProtocol
    typealias NodeID = Forces.NodeID
    typealias V = Forces.V
    var forces: Forces { get }
    var nodeIds: [NodeID] { get }
    var state: SimulationState<NodeID, V> { get set }



}

// public protocol _Simulation2D: _Simulation where V == simd_double2 {

// }

struct MySimulation<NodeID>: _Simulation
where NodeID: Hashable {

    typealias V = simd_double2
    
    typealias CenterForce = Force.CenterForce<NodeID, V>
    typealias ManyBodyForce = Force.ManyBodyForce<NodeID, V>
    typealias DirectionForce = Force.DirectionForce<NodeID, V>
    typealias LinkForce = Force.LinkForce<NodeID, V>
    typealias CollideForce = Force.CollideForce<NodeID, V>
    typealias RadialForce = Force.RadialForce<NodeID, V>
    typealias ForceField = Force.ForceField 

    var state: SimulationState<NodeID, V>

    var nodeIds: [NodeID]

    init(nodeIds: [NodeID]) {
        self.nodeIds = nodeIds
        self.state = Self.buildSimulation(nodeIds: nodeIds)
    }

    var forces = ForceField {
        CenterForce(center: .zero, strength: 0.1)
        CenterForce(center: .zero, strength: 0.1)
    }
}

extension _Simulation {

    static func buildSimulation(
        nodeIds: [NodeID],
        alpha: V.Scalar = 1,
        alphaMin: V.Scalar = 1e-3,
        alphaDecay: V.Scalar = 2e-3,
        alphaTarget: V.Scalar = 0.0,
        velocityDecay: V.Scalar = 0.6,
        setInitialStatus getInitialPosition: (
            (NodeID) -> V
        )? = nil
    ) -> SimulationState<NodeID, V> {

        let state = SimulationState(
            nodeIds: nodeIds,
            alpha: alpha,
            alphaMin: alphaMin,
            alphaDecay: alphaDecay,
            alphaTarget: alphaTarget,
            velocityDecay: velocityDecay,
            setInitialStatus: getInitialPosition
        )

        // self.forces.bindSimulation(state)

        return state
    }

    func tick() {
        self.forces.apply()
    }
}

let _sim = MySimulation(nodeIds: [1, 2, 3])

// let t: TestSimulation = TestSimulation(state: SimulationState(nodeIds: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]))
