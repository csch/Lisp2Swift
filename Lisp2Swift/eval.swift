import Foundation

extension Transcoder {
    
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
}

enum Evaluation: Equatable {
    case valid(expressions: [Expression])
    case unknown(symbol: String)
    case invalid(expression: String)
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
        
        let knownSymbols = [ "print", "+", "-", "*", "/", "<", ">", "==", ">=", "<=" ]
        
        /// TODO: evaluate number of parameters for given functions
        
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
