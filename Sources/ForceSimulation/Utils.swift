//
//  File.swift
//  
//
//  Created by li3zhen1 on 10/1/23.
//
import QuadTree


extension Float {

    @inlinable func jiggled() -> Float {
        if self == 0 || self == .nan {
            return Float.random(in: -0.5..<0.5) * 1e-6
        }
        return self
    }
}

extension Vector2f {
    @inlinable func jiggled() -> Vector2f {
        return Vector2f(x.jiggled(), y.jiggled())
    }
}



struct ContiguousArrayWithLookupTable<Key, Value>: Collection where Key: Hashable, Value: Identifiable, Value.ID == Key {
    func index(after i: Int) -> Int {
        return data.index(after: i)
    }

    subscript(_ position: Int) -> Value {
        get { return data[position] }
        set { 
            data[position] = newValue
            lookupTable[newValue.id] = position
        }
    }

    subscript(_ key: Key) -> Value? {
        get {
            guard let index = lookupTable[key] else { return nil }
            return data[index]
        }
        set {
            guard let newValue else { return }
            lookupTable[key] = data.count
            data.append(newValue)
        }
    }

    typealias Index = Int
    typealias Element = Value
        
    var data: ContiguousArray<Value>
    var lookupTable: [Key: Int]

    var startIndex: Int {
        get { return data.startIndex }
    }

    var endIndex: Int {
        get { return data.endIndex }
    }

    init() {
        self.data = ContiguousArray<Value>()
        self.lookupTable = [Key: Int]()
    }

    init<S>(_ elements: S) where S : Sequence, S.Element == Value {
        self.data = ContiguousArray<Value>(elements)
        self.lookupTable = [Key: Int]()
        for i in 0..<self.data.count {
            self.lookupTable[self.data[i].id] = i
        }
    }


    func index(forKey key: Key) -> Int? {
        return lookupTable[key]
    }

    func contains(_ key: Key) -> Bool {
        return lookupTable[key] != nil
    }

    func firstIndex(of element: Value) -> Int? {
        return lookupTable[element.id]
    }

    func firstIndex(where predicate: (Value) throws -> Bool) rethrows -> Int? {
        return try data.firstIndex(where: predicate)
    }


    func sorted(by areInIncreasingOrder: (Value, Value) throws -> Bool) rethrows -> ContiguousArrayWithLookupTable<Key, Value> {
        return try ContiguousArrayWithLookupTable<Key, Value>(data.sorted(by: areInIncreasingOrder))
    }

    func filter(_ isIncluded: (Value) throws -> Bool) rethrows -> ContiguousArrayWithLookupTable<Key, Value> {
        return try ContiguousArrayWithLookupTable<Key, Value>(data.filter(isIncluded))
    }

    func map<T>(_ transform: (Value) throws -> T) rethrows -> ContiguousArrayWithLookupTable<Key, T> {
        return try ContiguousArrayWithLookupTable<Key, T>(data.map(transform))
    }

    func compactMap<ElementOfResult>(_ transform: (Value) throws -> ElementOfResult?) rethrows -> ContiguousArrayWithLookupTable<Key, ElementOfResult> {
        return try ContiguousArrayWithLookupTable<Key, ElementOfResult>(data.compactMap(transform))
    }

    func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Value) throws -> Result) rethrows -> Result {
        return try data.reduce(initialResult, nextPartialResult)
    }


}


struct CartesianProduct<A, B>: AdditiveArithmetic where A: AdditiveArithmetic, B: AdditiveArithmetic {
    static var zero: CartesianProduct<A, B> {
        return CartesianProduct(a: A.zero, b: B.zero)
    }
    
    static func - (lhs: CartesianProduct<A, B>, rhs: CartesianProduct<A, B>) -> CartesianProduct<A, B> {
        return CartesianProduct(a: lhs.a-rhs.a, b: lhs.b-rhs.b)
    }
    
    static func + (lhs: CartesianProduct<A, B>, rhs: CartesianProduct<A, B>) -> CartesianProduct<A, B> {
        return CartesianProduct(a: lhs.a+rhs.a, b: lhs.b+rhs.b)
    }
    
    let a: A
    let b: B
}


//extension CartesianProduct where A: DurationProtocol, B: DurationProtocol {
//    static func / (lhs: CartesianProduct<A,B>, rhs: Int) -> CartesianProduct<A,B> {
//        return CartesianProduct(a: lhs.a/rhs, b: lhs.b/rhs)
//    }
//}
