import XCTest

class Lisp2SwiftTests: XCTestCase {

    let transcoder = Transcoder()
        
    func scan(_ text: String) -> [Word] {
        return transcoder.scan(text)
    }
    
    func eval(_ text: String) -> Evaluation {
        let words = scan(text)
        return transcoder.evaluate(words: words)
    }
    
    func l2s(_ text: String) -> String {
        let words = scan(text)
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
        XCTAssertEqual(scan("\"hello\" foo"), [.string("\"hello\""), .atom("foo")])
    }
    
    func test_scan_expressionWithDoubleQuotedString() {
        XCTAssertEqual(scan("(\"hello\")"), [.expression([.string("\"hello\"")])])
    }
    
    func test_scan_multiAtomExpressionWithSpaces() {
        XCTAssertEqual(scan("   (test foo) "), [.expression([.atom("test"), .atom("foo")])])
    }
    
    func test_scan_emptyExpression() {
        XCTAssertEqual(scan("()"), [.expression([])])
    }
    
    func test_scan_multipleParameterExpression() {
        XCTAssertEqual(scan("(hello world)"), [.expression([.atom("hello"), .atom("world")])])
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
        let expected: [Word] = [.expression([.atom("foo")]), .expression([.atom("bar")])]
        XCTAssertEqual(scan("(foo)\n(bar)"), expected)
    }
    
    func test_scan_nestedExpression() {
        let expected: [Word] = [.expression([
            .atom("print"),
            .expression([.atom("+"), .atom("1"), .atom("2"), .atom("3")])
        ])]
        XCTAssertEqual(scan("(print (+ 1 2 3))"), expected)
    }
        
    /// EVAL
    
    func assertExpression(with expressions: [Expression], for lisp: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(eval(lisp), .valid(expressions: [.expression(expressions)]), file: file, line: line)
    }
    
    func test_eval_print_expression() throws {
        let lisp = """
        (print "hi")
        """
        assertExpression(with: [.symbol("print"), .string("\"hi\"")], for: lisp)
    }
    
    func test_eval_foo_expression() throws {
        let lisp = """
        (foo "hi")
        """
        let result = eval(lisp)
        XCTAssertEqual(result, .unknown(symbol: "foo"))
    }
    
    func test_eval_number_expression() throws {
        let lisp = """
        (print 123)
        """
        assertExpression(with: [.symbol("print"), .number("123")], for: lisp)
    }
    
    func test_eval_add_expression() throws {
        let lisp = """
        (+ 1 2 3)
        """
        assertExpression(with: [.symbol("+"), .number("1"), .number("2"), .number("3")], for: lisp)
    }
    
    func test_eval_nested_expression() throws {
        let lisp = """
        (print (+ 1 2 3))
        """
        assertExpression(with: [.symbol("print"),
                                .expression([.symbol("+"), .number("1"), .number("2"), .number("3")])],
                                for: lisp)
    }
    
    func test_scan_lowerThanExpression() {
        let lisp = """
        (< 4 5)
        """
        assertExpression(with: [.symbol("<"), .number("4"), .number("5")], for: lisp)
    }

    
    /// TRANSCODE
    
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
    
    func test_transcode_add_expression() throws {
        let lisp = """
        (+ 1 2 3)
        """
        let result = l2s(lisp)
        XCTAssertEqual(result, "(1 + 2 + 3)\n")
    }
    
    func test_transcode_printSmaller_expression() throws {
        let lisp = """
        (print (< 1 3))
        """
        let result = l2s(lisp)
        XCTAssertEqual(result, "print(1 < 3)\n")
    }
}

extension Evaluation {
    var expressions: [Expression]? {
        switch self {
        case .valid(let expressions):
            return expressions
        case .invalid:
            return nil
        case .unknown:
            return nil
        }
    }
}
