import Foundation

extension Character {
    var isWhitespace: Bool {
        return self == " " || self == "\t" || self == "\n"
    }
}

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
}
