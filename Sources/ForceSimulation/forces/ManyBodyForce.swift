//
//  File.swift
//  
//
//  Created by li3zhen1 on 10/1/23.
//

import QuadTree


public class ManyBodyForce<VID> : Force where VID : Hashable {

    public enum Strength {
        case constant(Float)
        case varied( (VID) -> Float )
        case polarCoordinatesOnRad( (Float, VID) -> Float )
    }

    var strength: Strength = .constant(-30)

    weak var simulation: Simulation<VID>?

    var theta2: Float = 0.9
    var theta: Float { theta2.squareRoot() }

    var distanceMin: Float = 1.0
    var distanceMax: Float = Float.infinity

    internal init(strength: Strength) {
        self.strength = strength
    }

    public func apply(alpha: Float) {
        
    }

    public func initialize() {
        
    }

    

    func accumulate(quadTree: QuadTree<VID>) {

    }
    
}
