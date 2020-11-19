//
// TODO: Ideally load this straight from a usual swift file
//       so that we can check this against the compiler as well

let swiftWrappers =
"""

import Foundation

func add(_ a: Any, _ b: Any) -> Any {
    return a
}

func str(_ a: Any) -> Any {
    if let integer = a as? Int {
        return String(integer)
    }
    else if let double = a as? Double {
        return String(double)
    }
    else {
        return a
    }
}

func random(_ a: Any, _ b: Any) -> Any {
    guard let int1 = a as? Int, let int2 = b as? Int else {
        fatalError("Unsupported data types: \\(a) \\(b)")
    }
    return Int.random(in: int1..<int2+1)
}

func equal(_ a: Any, _ b: Any) -> Bool {
    if let lh = a as? NSNumber, let rh = b as? NSNumber {
        return lh == rh
    }
    else if let lh = a as? String, let rh = b as? String {
        return lh == rh
    }
    else {
        return false
    }
}
"""
