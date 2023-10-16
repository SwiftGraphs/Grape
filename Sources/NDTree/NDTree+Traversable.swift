//
//  File.swift
//  
//
//  Created by li3zhen1 on 10/16/23.
//

public protocol Traversable {
    func visit(
        shouldVisitChildren: (Self) -> Bool
    )
    
    func visitPostOrdered(
        _ action: (Self) -> ()
    )
}


extension NDTree: Traversable {
    public func visit(shouldVisitChildren: (NDTree<V, D>) -> Bool) {
        if shouldVisitChildren(self), let children {
            // this is an internal node
            children.forEach { t in
                t.visit(shouldVisitChildren: shouldVisitChildren)
            }
        }
    }
    
    public func visitPostOrdered(
        _ action: (NDTree<V, D>) -> ()
    ) {
        if let children {
            children.forEach { t in
                t.visitPostOrdered(action)
            }
        }
        action(self)
    }
}
