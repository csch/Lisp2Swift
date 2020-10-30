import Foundation

extension Character {
    var isWhitespace: Bool {
        return self == " " || self == "\t" || self == "\n"
    }
}

extension String {
    func substring(from: Int, length: Int) -> String {
        return (self as NSString).substring(with: NSMakeRange(from, length))
    }
}
