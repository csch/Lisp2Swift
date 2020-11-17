import Foundation

extension String {
    func substring(from: Int, length: Int) -> String {
        return (self as NSString).substring(with: NSMakeRange(from, length))
    }
    func character(at index: Int) -> Character {
        self[self.index(startIndex, offsetBy: index)]
    }
    var shrunken: String {
        guard self.count >= 2 else { return self }
        return substring(from: 1, length: self.count-2)
    }
}

extension Array {
    
    var butFirst: Self {
        return Array(self[1..<count])
    }
    
    var oddElements: Self {
        return self.enumerated().filter({$0.offset % 2 == 0}).map({$0.element})
    }    
}

struct PairIterator<C: IteratorProtocol>: IteratorProtocol {
    private var baseIterator: C
    init(_ iterator: C) {
        baseIterator = iterator
    }

    mutating func next() -> (C.Element, C.Element)? {
        if let left = baseIterator.next(), let right = baseIterator.next() {
            return (left, right)
        }
        return nil
    }
}
extension Sequence {
    var pairs: AnySequence<(Self.Iterator.Element,Self.Iterator.Element)> {
        return AnySequence({PairIterator(self.makeIterator())})
    }
}
