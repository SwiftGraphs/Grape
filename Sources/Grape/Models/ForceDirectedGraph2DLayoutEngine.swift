import ForceSimulation
import Observation
import SwiftUI

protocol LayoutEngine {

}

@Observable
public class ForceDirectedGraph2DLayoutEngine<ForceField>: LayoutEngine where ForceField: ForceProtocol, ForceField.Vector == SIMD2<Double> {

    var simulation: Simulation2D<ForceField>

    @ObservationIgnored
    let frameRate: Double = 60.0
    
    @ObservationIgnored
    var scheduledTimer: Timer? = nil

    public init(initialSimulation: Simulation2D<ForceField>) {
        self.simulation = initialSimulation
    }

    public func start() {
        guard self.scheduledTimer == nil else { return }
        self.scheduledTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0 / frameRate,
            repeats: true
        ) { [weak self] _ in
            self?.tick()
        }
    }

    public func stop() {
        self.scheduledTimer?.invalidate()
        self.scheduledTimer = nil
    }

    public func tick() {
        withMutation(keyPath: \.simulation) {
            simulation.tick()
        }
    }

    public func tick(waitingForTickingOn queue: DispatchQueue) {
        queue.asyncAndWait {
            self.simulation.tick()
        }
        withMutation(keyPath: \.self.simulation) { }
    }
}
