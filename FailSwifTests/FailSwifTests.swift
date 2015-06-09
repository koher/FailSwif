import XCTest
import FailSwif

class FailSwifTests: XCTestCase {
    func testBasic() {
        XCTAssert(toInt(nil).error == .Nil)
        XCTAssert(toInt("Swift").error == .IllegalFormat("Swift"))
        XCTAssert(toInt("42").value == 42)
    }
    
    func testMap() {
        XCTAssert(toInt(nil).map { $0 * $0 } == .Failure(.Nil))
        XCTAssert(toInt("Swift").map { $0 * $0 } == .Failure(.IllegalFormat("Swift")))
        XCTAssert(toInt("42").map { $0 * $0 } == .Success(42 * 42))
    }
    
    func testFlatMap() {
        XCTAssert(toInt(nil).flatMap { a in toInt(nil).flatMap { b in .Success(a + b) } } == .Failure(.Nil))
        XCTAssert(toInt(nil).flatMap { a in toInt("A").flatMap { b in .Success(a + b) } } == .Failure(.Nil))
        XCTAssert(toInt("2").flatMap { a in toInt("A").flatMap { b in .Success(a + b) } } == .Failure(.IllegalFormat("A")))
        XCTAssert(toInt("2").flatMap { a in toInt("3").flatMap { b in .Success(a + b) } } == .Success(5))
    }
    
    func testEquals() {
        XCTAssertTrue(toInt(nil) == toInt(nil))
        XCTAssertFalse(toInt(nil) == toInt("Swift"))
        XCTAssertFalse(toInt(nil) == toInt("42"))

        XCTAssertFalse(toInt("Swift") == toInt(nil))
        XCTAssertTrue(toInt("Swift") == toInt("Swift"))
        XCTAssertFalse(toInt("Swift") == toInt("42"))
        XCTAssertFalse(toInt("Swift") == toInt("Swift 2.0"))

        XCTAssertFalse(toInt("42") == toInt(nil))
        XCTAssertFalse(toInt("42") == toInt("Swift"))
        XCTAssertTrue(toInt("42") == toInt("42"))
        XCTAssertFalse(toInt("42") == toInt("0"))
    }
    
    func testCoalescing() {
        XCTAssertEqual(toInt(nil) ?? 0, 0)
        XCTAssertEqual(toInt("Swift") ?? 0, 0)
        XCTAssertEqual(toInt("42") ?? 0, 42)
    }
    
    func testDescription() {
        XCTAssertEqual(toInt(nil).description, "Failable(ParseError)")
        XCTAssertEqual(toInt("Swift").description, "Failable(ParseError(Swift))")
        XCTAssertEqual(toInt("42").description, "Failable(42)")
    }
    
    func testExample() {
        struct UILabel {
            var text: String?
        }
        let label = UILabel(text: "42")

        let a: Failable<Int, ParseError> = toInt(label.text)
        
        if let value = a.value {
            print(value)
        }
        
        switch a {
        case .Success(let value):
            print(value)
        case .Failure(.Nil):
            print("The text is nil.")
        case .Failure(.IllegalFormat(let string)):
            print("Illegal format: \(string)")
        }
        
        let value: Int? = a.value
        let error: ParseError? = a.error
        
        let b = a.map { $0 * $0 }
        let c = a.flatMap { a0 in b.flatMap { b0 in .Success(a0 + b0) } }
        let d: Int = a ?? 0
        let e = a.flatMap { .Success($0.successor()) }
        
        func toIntThrowable(string: String?) throws -> Int {
            guard let s = string else { throw ParseError.Nil }
            guard let int = Int(s) else { throw ParseError.IllegalFormat(s) }
            return int
        }
        
        func toInt2(string: String?) -> Failable<Int, ParseError> {
            do {
                return .Success(try toIntThrowable(string))
            } catch let error as ParseError {
                return .Failure(error)
            } catch { // It cannot be ommited with the current version. The error says "the enclosing catch is not exhaustive".
                fatalError("Never reaches here.")
            }
        }
        
        print(a)
        print(value)
        print(error)
        print(b)
        print(c)
        print(d)
        print(e)
    }
}

func toInt(string: String?) -> Failable<Int, ParseError> {
    guard let s = string else { return .Failure(.Nil) }
    guard let int = Int(s) else { return .Failure(.IllegalFormat(s)) }
    return .Success(int)
}

enum ParseError: ErrorType, Equatable {
    case Nil
    case IllegalFormat(String)
}

extension ParseError: CustomStringConvertible {
    var description: String {
        switch self {
        case .Nil:
            return "ParseError"
        case .IllegalFormat(let string):
            return "ParseError(\(string))"
        }
    }
}

func ==(lhs: ParseError, rhs: ParseError) -> Bool {
    switch (lhs, rhs) {
    case (.Nil, .Nil):
        return true
    case (.IllegalFormat(let string1), .IllegalFormat(let string2)):
        return string1 == string2
    default:
        return false
    }
}
