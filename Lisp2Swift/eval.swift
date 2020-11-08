import Foundation

/// Function mappings

var declaredFunctions = [
    "+" : FnDecl(name: "add",
                 args: ["a, b"],
                 body: .special(swiftCode:
                    """
                    function add(a: Any, b: Any) -> Any {
                        return a
                    }
                    """)),
    "==" : FnDecl(name: "==",
                 args: ["a, b"],
                 body: .none)
]


enum EvalError: Error {
    case foo
}

func evaluate(words: [Word]) -> Result<[Expression], EvalError> {
    // on top level only expressions are valid
    if words.filter({$0.isExpression == false}).count > 0 {
        return .failure(.foo)
    }
    return evaluate(remaining: words, expressions: [])
}

func evaluate(remaining: [Word], expressions: [Expression]) -> Result<[Expression], EvalError> {    
    return .success([])
}

enum Expression: Equatable {
    case fncall(_ : FnCall)
    case string(_: String)
    case number(_: String)
    case expression(_: [Expression])
    case vector(_: [Expression])
}

enum FnBody: Equatable {
    case none
    case special(swiftCode: String)
    case lisp(expressions: [Expression])
}

struct FnDecl: Equatable {
    let name: String
    let args: [String]
    let body: FnBody
}

struct FnCall: Equatable {
    let name: String
    let args: [Expression]
}

//enum EvalExpression: Equatable {
//    case fncall(_: FnCall)
//    case string(_: String)
//    case number(_: String)
//    case symbol(_: String)
//    case invalid(_: String)
//    case unknownSymbol(_: String)
//    case expression(_: [EvalExpression])
//    case vector(_: [EvalExpression])
//
//    var firstInvalid: String? {
//        switch self {
//        case .invalid(let expression):
//            return expression
//        case .expression(let words):
//            return words.compactMap({$0.firstInvalid}).first
//        default:
//            return nil
//        }
//    }
//
//    var firstUnknown: String? {
//        switch self {
//        case .unknownSymbol(let symbol):
//            return symbol
//        case .expression(let expressions):
//            return expressions.compactMap({$0.firstUnknown}).first
//        default:
//            return nil
//        }
//    }
//
//    init(word: Word) {
//
//        // TODO: these symbols should be only valid in 1st position in an expression
//        let knownSymbols = [ "print", "+", "-", "*", "/", "<", ">", "==", ">=", "<=", "defn" ]
//
//        /// TODO: evaluate number of parameters for given functions
//
//        switch word {
//        case .invalid(let expr):
//            self = .invalid(expr)
//        case .expression(let words):
//            self = .expression(words.map(EvalExpression.init))
//        case .vector(let words):
//
//            // TODO: symbols inside a vector which is inside a defn need to be checked against known definitions
//            self = .vector(words.map(EvalExpression.init))
//        case .string(let string):
//            self = .string(string)
//        case .atom(let atom):
//            if knownSymbols.contains(atom) {
//                self = .symbol(atom)
//            }
//            else if let _ = Int(atom) {
//                self = .number(atom)
//            }
//            else {
//                self = .unknownSymbol(atom)
//            }
//        }
//    }
//}
