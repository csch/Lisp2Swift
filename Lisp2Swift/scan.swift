import Foundation

enum Word: Equatable {
    case string(_: String)
    case atom(_: String)
    case expression(_: [Word])
    case invalid(_: String)
}

struct Extraction {
    let text: String
    let targetCharacterFound: Bool
}

struct Strategy {
    let start: Character?
    let end: Character?
    let process: ((Extraction) -> [Word])
    
    func matches(character: Character) -> Bool {
        if let start = start {
            return start == character
        }
        else {
            return true
        }
    }
}

let strategies = [
    Strategy(start: "\"", end: "\"", process: { extraction in
        return [extraction.targetCharacterFound ?
                    .string(extraction.text) : .invalid(extraction.text)]
    }),
    Strategy(start: nil, end: nil, process: { extraction in
        return [.atom(extraction.text)]
    })
]

extension String {
    func character(at index: Int) -> Character {
        self[self.index(startIndex, offsetBy: index)]
    }
}

extension Transcoder {
        
    private func append(index: Int, untilEndOrTargetCharacter target: Character?, from source: String, to result: String) -> Extraction {
        guard index < source.count && source.character(at: index) != " " else {
            return Extraction(text: result, targetCharacterFound: false)
        }
        let character = source.character(at: index)
        let newText = result + String(character)
        if let target = target, character == target {
            return Extraction(text: newText, targetCharacterFound: true)
        }
        else {
            return append(index: index + 1, untilEndOrTargetCharacter: target, from: source, to: newText)
        }
    }
    
    private func scan2(index: Int, text: String, collected: [Word]) -> [Word] {
        guard index < text.count else { return collected }
        let character = text.character(at: index)
        if character == " " {
            return scan2(index: index + 1, text: text, collected: collected)
        }
        else if let strategy = strategies.first(where: {$0.matches(character: character)}) {
            let extraction = append(index: index + 1, untilEndOrTargetCharacter: strategy.end, from: text, to: String(character))
            let newCollected = collected + strategy.process(extraction)
            return scan2(index: index + extraction.text.count, text: text, collected: newCollected)
        }
        else {
            return collected
        }
    }
    
    func scan2(_ text: String) -> [Word] {
        let updatedText = text.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "\t", with: " ")
        return scan2(index: 0, text: updatedText, collected: [])
    }
    
    func scan(_ text: String) -> [Word] {
        var exprLevel = 0
        var isString = false
        var start: Int?
        var words = [Word]()
        var lastChar: Character?
        
        for (index, char) in text.enumerated() {
            let isEnd = index == text.count-1
            if char == "\"" && exprLevel == 0 {
                if isString {
                    let sub = text.substring(from: start!, length: index + 1 - start!)
                    words.append(.string(sub))
                    isString = false
                    start = nil
                }
                else if isEnd {
                    words.append(.invalid(text))
                }
                else {
                    isString = true
                    start = index
                }
            }
            else if char == "(" && !isString {
                if (lastChar != nil && lastChar!.isWhitespace == false) || isEnd {
                    words.append(.invalid(text))
                }
                else if exprLevel == 0 {
                    start = index + 1
                }
                exprLevel += 1
            }
            else if char == ")" && !isString {
                exprLevel -= 1
                if exprLevel == 0 {
                    let substring = text.substring(from: start!, length: index - start!)
                    words.append(.expression(scan(substring)))
                    start = nil
                }
                else if isEnd {
                    words.append(.invalid(text))
                }
            }
            else if !isString && exprLevel == 0 {
                if char.isWhitespace == false && start == nil {
                    start = index
                    if isEnd {
                        words.append(.atom(String(char)))
                    }
                }
                
                else if (char.isWhitespace || isEnd) && start != nil  {
                    let offset = char.isWhitespace ? -1 : 0
                    let substring = text.substring(from: start!, length: index + 1 - start! + offset)
                    words.append(.atom(substring))
                    start = nil
                }
            }
            lastChar = char
        }
        return words
    }
}
