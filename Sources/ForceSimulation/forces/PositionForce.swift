//
//  PositionForce.swift
//  
//
//  Created by li3zhen1 on 10/1/23.
//

import Foundation

public class PositionForce<VID> : Force where VID : Hashable {
    var x: Float
    var y: Float
    var strength: Float
        
    init(x: Float, y: Float, strength: Float = 0.1) {
        self.x = x
        self.y = y
        self.strength = strength
    }

    var simulation: Simulation<VID>?

    func apply(alpha: Float) {
        
    }

    func initialize() {
        
    }

        

        
}