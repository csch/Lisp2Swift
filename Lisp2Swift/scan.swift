import Foundation

enum Word: Equatable {
    case string(_: String)
    case atom(_: String)
    case expression(_: [Word])
    case invalid(_: String)
}

extension Transcoder {
    
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
