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

func printHelp() {
    print("l2sc [-f filename] OR (lisp)")
}

let input = Array(CommandLine.arguments.dropFirst())

if input.first == "-f" {
    guard input.count == 2 else {
        printHelp()
        exit(1)
    }
    let filename = input[1]
    print("// Parsing from file: \(filename) //")
    if let contents = try? String(contentsOfFile: filename) {
        transcode(contents)
    }
    else {
        print("Could not read from \(filename)")
    }
}
else {
    print("// Parsing from commandline //")
    let lisp = input.joined(separator: " ")
    transcode(lisp)
}


