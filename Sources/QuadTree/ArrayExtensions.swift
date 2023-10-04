//
//  File.swift
//  
//
//  Created by li3zhen1 on 9/26/23.
//


public extension Collection {
    
    @inlinable func min<T: Comparable>(of keyPath: KeyPath<Self.Element, T>) -> T? {
        return self.min { a, b in
            return a[keyPath: keyPath] < b[keyPath: keyPath]
        }?[keyPath: keyPath]
    }
    
    @inlinable func max<T: Comparable>(of keyPath: KeyPath<Self.Element, T>) -> T? {
        return self.max { a, b in
            return a[keyPath: keyPath] < b[keyPath: keyPath]
        }?[keyPath: keyPath]
    }
    
}


public extension Collection where Element: AdditiveArithmetic {
    @inlinable func sum() -> Element {
        var result = Element.zero
        for el in self {
            result += el
        }
        return result
    }
}

public extension Collection where Element: Hashable {

    @inlinable func uniqueCount<T: Hashable>(of keyPath: KeyPath<Self.Element, T>) -> Int {
        return Set(self.map { $0[keyPath: keyPath] } ).count
    }

    @inlinable func uniqueCount() -> Int {
        return Set(self).count
    }

    @inlinable func toSet<T: Hashable>(of keyPath: KeyPath<Self.Element, T>) -> Set<T> {
        return Set(self.map { $0[keyPath: keyPath] } )
    }

    @inlinable func toSet() -> Set<Element> {
        return Set(self)
    }
}