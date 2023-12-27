/// A wrapper of managed buffer that stores an array of elements.
@_eagerMove
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
    class func createBuffer(withHeader header: Int, count: Int, initializer: (Int) -> Element)
        -> UnsafeArray
    {
        let buffer = self.create(minimumCapacity: count) { _ in header }
        buffer.withUnsafeMutablePointerToElements {
            for i in 0..<count {
                $0[i] = initializer(i)
            }
        }
        return unsafeDowncast(buffer, to: UnsafeArray.self)
    }

    @inlinable
    class func createBuffer(
        withHeader header: Int, 
        count: Int, 
        moving: consuming UnsafeMutablePointer<Element>, 
        movingCount: Int,
        fillingExcessiveBufferWith initialValue: consuming Element
    ) -> UnsafeArray {
        let buffer = self.create(minimumCapacity: count) { _ in header }
        buffer.withUnsafeMutablePointerToElements {
            $0.moveInitialize(from: moving, count: movingCount)
            $0.advanced(by: movingCount).initialize(
                repeating: initialValue, 
                count: count - movingCount
            )
        }
        return unsafeDowncast(buffer, to: UnsafeArray.self)
    }
    
    @inlinable
    class func createBuffer(
        moving array: [Element],
        fillingWithIfFailed element: Element
    ) -> UnsafeArray {
        let buffer = self.create(minimumCapacity: array.count) { _ in array.count }
        array.withUnsafeBufferPointer { bufferPtr in
            if let baseAddr = bufferPtr.baseAddress {
                buffer.withUnsafeMutablePointerToElements {
                    $0.moveInitialize(from: .init(mutating: baseAddr), count: array.count)
                }
            }
            else {
                buffer.withUnsafeMutablePointerToElements {
                    for i in 0..<array.count {
                        $0[i] = element
                    }
                }
            }
        }
        return unsafeDowncast(buffer, to: UnsafeArray.self)
    }

    @available(*, deprecated, renamed: "createBuffer(withHeader:count:initialValue:)")
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
        withUnsafeMutablePointers { headerPtr, elementPtr in
            elementPtr.deinitialize(count: self.header)
            headerPtr.deinitialize(count: 1)
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
