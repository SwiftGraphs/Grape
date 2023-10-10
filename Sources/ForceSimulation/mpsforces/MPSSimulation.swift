import Foundation
import Metal
import simd
import MetalPerformanceShaders


final public class MPSSimulation {
    init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("")
        }

        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("")
        }

        let library = device.makeDefaultLibrary()

        let function = library?.makeFunction(name: "")

        var pipelineState: MTLComputePipelineState
        do {
            pipelineState = try device.makeComputePipelineState(function: function!)
        } catch {
            fatalError("")
        }
    }
}
