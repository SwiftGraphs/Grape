import ForceSimulation
import Observation
import SwiftUI
import Charts

protocol LayoutEngine {
    
}

//@Observable
public class ForceDirectedGraph2DLayoutEngine<ForceField>: LayoutEngine & Observation.Observable
where ForceField: ForceProtocol, ForceField.Vector == SIMD2<Double> {
    
    public var simulation: Simulation2D<ForceField>
    
    @ObservationIgnored
    public var lastRenderedSize: CGSize = .init()
    
    // var isRunning = false
    
    @ObservationIgnored 
    @usableFromInline
    let frameRate: Double = 60.0
    
    @ObservationIgnored 
    @usableFromInline
    var scheduledTimer: Timer? = nil
    
    @inlinable
    public init(initialSimulation: Simulation2D<ForceField>) {
        self.simulation = initialSimulation
    }
    
    @inlinable
    func start() {
        guard self.scheduledTimer == nil else { return }
        self.scheduledTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0 / frameRate,
            repeats: true
        ) { [weak self] _ in
            self?.tick()
        }
    }
    
    @inlinable
    func stop() {
        self.scheduledTimer?.invalidate()
        self.scheduledTimer = nil
    }
    
    @inlinable
    func tick() {
        withMutation(keyPath: \.simulation) {
            Task.detached {
                self.simulation.tick()
            }
//            DispatchQueue(label: "grape", qos:.background).async {
//                simulation.tick()
//            }
        }
    }
    
    @inlinable
    func tickDetached() {
        withMutation(keyPath: \.simulation) {
            Task.detached {
                self.simulation.tick()
            }
//            DispatchQueue(label: "grape", qos:.background).async {
//                simulation.tick()
//            }
        }
    }
    
    @ObservationIgnored
    @usableFromInline
    let _$observationRegistrar = Observation.ObservationRegistrar()
    
    @inlinable
    nonisolated func access<Member>(
        keyPath: KeyPath<ForceDirectedGraph2DLayoutEngine, Member>
    ) {
        _$observationRegistrar.access(self, keyPath: keyPath)
    }
    
    @inlinable
    nonisolated func withMutation<Member, MutationResult>(
        keyPath: KeyPath<ForceDirectedGraph2DLayoutEngine, Member>,
        _ mutation: () throws -> MutationResult
    ) rethrows -> MutationResult {
        try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
    }
}
