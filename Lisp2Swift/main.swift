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
    case atom(_: String)
    case expression(_: [Word])
    case invalid(_: String)    
}

enum EvalExpression: Equatable {
    
    case string(_: String)
    case number(_: String)
    case symbol(_: String)
    case invalid(_: String)
    case unknownSymbol(_: String)
    case expression(_: [EvalExpression])
    
    var firstInvalid: String? {
        switch self {
        case .invalid(let expression):
            return expression
        case .expression(let words):
            return words.compactMap({$0.firstInvalid}).first
        default:
            return nil
        }
    }
    
    var firstUnknown: String? {
        switch self {
        case .unknownSymbol(let symbol):
            return symbol
        case .expression(let expressions):
            return expressions.compactMap({$0.firstUnknown}).first
        default:
            return nil
        }
    }
    
    init(word: Word) {
        
        let knownSymbols = [ "print", "+" ]
        
        switch word {
        case .invalid(let expr):
            self = .invalid(expr)
        case .expression(let words):
            self = .expression(words.map(EvalExpression.init))
        case .string(let string):
            self = .string(string)
        case .atom(let atom):
            if knownSymbols.contains(atom) {
                self = .symbol(atom)
            }
            else if let _ = Int(atom) {
                self = .number(atom)
            }
            else {
                self = .unknownSymbol(atom)
            }
        }
    }
}

enum Expression: Equatable {
    case string(_: String)
    case number(_: String)
    case symbol(_: String)
    case expression(_: [Expression])
    
    init(evalExpression: EvalExpression) {
        switch evalExpression {
        
        case .invalid, .unknownSymbol:
            fatalError("Cannot be transformed into valid `Expression`")
        
        case .expression(let expressions):
            self = .expression(expressions.map(Expression.init))
        case .number(let number):
            self = .number(number)
        case .string(let string):
            self = .string(string)
        case .symbol(let string):
            self = .symbol(string)
        }
    }
}

enum Evaluation: Equatable {
    case valid(expressions: [Expression])
    case unknown(symbol: String)
    case invalid(expression: String)
}

class Transcoder {
    
    func evaluate(words: [Word]) -> Evaluation {
        
        let evalExpressions = words.map({EvalExpression(word: $0)})
        if let invalid = evalExpressions.compactMap({$0.firstInvalid}).first {
            return .invalid(expression: invalid)
        }
        if let unknown = evalExpressions.compactMap({$0.firstUnknown}).first {
            return .unknown(symbol: unknown)
        }
        
        let expressions = evalExpressions.map(Expression.init)
        return .valid(expressions: expressions)
    }
    
    func transcode(expression: Expression) -> String {
        
        switch expression {
        case .string(let string):
            return string
            
        case .symbol(let symbol):
            return symbol
            
        case .number(let number):
            return number
        
        case .expression(let expressions):
            // TODO: go through the sub expressions and apply them
            if expressions.count < 2 { fatalError("Transcode: Unexpected number of expression") }
            let command = transcode(expression: expressions[0])
            let params = Array(expressions.dropFirst()).map(transcode(expression:))
            switch command {
            case "print":
                let printParams = params.joined(separator: ",")
                return command + "(" + printParams + ")"
            case "+":
                let addition = params.joined(separator: " + ")
                return "(\(addition))"
            default:
                fatalError("Transcode: Unexpected command: \(command)")
            }
        }
    }

    func transcode(expressions: [Expression]) -> String {
        return expressions.map({transcode(expression: $0) + "\n"}).reduce("", +)
    }
}

let t = Transcoder()
let input = Array(CommandLine.arguments.dropFirst())
let lisp = input.joined(separator: " ")
let scanned = t.scan(lisp)
switch t.evaluate(words: scanned) {

case .invalid(let expression):
    print("[ERROR] Invalid expression: " + expression)
case .unknown(let symbol):
    print("[ERROR] Unknown symbol: " + symbol)
case .valid(let expressions):
    let code = t.transcode(expressions: expressions)
    print(code)
    
}
