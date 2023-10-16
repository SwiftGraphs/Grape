//
//  ForceLike.swift
//
//
//  Created by li3zhen1 on 10/1/23.
//

import NDTree

public protocol ForceLike {
    associatedtype NodeID: Hashable
    func apply(alpha: Double)
}


public protocol NDTreeBasedForceLike: ForceLike {
    associatedtype TD: NDTreeDelegate
}

extension Array where Element: NDTreeBasedForceLike {
    public func combined() {
        
    }
}

