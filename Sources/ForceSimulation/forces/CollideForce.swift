//
//  File.swift
//  
//
//  Created by li3zhen1 on 10/1/23.
//

import Foundation


public class CollideForce<VID> : Force where VID : Hashable {

    public enum CollideRadius {
        case constant(Float)
        case varied( (VID) -> Float )
        case polarCoordinatesOnRad( (Float, VID) -> Float )
    }

    weak var simulation: Simulation<VID>?

    public func apply(alpha: Float) {
        
    }

    public func initialize() {
        
    }

    
    
    
}
