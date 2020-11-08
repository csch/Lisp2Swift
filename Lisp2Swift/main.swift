import Foundation

let input = Array(CommandLine.arguments.dropFirst())
let lisp = input.joined(separator: " ")
let scanned = scan(lisp)
switch evaluate(words: scanned) {

case .failure(let error):
    print("[ERROR]: \(error)")
case .success(let expressions):
    let code = transcode(expressions: expressions)
    print(code)
    
}
