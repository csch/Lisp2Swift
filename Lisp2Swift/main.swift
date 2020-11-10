import Foundation

let input = Array(CommandLine.arguments.dropFirst())
let lisp = input.joined(separator: " ")
do {
    let scanned = try scan(lisp)
    let expressions = try evaluate(words: scanned)
    let code = transcode(expressions: expressions)
    print(code)
}
catch {
    print("\(error)")
}


