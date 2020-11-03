import Foundation

let input = Array(CommandLine.arguments.dropFirst())
let lisp = input.joined(separator: " ")
let scanned = scan(lisp)
switch evaluate(words: scanned) {

case .invalid(let expression):
    print("[ERROR] Invalid expression: " + expression)
case .unknown(let symbol):
    print("[ERROR] Unknown symbol: " + symbol)
case .valid(let expressions):
    let code = transcode(expressions: expressions)
    print(code)
    
}
