import Foundation

let input = Array(CommandLine.arguments.dropFirst())
let lisp = input.joined(separator: " ")
do {
    let scanned = try scan(lisp)
    switch evaluate(words: scanned) {
    case .failure(let error):
        print("[EvalError]: \(error)")
    case .success(let expressions):
        let code = transcode(expressions: expressions)
        print(code)
    }
}
catch {
    print("[ScanError]: \(error)")
}


