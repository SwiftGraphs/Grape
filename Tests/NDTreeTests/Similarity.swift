infix operator ~=: ComparisonPrecedence

extension String {
    func removeWhitespace() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }

    static func ~= (lhs:Self, rhs:Self) -> Bool {
        return lhs.removeWhitespace() == rhs.removeWhitespace()
    }
    
}



extension Float {
    static let tolerance: Self = 1e-5
    static func ~= (lhs:Self, rhs: Self) -> Bool {
        return abs(lhs-rhs) <= tolerance
    }
}


extension Double {
    static let tolerance: Self = 1e-5
    static func ~= (lhs:Self, rhs: Self) -> Bool {
        return abs(lhs-rhs) <= tolerance
    }
}

