import Foundation

/// Function mappings (see wrapper_functions.swift)

let standardFunctions = [
    "+" : FnDecl(name: "add",
                 args: ["a", "b"],
                 body: .none),
 
    "random" : FnDecl(name: "random",
                      args: ["a", "b"],
                      body: .none),
                    
    "str" : FnDecl(name: "str",
                   args: ["a"],
                   body: .none),
    
    "==" : FnDecl(name: "equal",
                 args: ["a" , "b"],
                 body: .none),
    
    "print" : FnDecl(name: "print",
                 args: ["a"],
                 body: .none),
    
    "readline" : FnDecl(name: "readLine",
                 args: [],
                 body: .none)
]

let initialScope = Scope(symbols: [], declaredFunctions: standardFunctions)

enum EvalError: Error, Equatable {
    case functionAlreadyExists(_ name: String)
    case invalidFunctionDeclaration
    case undeclaredFunction(_ name: String)
    case invalidExpression(_ words: [Word])
    case unknownSymbol(_ symbol: String)
    case incorrectArguments(function: String, args: [Word])
}

struct ScopedExpression {
    let expression: Expression
    let scope: Scope
}

struct Scope {
    let symbols: [String]
    let declaredFunctions: [String : FnDecl]
    func adding(symbols newSymbols: [String]) -> Scope {
        return Scope(symbols: symbols + newSymbols, declaredFunctions: declaredFunctions)
    }
    func adding(function: FnDecl, forName: String) -> Scope {
        var merged = declaredFunctions
        merged[forName] = function
        return Scope(symbols: symbols, declaredFunctions: merged)
    }
    func hasFunction(forName: String) -> Bool {
        return declaredFunctions[forName] != nil
    }
    func merging(other: Scope) -> Scope {
        let allSymbols = Set(symbols + other.symbols)
        let mergedFunctions = declaredFunctions.merging(other.declaredFunctions) { (a, b) in return a }
        return Scope(symbols: Array(allSymbols), declaredFunctions: mergedFunctions)
    }
}

func evaluate(words: [Word], scope: Scope) throws -> [Expression] {
    let scopedExpressions = try words.reduce([ScopedExpression](), { result, word in
        let scopedExpression = try evaluate(word: word, scope: result.last?.scope ?? scope)
        return result + [scopedExpression]
    })
    return scopedExpressions.map({$0.expression})
}

func sanitiseFunction(name: String) -> String {
    name.replacingOccurrences(of: "-", with: "_")
}

private func parseFunctionDeclaration(name: String, remainder: [Word], scope: Scope) throws -> FnDecl {
    let vector = remainder.first?.vector
    if let args = vector?.compactMap({$0.atom}), args.count == vector?.count {
        let fnName = sanitiseFunction(name: name)
        let parsedFunc = FnDecl(name: fnName, args: args, body: FnBody.none)
        let newScope = scope.adding(symbols: args).adding(function: parsedFunc, forName: name)
        let expressions = try evaluate(words: remainder.butFirst, scope: newScope)
        return FnDecl(name: fnName, args: args, body: FnBody.lisp(expressions: expressions))
    }
    throw EvalError.invalidFunctionDeclaration
}

private func parseFunctionCall(name: String, remainder: [Word], scope: Scope) throws -> Expression {
    if let fn = scope.declaredFunctions[name] {
        if fn.args.count == remainder.count {
            return .fncall(
                FnCall(
                    name: sanitiseFunction(name: fn.name),
                    args: try remainder.map({try evaluate(word: $0, scope: scope).expression})
                )
            )
        }
        else {
            throw EvalError.incorrectArguments(function: name, args: remainder)
        }
    }
    else {
        throw EvalError.undeclaredFunction(name)
    }
}

private func evaluate(word: Word, scope: Scope) throws -> ScopedExpression {
    let expression: Expression
    var updatedScope = scope
    switch word {
    case .expression(let words):
        
        guard let firstAtom = words.first?.atom else { throw EvalError.invalidExpression(words) }
        let remainder = words.butFirst
        
        if firstAtom == "defn" {
            guard let name = remainder.first?.atom else { throw EvalError.invalidFunctionDeclaration }
            guard scope.hasFunction(forName: name) == false else { throw EvalError.functionAlreadyExists(name) }
            let decl = try parseFunctionDeclaration(name: name, remainder: remainder.butFirst, scope: scope)
            updatedScope = updatedScope.adding(function: decl, forName: name)
            expression = .fndecl(decl)
        }
        else if firstAtom == "if" {
            let expressions = try remainder.map({try evaluate(word: $0, scope: scope).expression})
            guard expressions.count == 2 || expressions.count == 3 else {
                throw EvalError.invalidExpression(words)
            }
            expression = .ifelse(
                condition: expressions[0],
                ifExpression: expressions[1],
                elseExpression: expressions.last
            )
        }
        else if firstAtom == "do" {
            let expressions = try remainder.map({try evaluate(word: $0, scope: scope).expression})
            expression = .docall(expressions: expressions)
        }
        else if firstAtom == "let" {
            guard let oddElements = remainder.first?.vector?.oddElements, oddElements.allSatisfy({$0.atom != nil}) else {
                throw EvalError.invalidExpression(words)
            }
            let vectorSymbols = oddElements.compactMap({$0.atom})
            let expressions = try remainder.map({try evaluate(word: $0, scope: scope.adding(symbols: vectorSymbols)).expression})
            guard case .vector(let vectorExpressions) = expressions.first, expressions.count >= 2 else {
                throw EvalError.invalidExpression(words)
            }
            expression = .letExpression(vector: vectorExpressions, expressions: expressions.butFirst)
        }
        else {
            expression = try parseFunctionCall(name: firstAtom, remainder: remainder, scope: scope)
        }
    case .vector(let words):
        expression = .vector(try words.map({try evaluate(word: $0, scope: scope).expression}))
    case .atom(let atom):
        if scope.symbols.contains(atom) {
            expression = .symbol(atom)
        }
        else {
            throw EvalError.unknownSymbol(atom)
        }
    case .number(let number):
        expression = .number(number)
    case .string(let string):
        expression = .string(string)
    }
    return ScopedExpression(expression: expression, scope: updatedScope)
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
    case none // already defined via `swift-wrappers.swift`
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
