import Foundation

let input = Array(CommandLine.arguments.dropFirst())
let lisp = input.joined(separator: " ")
let scanned = scan(lisp)

switch scanned {

case .failure(let error):
    print("[ScanError]: \(error)")
case .success(let words):
    switch evaluate(words: words) {
    case .failure(let error):
        print("[EvalError]: \(error)")
    case .success(let expressions):
        let code = transcode(expressions: expressions)
        print(code)
    }
}

