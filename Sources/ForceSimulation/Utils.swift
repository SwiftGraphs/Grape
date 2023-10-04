//
//  File.swift
//  
//
//  Created by li3zhen1 on 10/1/23.
//
import QuadTree

public protocol RandomFloatGenerator {
    mutating func nextFloat() -> Float
}

class LinearCongruentialGenerator: RandomFloatGenerator {

    private var seed: UInt32
    private let a: UInt32 = 1664525
    private let c: UInt32 = 1013904223
    private let m: UInt32 = UInt32.max  // 2^32 - 1

    init(_ seed: UInt32 = 1) {
        self.seed = seed
    }

    /*mutating*/ func nextFloat() -> Float {
        seed = (a * seed + c) & m // Note: `& m` is used instead of `% m` for performance and because m is 2^32
        let normalizedValue = Float(seed) / Float(m)
        return normalizedValue
    }
    
}

extension Float {
    @inlinable func jiggled(with random: () -> Float) -> Float {
        if self == 0 || self == .nan {
            return (random() - 0.5) * 1e-6
        }
        return self
    }

    @inlinable func jiggled(with randomGenerator: inout some RandomFloatGenerator) -> Float {
        if self == 0 || self == .nan {
            return (randomGenerator.nextFloat() - 0.5) * 1e-6
        }
        return self
    }
}

extension Vector2f {
    @inlinable func jiggled(with random: () -> Float) -> Vector2f {
        return Vector2f(x.jiggled(with: random), y.jiggled(with: random))
    }

    @inlinable func jiggled(with randomGenerator: inout some RandomFloatGenerator) -> Vector2f {
        return Vector2f(x.jiggled(with: &randomGenerator), y.jiggled(with: &randomGenerator))
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