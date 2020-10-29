import Foundation

print("Hello, World!")

extension String {
    
    func enclosed(by: String) -> Bool {
        return hasPrefix(by) && hasSuffix(by)
    }
    
    var isExpression: Bool {
        return hasPrefix("(") && hasSuffix(")")
    }
}

enum Word: Equatable {
    case string(_: String)
    case symbol(_: String)
    case expression(_: [Word])
    case invalid(_: String)
    
    init?(string: String) {
        if string.enclosed(by: "\"") {
            self = .string(string)
        }
        else if string.contains("(") || string.contains(")") {
            self = .invalid(string)
        }
        else if string.count == 0 {
            return nil
        }
        else {
            self = .symbol(string)
        }
    }
}

enum Expression: Equatable {
    case string(_: String)
    case symbol(_: String)
    case expression(_: [Expression])
}

enum ParseResult: Equatable {
    case valid(expressions: [Expression])
    case invalid(expression: String)
}

class Parser {
      
    func scan(text: String) -> [Word] {
        if text.isExpression {
            let contents = (text as NSString).substring(with: NSMakeRange(1, text.count - 2))
            return [.expression(scan(text: contents))]
        }
        else if text.contains(" ") {
            let parts = text.split(separator: " ")
                .compactMap({String($0)})
                .filter({$0.count > 0})
            return parts.compactMap({scan(text: $0).first})
        }
        else {
            return [Word(string: text)].compactMap({$0})
        }
    }

    func parse(text: String) -> ParseResult {
        let words = scan(text: text)
        // TODO: check that first tier only has expressions
        return .valid(expressions: [])
    }
    
    
    
//    // OLD IMPL
//
//    struct Expression2 {
//        let symbol: String
//        let parameters: [String]
//    }
//
//    func oldParse(lispString: String) -> [Expression2] {
//
//        let string = lispString as NSString
//        let startRange = string.range(of: "(")
//        let endRange = string.range(of: ")")
//
//        guard startRange.location != NSNotFound && endRange.location != NSNotFound else {
//            return []
//        }
//
//        let range = NSMakeRange(startRange.location + 1, endRange.location-startRange.location - 1)
//        let contents = string.substring(with: range)
//
//        let elements = contents.split(separator: " ").map({String($0)})
//
//        guard elements.count >= 2 else {
//            return []
//        }
//
//        let symbol = elements[0]
//        let parameters = Array(elements.dropFirst())
//        return [Expression2(symbol: symbol, parameters: parameters)]
//    }
}
