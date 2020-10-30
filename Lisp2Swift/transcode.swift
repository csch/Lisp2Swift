import Foundation

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

class Transcoder {
    
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
}
