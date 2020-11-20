import Foundation

func transcode(_ lisp: String) {
    do {
        let scanned = try scan(lisp)
        let expressions = try evaluate(words: scanned, scope: initialScope)
        let code = transcode(expressions: expressions, library: Array(standardFunctions.values))
        print(code)
    }
    catch {
        print("\(error)")
    }
}

let input = Array(CommandLine.arguments.dropFirst())

if input.first == "-f" {
    let filename = input[1]
    if let contents = try? String(contentsOfFile: filename) {
        transcode(contents)
    }
    else {
        print("Could not read from \(filename)")
    }
}
else {
    let lisp = input.joined(separator: " ")
    transcode(lisp)
}
