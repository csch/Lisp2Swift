import Foundation

func transcode(expression: Expression) -> String {
    
    switch expression {
    case .string(let string):
        return string
        
    case .fncall(let fnCall):
        fatalError("Implement me")
        
    case .number(let number):
        return number
        
    case .vector(let expressions):
        fatalError("Not implemented")
        
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
