import XCTest

class Lisp2SwiftTests: XCTestCase {
    
    func _scan(_ text: String) -> [Word] {
        do {
            return try scan(text)
        }
        catch {
            return []        
        }
    }
    
    func eval(_ text: String) -> Result<[Expression], EvalError> {
        do {
            return .success(try evaluate(words: _scan(text)))
        }
        catch {
            return .failure(error as! EvalError)
        }
    }
    
    func l2s(_ text: String) -> Result<String, EvalError> {
        let result = eval(text)
        switch result {
        case .failure(let error):
            return .failure(error)
        case .success(let expressions):
            return .success(transcode(expressions: expressions))
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
        XCTAssertEqual(eval(lisp), .success(expressions), file: file, line: line)
    }
    
    func test_eval_print_expression() throws {
        let lisp = """
        (print "hi")
        """
        assertExpression(with: [
                            .fncall(FnCall(
                                        name: "print",
                                        args: [.string("\"hi\"")]
                            ))], for: lisp)
    }
    
    func test_eval_foo_expression() throws {
        let lisp = """
        (fox "hi")
        """
        let result = eval(lisp)
        XCTAssertEqual(result, .failure(.undeclaredFunction("fox")))
    }

    func test_eval_number_expression() throws {
        let lisp = """
        (print 123)
        """
        assertExpression(with: [
                            .fncall(FnCall(
                                        name: "print",
                                        args: [.number("123")]
                            ))], for: lisp)
    }

    func test_eval_add_expression() throws {
        let lisp = """
        (+ 1 2)
        """
        assertExpression(with: [
                            .fncall(FnCall(
                                        name: "add",
                                        args: [.number("1"), .number("2")]
                            ))], for: lisp)
    }

    func test_eval_nested_expression() throws {
        let lisp = """
        (print (+ 1 2))
        """
        assertExpression(with: [
                            .fncall(FnCall(
                                        name: "print",
                                        args: [.fncall(FnCall(
                                            name: "add",
                                            args: [.number("1"), .number("2")]))
                                                       ]
                                ))], for: lisp)
    }

    func test_eval_defn() {
        let lisp = """
        (defn foo [arg1] (+ arg1 arg1))
        """
        let fncall = Expression.fncall(
            FnCall(name: "add",
                   args: [.symbol("arg1"), .symbol("arg1")])
        )
        let fndecl = Expression.fndecl(
            FnDecl(name: "foo", args: ["arg1"], body: .lisp(expressions: [fncall]))
        )
        assertExpression(with: [fndecl], for: lisp)
    }        
    
    func test_eval_equals() {
        let lisp = """
        (== 1 2)
        """
        let fncall = Expression.fncall(
            FnCall(name: "equal",
                   args: [.number("1"), .number("2")])
        )
        assertExpression(with: [fncall], for: lisp)
    }
    
    func test_eval_if() {
        let lisp = """
        (if (== 1 2) (print "equal") (print "not equal"))
        """
        
        let equals = Expression.fncall(
            FnCall(name: "equal",
                   args: [.number("1"), .number("2")])
        )
        let print1 = Expression.fncall(
            FnCall(name: "print",
                   args: [.string("\"equal\"")])
        )
        let print2 = Expression.fncall(
            FnCall(name: "print",
                   args: [.string("\"not equal\"")])
        )
        let ifelse = Expression.ifelse(
            condition: equals,
            ifExpression: print1,
            elseExpression: print2
        )
        assertExpression(with: [ifelse], for: lisp)
    }
    
    func test_eval_let() {
        let lisp = """
        (let [a 12] (print a))
        """
        let letEx = Expression.letExpression(vector: [.symbol("a"), .number("12")], expressions: [.fncall(FnCall(name: "print", args: [.symbol("a")]))])
        assertExpression(with: [letEx], for: lisp)
    }
    
    /// TRANSCODE
    
    func test_transcode_print_expression() throws {
        let lisp = """
        (print "hi")
        """
        let result = l2s(lisp)
        XCTAssertEqual(result, .success("print(\"hi\")\n"))
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
        XCTAssertEqual(result, .success(expected))
    }
    
    func test_transcode_invalidArgs_expression() throws {
        let lisp = """
        (+ 1 2 3)
        """
        let result = l2s(lisp)
        XCTAssertEqual(result, .failure(.incorrectArguments([.number("1"), .number("2"), .number("3")])))
    }
    
    func test_transcode_add_expression() throws {
        let lisp = """
        (+ 1 2)
        """
        let result = l2s(lisp)
        XCTAssertEqual(result, .success("add(1,2)\n"))
    }
}

