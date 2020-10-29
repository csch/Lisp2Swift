import XCTest
@testable import Lisp2Swift

class Lisp2SwiftTests: XCTestCase {

    let transcoder = Transcoder()
    
    func scan(_ text: String) -> [Word] {
        return transcoder.scan(text: text)
    }
    
    func l2s(_ text: String) -> String {
        let words = transcoder.scan(text: text)
        let result = transcoder.evaluate(words: words)
        return transcoder.transcode(expressions: result.expressions!)
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
    
    func test_scan_multiAtomExpressionWithSpaces() {
        XCTAssertEqual(scan("   (test foo) "), [.expression([.symbol("test"), .symbol("foo")])])
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
    
    func test_scan_expressionsWithNewLine() {
        let expected: [Word] = [.expression([.symbol("foo")]), .expression([.symbol("bar")])]
        XCTAssertEqual(scan("(foo)\n(bar)"), expected)
    }
    
    func test_evaluate_print_expression() throws {
        let lisp = """
        (print "hi")
        """
        let words = transcoder.scan(text: lisp)
        let result = transcoder.evaluate(words: words)
        let subExpressions: [Expression] = [.symbol("print"), .string("\"hi\"")]
        XCTAssertEqual(result, .valid(expressions: [.expression(subExpressions)]))
    }
    
    func test_transcode_print_expression() throws {
        let lisp = """
        (print "hi")
        """
        let result = l2s(lisp)
        XCTAssertEqual(result, "print(\"hi\")\n")
    }
    
    func test_transcode_2_print_expressions() throws {
        let lisp = """
        (print "hello")
        (print "world")
        """
        let expected = """
        print(\"hello\")
        print(\"world\")

        """
        let result = l2s(lisp)
        XCTAssertEqual(result, expected)
    }
}

extension Evaluation {
    var expressions: [Expression]? {
        switch self {
        case .valid(let expressions):
            return expressions
        case .invalid:
            return nil
        }
    }
}
