import Foundation

enum ScanError: Error {
    case invalidExpression(_ text: String)
}

enum Word: Equatable {
    case string(_: String)
    case number(_ : String)
    case atom(_: String)
    case expression(_: [Word])
    case vector(_: [Word])
     
    var atom: String? {
        if case .atom(let str) = self {
            return str
        }
        return nil
    }
        
    var isExpression: Bool {
        if case .expression = self {
            return true
        }
        return false
    }
}

struct Extraction {
    let text: String
    let targetCharacterFound: Bool
}

struct Strategy {
    let start: Character?
    let end: Character?
    let stopAtWhitespace: Bool
    let allowNesting: Bool
    let process: ((Extraction) -> Result<[Word], ScanError>)
        
    func matches(character: Character) -> Bool {
        if let start = start {
            return start == character
        }
        else {
            return true
        }
    }
    
    func nestingDelta(for character: Character) -> Int {
        if allowNesting, character == start { return 1 }
        if allowNesting, character == end { return -1 }
        return 0
    }
}

let strategies = [
    Strategy(start: "\"", end: "\"", stopAtWhitespace: false, allowNesting: false, process: { extraction in
        return extraction.targetCharacterFound ?
            .success([.string(extraction.text)]) : .failure(ScanError.invalidExpression(extraction.text))
    }),
    Strategy(start: "(", end: ")", stopAtWhitespace: false, allowNesting: true, process: { extraction in
        if extraction.targetCharacterFound {
            let result = scan(extraction.text.shrunken)
            return result.map({[.expression($0)]})
        }
        else {
            return .failure(.invalidExpression(extraction.text))
        }
    }),
    Strategy(start: "[", end: "]", stopAtWhitespace: false, allowNesting: true, process: { extraction in
        if extraction.targetCharacterFound {
            let result = scan(extraction.text.shrunken)
            return result.map({[.expression($0)]})
        }
        else {
            return .failure(.invalidExpression(extraction.text))
        }
    }),
    Strategy(start: nil, end: nil, stopAtWhitespace: true, allowNesting: false, process: { extraction in
        if extraction.text.contains("(") || extraction.text.contains(")") {
            return .failure(.invalidExpression(extraction.text))
        }
        let result: Word
        if Int(extraction.text) != nil || Double(extraction.text) != nil {
            result = .number(extraction.text)
        }
        else {
            result = .atom(extraction.text)
        }
        return .success([result])
    }),
]

private func append(index: Int, strategy: Strategy, nestingLevel: Int, from source: String, to result: String) -> Extraction {
    guard index < source.count && (source.character(at: index) != " " || strategy.stopAtWhitespace == false) else {
        return Extraction(text: result, targetCharacterFound: false)
    }
    let character = source.character(at: index)
    let newText = result + String(character)
    if let target = strategy.end, character == target, nestingLevel == 0 {
        return Extraction(text: newText, targetCharacterFound: true)
    }
    else {
        return append(index: index + 1, strategy: strategy, nestingLevel: nestingLevel + strategy.nestingDelta(for: character), from: source, to: newText)
    }
}

private func scan(index: Int, text: String, collected: [Word]) -> Result<[Word], ScanError> {
    guard index < text.count else { return .success(collected) }
    let character = text.character(at: index)
    if character == " " {
        return scan(index: index + 1, text: text, collected: collected)
    }
    else if let strategy = strategies.first(where: {$0.matches(character: character)}) {
        let extraction = append(
            index: index + 1,
            strategy: strategy,
            nestingLevel: 0,
            from: text,
            to: String(character)
        )
        let result = strategy.process(extraction)
        switch result {
        case .failure:
            return result
        case .success(let words):
            return scan(index: index + extraction.text.count, text: text, collected: collected + words)
        }        
    }
    else {
        return .success(collected)
    }
}

func scan(_ text: String) -> Result<[Word], ScanError> {
    let updatedText = text.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "\t", with: " ")
    return scan(index: 0, text: updatedText, collected: [])
}

