import XCTest
@testable import Lisp2Swift

class Lisp2SwiftTests: XCTestCase {

    let parser = Parser()
    
    func scan(_ text: String) -> [Word] {
        return parser.scan(text: text)
    }
    
    func test_scan_emptyText() {
        XCTAssertEqual(scan(""), [])
    }
    
    func test_scan_doubleQuotedString() {
        XCTAssertEqual(scan("\"hello\""), [.string("\"hello\"")])
    }
    
    func test_scan_stringAndSymbol() {
        XCTAssertEqual(scan("\"hello\" foo"), [.string("\"hello\""), .symbol("foo")])
    }
    
    func test_scan_expressionWithDoubleQuotedString() {
        XCTAssertEqual(scan("(\"hello\")"), [.expression([.string("\"hello\"")])])
    }
    
    func test_scan_emptyExpression() {
        XCTAssertEqual(scan("()"), [.expression([])])
    }
    
    func test_scan_multipleParameterExpression() {
        XCTAssertEqual(scan("(hello world)"), [.expression([.symbol("hello"), .symbol("world")])])
    }
    
    func test_scan_unEndedExpression() {
        XCTAssertEqual(scan("("), [.invalid("(")])
    }
    
    func test_scan_unStartedExpression() {
        XCTAssertEqual(scan(")"), [.invalid(")")])
    }
    
    func test_scan_invalidExpression() {
        XCTAssertEqual(scan("basdf(foo"), [.invalid("basdf(foo")])
    }
    
    ///
    
    func test_parse_print_expression() throws {
        let lisp = """
        (print "hi")
        """
        let result = parser.parse(text: lisp)
        let subExpressions: [Expression] = [.symbol("print"), .string("\"hi\"")]
        XCTAssertEqual(result, .valid(expressions: [.expression(subExpressions)]))
    }
}
