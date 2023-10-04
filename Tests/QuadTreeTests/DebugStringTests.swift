import XCTest
@testable import QuadTree



struct DataNode: Identifiable {
    
    typealias ID = Int
    let id: Int
    let name: String
    
    static var idCounter = 0
    
    static public func create(_ name: String) -> Self {
        defer { idCounter += 1 }
        return Self(id: idCounter, name: name)
    }
}

final class DebugStringTests: XCTestCase {
    func testDebugString() {
        let alice = DataNode.create("Alice")
        let bob = DataNode.create("Bob")
        let tree = try! QuadTree(nodes: [(alice, .init(10.0, 1.0))])
        
        tree.add(bob, at: .init(20.1, 3.7))
        
        print(tree.root.debugDescription)
    }
    
    
    
    
    
    
}
