import Foundation

enum Word: Equatable {
    case string(_: String)
    case atom(_: String)
    case expression(_: [Word])
    case vector(_: [Word])
    case invalid(_: String)
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
    let process: ((Extraction) -> [Word])
        
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
        return [extraction.targetCharacterFound ?
                    .string(extraction.text) : .invalid(extraction.text)]
    }),
    Strategy(start: "(", end: ")", stopAtWhitespace: false, allowNesting: true, process: { extraction in
        return [extraction.targetCharacterFound ?
                    .expression(scan(extraction.text.shrunken)) : .invalid(extraction.text)]
    }),
    Strategy(start: "[", end: "]", stopAtWhitespace: false, allowNesting: true, process: { extraction in
        return [extraction.targetCharacterFound ?
                    .vector(scan(extraction.text.shrunken)) : .invalid(extraction.text)]
    }),
    Strategy(start: nil, end: nil, stopAtWhitespace: true, allowNesting: false, process: { extraction in
        if extraction.text.contains("(") || extraction.text.contains(")") {
            return [.invalid(extraction.text)]
        }
        return [.atom(extraction.text)]
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

private func scan(index: Int, text: String, collected: [Word]) -> [Word] {
    guard index < text.count else { return collected }
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
        let newCollected = collected + strategy.process(extraction)
        return scan(index: index + extraction.text.count, text: text, collected: newCollected)
    }
    else {
        return collected
    }
}

func scan(_ text: String) -> [Word] {
    let updatedText = text.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "\t", with: " ")
    return scan(index: 0, text: updatedText, collected: [])
}

