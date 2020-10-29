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
    
    func enclosed(by: String) -> Bool {
        return hasPrefix(by) && hasSuffix(by)
    }
    
    var insideOfExpression: String {
        return (self as NSString).substring(with: NSMakeRange(1, self.count - 2))
    }
    
//    var isExpression: Bool {
//        // TODO: this needs to understand if it contains subexpressions
//        /// (h)(x) <- not an expression
//        // algorithm: go through it and if you find the closing braces before end of the string you know that t
//        guard hasPrefix("(") && hasSuffix(")") else { return false }
//        var numOpen = 0
//
//        for (index, ch) in self.enumerated() {
//            if ch == "(" { numOpen += 1 }
//            if ch == ")" { if numOpen == 1 && index < self.count - 1 { return false }}
//        }
//        return true
//    }
}

enum Word: Equatable {
    case string(_: String)
    case symbol(_: String)
    case expression(_: [Word])
    case invalid(_: String)
    
    init?(string: String) {
        guard string.count > 0 else { return nil }
        if string.enclosed(by: "\"") {
            self = .string(string)
        }
        else if string.contains("(") || string.contains(")") {
            self = .invalid(string)
        }
        else {
            self = .symbol(string)
        }
    }
    
    var invalidExpression: String? {
        switch self {
        case .invalid(let expression):
            return expression
        case .expression(let words):
            return words.compactMap({$0.invalidExpression}).first
        default:
            return nil
        }
    }
}

enum Expression: Equatable {
    case string(_: String)
    case symbol(_: String)
    case expression(_: [Expression])
    
    init?(word: Word) {
        switch word {
        case .invalid:
            return nil
        case .expression(let words):
            self = .expression(words.compactMap(Expression.init))
        case .string(let string):
            self = .string(string)
        case .symbol(let symbol):
            self = .symbol(symbol)
        }
    }
}

enum Evaluation: Equatable {
    case valid(expressions: [Expression])
    case invalid(expression: String)
}

class Transcoder {
      
    ///
    /// What we want:
    ///  Given a line of text such as "   (foo bar) (x (y)) asdfs"
    ///  we expect the following result [expression expression symbol]
    ///
    /// How do we do that:
    ///  - Generally, we parse through by character and save indices of
    ///    important events
    ///
    ///  1. We need parse for strings first, because they can include expressions
    ///     While parsing a string whitespace and newlines are ignored
    ///     If we finish parsing and our string is open, raise an error!
    ///  2. While parsing an expression we just keep looking for the end parantheses
    ///     so that we are on level 0. Whitespace ignored. When no end -> error
    ///     When end reached, recurse on inside of string and return .expression(...)
    ///  3. When not inside string and not inside expression we collect a list of symbols that will be returned
    ///     separated by whitespace
    ///
    ///
    
    func scan(text: String) -> [Word] {
        var exprLevel = 0
        var isString = false
        var start: Int?
        var words = [Word]()
        var lastChar: Character?
        
        for (index, char) in text.enumerated() {
            let isEnd = index == text.count-1
            if char == "\"" && exprLevel == 0 {
                if isString {
                    let sub = text.substring(from: start!, length: index + 1 - start!)
                    words.append(.string(sub))
                    isString = false
                    start = nil
                }
                else if isEnd {
                    words.append(.invalid(text))
                }
                else {
                    isString = true
                    start = index
                }
            }
            else if char == "(" && !isString {
                if (lastChar != nil && lastChar!.isWhitespace == false) || isEnd {
                    words.append(.invalid(text))
                }
                else if exprLevel == 0 {
                    start = index + 1
                }
                exprLevel += 1
            }
            else if char == ")" && !isString {
                exprLevel -= 1
                if exprLevel == 0 {
                    let substring = text.substring(from: start!, length: index - start!)
                    words.append(.expression(scan(text: substring)))
                    start = nil
                }
                else if isEnd {
                    words.append(.invalid(text))
                }
            }
            else if !isString && exprLevel == 0 {
                if char.isWhitespace == false && start == nil {
                    start = index
                }
                
                else if (char.isWhitespace || isEnd) && start != nil  {
                    let offset = char.isWhitespace ? -1 : 0
                    let substring = text.substring(from: start!, length: index + 1 - start! + offset)
                    words.append(.symbol(substring))
                    start = nil
                }
            }
            lastChar = char
        }
        return words
    }
    
//    func scan(text: String) -> [Word] {
//        let newText = text.replacingOccurrences(of: "\n", with: " ")
//
//        // TODO: need a way to split up in case we have multiple expressions
//        if newText.isExpression {
//            let contents = newText.insideOfExpression
//            return [.expression(scan(text: contents))]
//        }
//
//        /// at this point we should have scanned all expressions and strings already so
//        /// that we don't split up any of those
//        else if newText.contains(" ") {
//            let parts = newText.split(separator: " ")
//                .compactMap({String($0)})
//                .filter({$0.count > 0})
//            return parts.compactMap({scan(text: $0).first})
//        }
//        else {
//            return [Word(string: newText)].compactMap({$0})
//        }
//    }
    
    func evaluate(words: [Word]) -> Evaluation {
        if let invalidExpr = words.compactMap({$0.invalidExpression}).first {
            return .invalid(expression: invalidExpr)
        }
        return .valid(expressions: words.compactMap(Expression.init))
    }
    
    func transcode(expression: Expression) -> String {
        
        switch expression {
        case .string(let string):
            return string + ")"
            
        case .symbol(let symbol):
            return symbol + "("
            
        case .expression(let expressions):
            return expressions.map({transcode(expression: $0)}).reduce("", +)
        }
    }

    func transcode(expressions: [Expression]) -> String {
        return expressions.map({transcode(expression: $0) + "\n"}).reduce("", +)
    }
}
