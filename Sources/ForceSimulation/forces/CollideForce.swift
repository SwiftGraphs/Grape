//
//  File.swift
//  
//
//  Created by li3zhen1 on 10/1/23.
//

import Foundation


public class CollideForce<N> : Force where N : Identifiable {

    public enum CollideRadius {
        case constant(Float)
        case varied( (N.ID) -> Float )
        case polarCoordinatesOnRad( (Float, N.ID) -> Float )
    }

    weak var simulation: Simulation<N>?

    public func apply(alpha: Float) {
        
    }

    public func initialize() {
        
    }

    
    
    
}
