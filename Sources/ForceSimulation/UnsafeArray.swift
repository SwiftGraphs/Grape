/// A wrapper of managed buffer that stores an array of elements.
public final class UnsafeArray<Element>: ManagedBuffer<Int, Element> {

    @inlinable
    class func createBuffer(withHeader header: Int, count: Int, initialValue: Element)
        -> UnsafeArray
    {
        let buffer = self.create(minimumCapacity: count) { _ in header }
        buffer.withUnsafeMutablePointerToElements {
            $0.initialize(repeating: initialValue, count: count)
        }
        return unsafeDowncast(buffer, to: UnsafeArray.self)
    }

    @inlinable
    class func createUninitializedBuffer(
        count: Int
    ) -> UnsafeArray {
        let buffer = self.create(minimumCapacity: count) { _ in count }
        // buffer.withUnsafeMutablePointerToElements {
        //     $0.initialize(repeating: Element(), count: count)
        // }
        return unsafeDowncast(buffer, to: UnsafeArray.self)
    }



    @inlinable
    var count: Int {
        return header
    }

    @inlinable
    var range: Range<Int> {
        return 0..<header
    }

    @inlinable
    func element(at index: Int) -> Element {
        return withUnsafeMutablePointerToElements { $0[index] }
    }

    @inlinable
    func setElement(_ element: Element, at index: Int) {
        withUnsafeMutablePointerToElements { $0[index] = element }
    }

    @inlinable
    deinit {
        _ = withUnsafeMutablePointerToElements { buffer in
            buffer.deinitialize(count: self.header)
        }
    }

    @inlinable
    public subscript(index: Int) -> Element {
        get {
            return withUnsafeMutablePointerToElements { $0[index] }
        }
        set {
            withUnsafeMutablePointerToElements { $0[index] = newValue }
        }
    }

    @inlinable
    public func asArray() -> [Element] {
        return withUnsafeMutablePointerToElements {
            Array(UnsafeBufferPointer(start: $0, count: self.header))
        }
    }

    @inlinable
    public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Int? {
        var result: Int? = nil

        try withUnsafeMutablePointerToElements {
            for i in 0..<self.header {
                if try predicate($0[i]) {
                    result = i
                }
            }
        }
        return result
    }

    @inlinable
    public var mutablePointer: UnsafeMutablePointer<Element> {
        return withUnsafeMutablePointerToElements {
            $0
        }
    }

}
