public protocol Disposable {
    @inlinable
    mutating func dispose()
}

extension UnsafeMutablePointer where Pointee: Disposable {

    /// Disposes the underlying memory block and 
    /// deallocates the memory block previously allocated at this pointer.
    ///
    /// This pointer must be a pointer to the start of a previously allocated memory 
    /// block. The memory must not be initialized or `Pointee` must be a trivial type.
    @inlinable
    public func dispose() {
        self.pointee.dispose()
        self.deallocate()
    }
}