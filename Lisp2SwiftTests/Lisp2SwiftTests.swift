import XCTest

class Lisp2SwiftTests: XCTestCase {
    
    func _scan(_ text: String) -> [Word] {
        let result = scan(text)
        switch result {
        case .failure:
            return []
        case .success(let words):
            return words
        }
    }
    
    func eval(_ text: String) -> Result<[Expression], EvalError> {
        return evaluate(words: _scan(text))
    }
    
    func l2s(_ text: String) -> String {
        let result = eval(text)
        switch result {
        case .failure:
            return ""
        case .success(let expressions):
            return transcode(expressions: expressions)
        }
    }
    
    // scan
    
    func test_scan_emptyText() {
        XCTAssertEqual(_scan(""), [])
    }
    
    func test_scan_Integer() {
        XCTAssertEqual(_scan("123"), [.number("123")])
    }
    
    func test_scan_Double() {
        XCTAssertEqual(_scan("123.12"), [.number("123.12")])
    }
    
    func test_scan_doubleQuotedString() {
        XCTAssertEqual(_scan("\"hello\""), [.string("\"hello\"")])
    }
    
    func test_scan_stringAndSymbol() {
        XCTAssertEqual(_scan("\"hello\" foo"), [.string("\"hello\""), .atom("foo")])
    }
    
    func test_scan_expressionWithDoubleQuotedString() {
        XCTAssertEqual(_scan("(\"hello\")"), [.expression([.string("\"hello\"")])])
    }
    
    func test_scan_multiAtomExpressionWithSpaces() {
        XCTAssertEqual(_scan("   (test foo) "), [.expression([.atom("test"), .atom("foo")])])
    }
    
    func test_scan_emptyExpression() {
        XCTAssertEqual(_scan("()"), [.expression([])])
    }
    
    func test_scan_multipleParameterExpression() {
        XCTAssertEqual(_scan("(hello world)"), [.expression([.atom("hello"), .atom("world")])])
    }
    
    func test_scan_unEndedExpression() {
        XCTAssertEqual(_scan("("), [])
    }
    
    func test_scan_unStartedExpression() {
        XCTAssertEqual(_scan(")"), [])
    }
    
    func test_scan_invalidExpression() {
        XCTAssertEqual(_scan("basdf(foo"), [])
    }
    
    func test_scan_expressionsWithNewLine() {
        let expected: [Word] = [.expression([.atom("foo")]), .expression([.atom("bar")])]
        XCTAssertEqual(_scan("(foo)\n(bar)"), expected)
    }
    
    func test_scan_nestedExpression() {
        let expected: [Word] = [.expression([
            .atom("print"),
            .expression([.atom("+"), .number("1"), .number("2"), .number("3")])
        ])]
        XCTAssertEqual(_scan("(print (+ 1 2 3))"), expected)
    }
    
    func test_scan_defn() {
        let expected: [Word] = [.expression([
            .atom("defn"),
            .vector([.atom("arg1")]),
            .expression([.atom("+"), .atom("arg1"), .atom("arg1")])
        ])]
        XCTAssertEqual(_scan("(defn [arg1] (+ arg1 arg1))"), expected)
    }
        
    /// EVAL
    
    func assertExpression(with expressions: [Expression], for lisp: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(eval(lisp), .success([.expression(expressions)]), file: file, line: line)
    }
    
    func test_eval_print_expression() throws {
        let lisp = """
        (print "hi")
        """
        assertExpression(with: [
                            .fncall(FnCall(
                                        name: "print",
                                        args: [.string("hi")]
                            ))], for: lisp)
    }
    
//    func test_eval_foo_expression() throws {
//        let lisp = """
//        (foo "hi")
//        """
//        let result = eval(lisp)
//        XCTAssertEqual(result, .unknown(symbol: "foo"))
//    }
//
//    func test_eval_number_expression() throws {
//        let lisp = """
//        (print 123)
//        """
//        assertExpression(with: [.symbol("print"), .number("123")], for: lisp)
//    }
//
//    func test_eval_add_expression() throws {
//        let lisp = """
//        (+ 1 2 3)
//        """
//        assertExpression(with: [.symbol("+"), .number("1"), .number("2"), .number("3")], for: lisp)
//    }
//
//    func test_eval_nested_expression() throws {
//        let lisp = """
//        (print (+ 1 2 3))
//        """
//        assertExpression(with: [.symbol("print"),
//                                .expression([.symbol("+"), .number("1"), .number("2"), .number("3")])],
//                                for: lisp)
//    }
//
//    func test_eval_lowerThanExpression() {
//        let lisp = """
//        (< 4 5)
//        """
//        assertExpression(with: [.symbol("<"), .number("4"), .number("5")], for: lisp)
//    }
//
//    func test_eval_defn() {
//        let lisp = """
//        (defn [arg1] (+ arg1 arg1))
//        """
//        assertExpression(with: [.symbol("defn"),
//                                .vector([.symbol("arg1")]),
//                                .expression([.symbol("+"),
//                                             .symbol("arg1"),
//                                             .symbol("arg1")])], for: lisp)
//    }

    
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

