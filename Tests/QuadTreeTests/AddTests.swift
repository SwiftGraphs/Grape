import XCTest
@testable import QuadTree

struct IdNode: Identifiable {
    typealias ID = Int
    let id: Int
    
    static var idCounter = 0
    
    static public func new() -> Self {
        defer { idCounter += 1 }
        return Self(id: idCounter)
    }
    
    static public func reset() {
        idCounter = 0
    }
}


extension String {
    func removeWhitespace() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }

    func similarTo(_ other: String) -> Bool {
        return self.removeWhitespace() == other.removeWhitespace()
    }
}




extension QuadTreeNode {
    func getD3StyleDescription() -> String{
        if let children {
            return "[\(children.northWest.getD3StyleDescription()), \(children.northEast.getD3StyleDescription()), \(children.southWest.getD3StyleDescription()), \(children.southEast.getD3StyleDescription())]"
        }
        else {
            if nodes.count == 0 {
                return ""
            }
            else if nodes.count == 1{
                let first = nodes.first!
                return "{data: [\(first.value.x), \(first.value.y)]}"
            }
            else {
                let first = nodes.first!
                return "{data: [\(first.value.x), \(first.value.y)], next:{?}}"
            }
        }
    }
}


struct D3QuadTreeEntry: Decodable {
    let data: [Float]
}



final class AddTests: XCTestCase {
    func testDebugString() {
        /*

            const q = quadtree();
            assert.deepStrictEqual(q.add([0.0, 0.0]).root(), {data: [0, 0]});
            assert.deepStrictEqual(q.add([0.9, 0.9]).root(), [{data: [0, 0]},,, {data: [0.9, 0.9]}]);
            assert.deepStrictEqual(q.add([0.9, 0.0]).root(), [{data: [0, 0]}, {data: [0.9, 0]},, {data: [0.9, 0.9]}]);
            assert.deepStrictEqual(q.add([0.0, 0.9]).root(), [{data: [0, 0]}, {data: [0.9, 0]}, {data: [0, 0.9]}, {data: [0.9, 0.9]}]);
            assert.deepStrictEqual(q.add([0.4, 0.4]).root(), [[{data: [0, 0]},,, {data: [0.4, 0.4]}], {data: [0.9, 0]}, {data: [0, 0.9]}, {data: [0.9, 0.9]}]);
        
        */
        
        let jsonStr = "[[{data: [0.0, 0.0]},,, {data: [0.4, 0.4]}], {data: [0.9, 0.0]}, {data: [0.0, 0.9]}, {data: [0.9, 0.9]}]"
        
        let decoder = JSONDecoder()
        
        let q = QuadTree<IdNode>.create(startingWith: IdNode.new(), at: Vector2f(x: 0, y:0))
        
        q.add(IdNode.new(), at: Vector2f(x: 0.9, y:0.9))
        
        q.add(IdNode.new(), at: Vector2f(x: 0.9, y:0.0))
        
        q.add(IdNode.new(), at: Vector2f(x: 0.0, y:0.9))
        
        q.add(IdNode.new(), at: Vector2f(x: 0.4, y:0.4))
        
        print(q.root.getD3StyleDescription().removeWhitespace())
        print(jsonStr.removeWhitespace())
        
        
        
        
        
        
        
        
        
        
        
    }
    
    
}
