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
}

enum Word: Equatable {
    case string(_: String)
    case symbol(_: String)
    case expression(_: [Word])
    case invalid(_: String)
    
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

let t = Transcoder()
let input = Array(CommandLine.arguments.dropFirst())
let lisp = input.joined(separator: " ")
let scanned = t.scan(text: lisp)
switch t.evaluate(words: scanned) {

case .invalid(let expression):
    print("[ERROR] invalid expression: " + expression)
case .valid(let expressions):
    let code = t.transcode(expressions: expressions)
    print(code)
}
