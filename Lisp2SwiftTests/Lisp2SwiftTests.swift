import XCTest
@testable import Lisp2Swift

class Lisp2SwiftTests: XCTestCase {

    let parser = Parser()
    
    func scan(_ text: String) -> ScanResult {
        return parser.scan(text: text)
    }
    
    func test_scan_emptyText() {
        XCTAssertEqual(scan(""), .regions([]))
    }
    
    func test_scan_invalidText() {
        XCTAssertEqual(scan("bla"), .incomplete)
    }
    
    func test_scan_unended_expression() {
        XCTAssertEqual(scan("(bla"), .incomplete)
    }
    
    func test_scan_expression() {
        XCTAssertEqual(scan("(bla)"), .regions(["bla"]))
    }
    
    func test_scan_twoExpressions() {
        XCTAssertEqual(scan("(bla)(bla)"), .regions(["bla", "bla"]))
    }
    
    func test_parse_print_expression() throws {
        let lisp = """
        (print "hi")
        """
        let expressions = parser.parse(lispString: lisp)
        XCTAssertEqual(expressions.count, 1)
        let first = try XCTUnwrap(expressions.first)
        XCTAssertEqual(first.symbol, "print")
        XCTAssertEqual(first.parameters, ["\"hi\""])
    }
}
