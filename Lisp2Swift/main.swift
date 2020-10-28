import Foundation

print("Hello, World!")

struct Expression {
    let symbol: String
    let parameters: [String]
}

enum ScanResult: Equatable {
    case regions(_: [String])
    case incomplete
}

class Parser {

    func scan(text: String) -> ScanResult {
        return .regions([""])
    }
    
    func parse(lispString: String) -> [Expression] {
        
        let string = lispString as NSString
        let startRange = string.range(of: "(")
        let endRange = string.range(of: ")")
        
        guard startRange.location != NSNotFound && endRange.location != NSNotFound else {
            return []
        }
        
        let range = NSMakeRange(startRange.location + 1, endRange.location-startRange.location - 1)
        let contents = string.substring(with: range)
        
        let elements = contents.split(separator: " ").map({String($0)})
        
        guard elements.count >= 2 else {
            return []
        }
        
        let symbol = elements[0]
        let parameters = Array(elements.dropFirst())
        return [Expression(symbol: symbol, parameters: parameters)]
    }
}
