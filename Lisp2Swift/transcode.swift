import Foundation

func transcode(expression: Expression) -> String {
    
    switch expression {
    case .string(let string):
        return string
    
    case .fndecl(let fnDecl):
        if case .lisp(let expressions) = fnDecl.body {
            let args = fnDecl.args.map({"_ " + $0 + ": Any"}).joined(separator: ",")
            let bodyBody = transcode(expressions: expressions)
            return """
                   func \(fnDecl.name) (\(args)) {
                       \(bodyBody)
                   }
                   """
        }
        else {
            return ""
        }
        
    case .fncall(let fnCall):
        let args = fnCall.args.map(transcode)
        return fnCall.name + "(" + args.joined(separator: ",") + ")"
    
    case .symbol(let symbol):
        return symbol
        
    case .number(let number):
        return number
        
    case .vector(let expressions):
        fatalError("Not implemented")
        
    case .ifelse(let condition, let ifExpression, let elseExpression):
        let condCode = transcode(expression: condition)
        let ifCode = transcode(expression: ifExpression)
        let elseCode = elseExpression.map(transcode(expression:))
        let ifSwift = """
                      if \(condCode) {
                        \(ifCode)
                      }
                      """
        if let elseCode = elseCode {
            return ifSwift +
            """
            else {
              \(elseCode)
            }
            """
        }
        else {
            return ifSwift
        }
        
    case .expression(let expressions):
        // TODO: go through the sub expressions and apply them
        if expressions.count < 2 { fatalError("Transcode: Unexpected number of expression") }
        let command = transcode(expression: expressions[0])
        let params = Array(expressions.dropFirst()).map(transcode(expression:))
        
        ///
        /// TODO: 1. simplify/clean up functions that work in the same manner
        ///
        switch command {
        case "print":
            let printParams = params.joined(separator: ",")
            return command + "(" + printParams + ")"
        case "+", "-", "*", "/":
            let equation = params.joined(separator: " \(command) ")
            return "(\(equation))"
        case "<", ">", ">=", "<=", "==":
            return params[0] + " \(command) " + params[1]
        default:
            fatalError("Transcode: Unexpected command: \(command)")
        }
    }
}

func transcode(expressions: [Expression]) -> String {
    return expressions.map({transcode(expression: $0) + "\n"}).reduce("", +)
}

func transcode(expressions: [Expression], library: [FnDecl]) -> String {
    let imports = "import Foundation"
    let header = library.compactMap({$0.specialSwiftCode}).joined(separator: "\n")
    let transcoded = transcode(expressions: expressions)
    return [imports, header, transcoded].joined(separator: "\n")
}

