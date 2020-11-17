import Foundation

/// Function mappings


func sanitiseFunction(name: String) -> String {
    name.replacingOccurrences(of: "-", with: "_")
}

// TODO: this shouldn't be a global variable (because tests currently reuse it)
var declaredFunctions = [
    "+" : FnDecl(name: "add",
                 args: ["a", "b"],
                 body: .special(swiftCode:
                    """
                    func add(_ a: Any, _ b: Any) -> Any {
                        return a
                    }
                    """)),
    
    "==" : FnDecl(name: "equal",
                 args: ["a" , "b"],
                 body: .special(swiftCode:
                    """
                    func equal(_ a: Any, _ b: Any) -> Bool {
                        if let lh = a as? NSNumber, let rh = b as? NSNumber {
                            return lh == rh
                        }
                        else if let lh = a as? String, let rh = b as? String {
                            return lh == rh
                        }
                        else {
                            return false
                        }
                    }
                    """)),
    
    "print" : FnDecl(name: "print",
                 args: ["a"],
                 body: .none),
    
    "readline" : FnDecl(name: "readLine",
                 args: [],
                 body: .none)
]

enum EvalError: Error, Equatable {
    case foo
    case functionAlreadyExists(_ name: String)
    case invalidFunctionDeclaration
    case undeclaredFunction(_ name: String)
    case invalidExpression(_ words: [Word])
    case unknownSymbol(_ symbol: String)
    case incorrectArguments(_ args: [Word])
}

struct Scope {
    let symbols: [String]
    func adding(symbols newSymbols: [String]) -> Scope {
        return Scope(symbols: symbols + newSymbols)
    }
    static let empty = Scope(symbols: [])
}

func evaluate(words: [Word], scope: Scope = .empty) throws -> [Expression] {
    return try words.map({ try evaluate(word: $0, scope: scope)})
}

private func parseFunctionDeclaration(name: String, remainder: [Word]) throws -> FnDecl {
    let vector = remainder.first?.vector
    if let args = vector?.compactMap({$0.atom}), args.count == vector?.count {
        let scope = Scope(symbols: args)
        // add temporary function declaration so we can parse recursive calls
        let fnName = sanitiseFunction(name: name)
        declaredFunctions[name] = FnDecl(name: fnName, args: args, body: FnBody.none)
        let expressions = try evaluate(words: remainder.butFirst, scope: scope)
        return FnDecl(name: fnName, args: args, body: FnBody.lisp(expressions: expressions))
    }
    throw EvalError.invalidFunctionDeclaration
}

private func parseFunctionCall(name: String, remainder: [Word], scope: Scope) throws -> Expression {
    if let fn = declaredFunctions[name] {
        if fn.args.count == remainder.count {
            return .fncall(FnCall(name: sanitiseFunction(name: fn.name), args: try remainder.map({try evaluate(word: $0, scope: scope)})))
        }
        else {
            throw EvalError.incorrectArguments(remainder)
        }
    }
    else {
        throw EvalError.undeclaredFunction(name)
    }
}

private func evaluate(word: Word, scope: Scope) throws -> Expression {
    switch word {
    case .expression(let words):
        
        guard let firstAtom = words.first?.atom else { throw EvalError.invalidExpression(words) }
        let remainder = words.butFirst
        
        if firstAtom == "defn" {
            guard let name = remainder.first?.atom else { throw EvalError.invalidFunctionDeclaration }
            guard declaredFunctions[name] == nil else { throw EvalError.functionAlreadyExists(name) }
            let decl = try parseFunctionDeclaration(name: name, remainder: remainder.butFirst)
            declaredFunctions[name] = decl
            return .fndecl(decl)
        }
        else if firstAtom == "if" {
            let expressions = try remainder.map({try evaluate(word: $0, scope: scope)})
            guard expressions.count == 2 || expressions.count == 3 else {
                throw EvalError.invalidExpression(words)
            }
            return .ifelse(condition: expressions[0], ifExpression: expressions[1], elseExpression: expressions.last)
        }
        else if firstAtom == "do" {
            let expressions = try remainder.map({try evaluate(word: $0, scope: scope)})
            return .docall(expressions: expressions)
        }
        else if firstAtom == "let" {
            guard let oddElements = remainder.first?.vector?.oddElements, oddElements.allSatisfy({$0.atom != nil}) else {
                throw EvalError.invalidExpression(words)
            }
            let vectorSymbols = oddElements.compactMap({$0.atom})
            let expressions = try remainder.map({try evaluate(word: $0, scope: scope.adding(symbols: vectorSymbols))})
            guard case .vector(let vectorExpressions) = expressions.first, expressions.count >= 2 else {
                throw EvalError.invalidExpression(words)
            }
            return .letExpression(vector: vectorExpressions, expressions: expressions.butFirst)
        }
        else {
            return try parseFunctionCall(name: firstAtom, remainder: remainder, scope: scope)
        }
    case .vector(let words):
        return .vector(try words.map({try evaluate(word: $0, scope: scope)}))
    case .atom(let atom):
        if scope.symbols.contains(atom) {
            return .symbol(atom)
        }
        else {
            throw EvalError.unknownSymbol(atom)
        }
    case .number(let number):
        return .number(number)
    case .string(let string):
        return .string(string)
    }
}

indirect enum Expression: Equatable {
    case fndecl(_ : FnDecl)
    case fncall(_ : FnCall)
    case docall(expressions: [Expression])
    case ifelse(condition: Expression, ifExpression: Expression, elseExpression: Expression?)
    case letExpression(vector: [Expression], expressions: [Expression])
    case expression(_: [Expression])
    case vector(_: [Expression])
    case string(_: String)
    case symbol(_: String)
    case number(_: String)
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
  
    var specialSwiftCode: String? {
        if case .special(let code) = body {
            return code
        }
        else {
            return nil
        }
    }        
}

struct FnCall: Equatable {
    let name: String
    let args: [Expression]
}
