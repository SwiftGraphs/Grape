//
//  Utils.swift
//
//
//  Created by li3zhen1 on 10/1/23.
//
import NDTree

// TODO: impl deterministic random number generator
// https://forums.swift.org/t/deterministic-randomness-in-swift/20835/5
public struct LinearCongruentialGenerator {
    @usableFromInline internal static let a: Double = 1664525
    @usableFromInline internal static let c: Double = 1013904223
    @usableFromInline internal static let m: Double = 4294967296
    @usableFromInline internal static var _s: Double = 1
    @usableFromInline internal var s: Double = 1
    
    @inlinable mutating func next() -> Double {
        s = (Self.a * s + Self.c).truncatingRemainder(dividingBy: Self.m)
        return s / Self.m
    }
    
    @inlinable static func next() -> Double {
        Self._s = (Self.a * Self._s + Self.c).truncatingRemainder(dividingBy: Self.m)
        return Self._s / Self.m
    }
}

public extension Double {
    @inlinable func jiggled() -> Double {
        if self == 0 || self == .nan {
            return (LinearCongruentialGenerator.next() - 0.5) * 1e-6
        }
        return self
    }
}

public extension VectorLike where Scalar == Double {
    @inlinable func jiggled() -> Self {
        var result = Self.zero
        for i in indices {
            result[i] = self[i].jiggled()
        }
        return result
    }
}


public struct EdgeID<NodeID>: Hashable where NodeID: Hashable {
    public let source: NodeID
    public let target: NodeID

    public init(_ source: NodeID, _ target: NodeID) {
        self.source = source
        self.target = target
    }
}



public protocol PrecalculatableNodeProperty {
    associatedtype NodeID: Hashable
    associatedtype V: VectorLike where V.Scalar == Double
    func calculated(for simulation: Simulation<NodeID, V>) -> [Double]
}


//
//struct ContiguousArrayWithLookupTable<Key, Value>: Collection
//where Key: Hashable, Value: Identifiable, Value.ID == Key {
//    func index(after i: Int) -> Int {
//        return data.index(after: i)
//    }
//
//    subscript(_ position: Int) -> Value {
//        get { return data[position] }
//        set {
//            data[position] = newValue
//            lookupTable[newValue.id] = position
//        }
//    }
//
//    subscript(_ key: Key) -> Value? {
//        get {
//            guard let index = lookupTable[key] else { return nil }
//            return data[index]
//        }
//        set {
//            guard let newValue else { return }
//            lookupTable[key] = data.count
//            data.append(newValue)
//        }
//    }
//
//    typealias Index = Int
//    typealias Element = Value
//
//    var data: ContiguousArray<Value>
//    var lookupTable: [Key: Int]
//
//    var startIndex: Int {
//        return data.startIndex
//    }
//
//    var endIndex: Int {
//        return data.endIndex
//    }
//
//    init() {
//        self.data = ContiguousArray<Value>()
//        self.lookupTable = [Key: Int]()
//    }
//
//    init<S>(_ elements: S) where S: Sequence, S.Element == Value {
//        self.data = ContiguousArray<Value>(elements)
//        self.lookupTable = [Key: Int]()
//        for i in 0..<self.data.count {
//            self.lookupTable[self.data[i].id] = i
//        }
//    }
//
//    func index(forKey key: Key) -> Int? {
//        return lookupTable[key]
//    }
//
//    func contains(_ key: Key) -> Bool {
//        return lookupTable[key] != nil
//    }
//
//    func firstIndex(of element: Value) -> Int? {
//        return lookupTable[element.id]
//    }
//
//    func firstIndex(where predicate: (Value) throws -> Bool) rethrows -> Int? {
//        return try data.firstIndex(where: predicate)
//    }
//
//    func sorted(by areInIncreasingOrder: (Value, Value) throws -> Bool) rethrows
//        -> ContiguousArrayWithLookupTable<Key, Value>
//    {
//        return try ContiguousArrayWithLookupTable<Key, Value>(data.sorted(by: areInIncreasingOrder))
//    }
//
//    func filter(_ isIncluded: (Value) throws -> Bool) rethrows -> ContiguousArrayWithLookupTable<
//        Key, Value
//    > {
//        return try ContiguousArrayWithLookupTable<Key, Value>(data.filter(isIncluded))
//    }
//
//    func map<T>(_ transform: (Value) throws -> T) rethrows -> ContiguousArrayWithLookupTable<Key, T>
//    {
//        return try ContiguousArrayWithLookupTable<Key, T>(data.map(transform))
//    }
//
//    func compactMap<ElementOfResult>(_ transform: (Value) throws -> ElementOfResult?) rethrows
//        -> ContiguousArrayWithLookupTable<Key, ElementOfResult>
//    {
//        return try ContiguousArrayWithLookupTable<Key, ElementOfResult>(data.compactMap(transform))
//    }
//
//    func reduce<Result>(
//        _ initialResult: Result, _ nextPartialResult: (Result, Value) throws -> Result
//    ) rethrows -> Result {
//        return try data.reduce(initialResult, nextPartialResult)
//    }

//}
//
//struct CartesianProduct<A, B>: AdditiveArithmetic
//where A: AdditiveArithmetic, B: AdditiveArithmetic {
//    static var zero: CartesianProduct<A, B> {
//        return CartesianProduct(a: A.zero, b: B.zero)
//    }
//
//    static func - (lhs: CartesianProduct<A, B>, rhs: CartesianProduct<A, B>) -> CartesianProduct<
//        A, B
//    > {
//        return CartesianProduct(a: lhs.a - rhs.a, b: lhs.b - rhs.b)
//    }
//
//    static func + (lhs: CartesianProduct<A, B>, rhs: CartesianProduct<A, B>) -> CartesianProduct<
//        A, B
//    > {
//        return CartesianProduct(a: lhs.a + rhs.a, b: lhs.b + rhs.b)
//    }
//
//    let a: A
//    let b: B
//}
