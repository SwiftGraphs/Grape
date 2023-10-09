//
//  PositionForce.swift
//  
//
//  Created by li3zhen1 on 10/1/23.
//

import Foundation

public class PositionForce<N> : Force where N: Identifiable {
    var x: Float
    var y: Float
    var strength: Float
        
    init(x: Float, y: Float, strength: Float = 0.1) {
        self.x = x
        self.y = y
        self.strength = strength
    }

    weak var simulation: Simulation<N>?

    public func apply(alpha: Float) {
        
    }
    

        

        
}
