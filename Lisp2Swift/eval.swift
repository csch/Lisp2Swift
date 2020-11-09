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
//    // on top level only expressions are valid
//    if words.filter({$0.isExpression == false}).count > 0 {
//        return .failure(.foo)
//    }
    do {
        return .success(try words.map({ try evaluate(word: $0)}))
    }
    catch {
        return .failure(.foo)
    }
}

// TODO: need to restructure this
private func evaluate(word: Word) throws -> Expression {
    switch word {
    case .expression(let words):
        guard let firstAtom = words.first?.atom else { throw EvalError.foo }
        // let symbols = words.butFirst.compactMap({$0.atom})
        // TODO: check if symbols are declared
        if let fn = declaredFunctions[firstAtom], fn.args.count == words.butFirst.count {
            return .fncall(FnCall(name: fn.name, args: try words.butFirst.map({try evaluate(word: $0)})))
        }
        else {
            throw EvalError.foo
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
