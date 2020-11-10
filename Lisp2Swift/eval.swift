import Foundation

/// Function mappings

var declaredFunctions = [
    "+" : FnDecl(name: "add",
                 args: ["a", "b"],
                 body: .special(swiftCode:
                    """
                    function add(a: Any, b: Any) -> Any {
                        return a
                    }
                    """)),
    
    "==" : FnDecl(name: "==",
                 args: ["a" , "b"],
                 body: .none),
    
    "print" : FnDecl(name: "print",
                 args: ["a"],
                 body: .none)
]


enum EvalError: Error, Equatable {
    case foo
    case invalidFunctionDeclaration
    case undeclaredFunction
    case unknownExpression
    case incorrectArguments(_ args: [Word])
}

func evaluate(words: [Word]) throws -> [Expression] {
    return try words.map({ try evaluate(word: $0)})
}

private func parseFunctionDeclaration(name: String, remainder: [Word]) throws -> Expression {
    throw EvalError.invalidFunctionDeclaration
}

private func parseFunctionCall(name: String, remainder: [Word]) throws -> Expression {
    if let fn = declaredFunctions[name] {
        if fn.args.count == remainder.count {
            return .fncall(FnCall(name: fn.name, args: try remainder.map({try evaluate(word: $0)})))
        }
        else {
            throw EvalError.incorrectArguments(remainder)
        }
    }
    else {
        throw EvalError.undeclaredFunction
    }
}

private func evaluate(word: Word) throws -> Expression {
    switch word {
    case .expression(let words):
        
        guard let firstAtom = words.first?.atom else { throw EvalError.unknownExpression }
        let remainder = words.butFirst
        
        if firstAtom == "defn", let name = remainder.first?.atom {
            return try parseFunctionDeclaration(name: name, remainder: remainder.butFirst)
        }
        else {
            return try parseFunctionCall(name: firstAtom, remainder: remainder)
        }
    case .vector(let words):
        return .vector(try words.map({try evaluate(word: $0)}))
    case .atom:
        fatalError("Not implemented")
    case .number(let number):
        return .number(number)
    case .string(let string):
        return .string(string)
    }
}

enum Expression: Equatable {
    case fndecl(_ : FnDecl)
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
