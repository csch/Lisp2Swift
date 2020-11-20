//
// TODO: Ideally load this straight from a usual swift file
//       so that we can check this against the compiler as well

let swiftWrappers =
"""

import Foundation

func add(_ a: Any, _ b: Any) -> Any {
    switch (a, b) {
    case let (a, b) as (Int, Int):
        return a + b
    case let (a, b) as (Double, Int):
        return a + Double(b)
    case let (a, b) as (Int, Double):
        return Double(a) + b
    case let (a, b) as (Double, Double):
        return a + b
    default:
        fatalError("add: Unsupported data types: \\(a) \\(b)")
    }
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
        fatalError("random: Unsupported data types: \\(a) \\(b)")
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
