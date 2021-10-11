import XCTest
@testable import KrwJSON

final class KrwJSONTests: XCTestCase {

    func makeJSON() throws -> JSON {
        let jsonString = """
            {
                "foo": "string",
                "bar": 8,
                "nested": {
                    "key": "nested.value"
                },
                "array": [
                    0,
                    3
                ],
                "testDTO": {
                    "key1": "val1",
                    "key2": 39849387498
                }
            }
            """
        return try JSONDecoder()
            .decode(JSON.self, from: jsonString.data(using: .utf8)!)
    }

    func testStringKey() {
        let json = try! makeJSON()
        XCTAssertEqual(try json.foo, "string")
    }

    func testIntKey() {
        let json = try! makeJSON()
        XCTAssertEqual(try json.bar, 8)
    }

    func testNestedKey() {
        let json = try! makeJSON()
        XCTAssertEqual(try json.nested.key, "nested.value")
    }

    func testArrayIndex() {
        let json = try! makeJSON()
        XCTAssertEqual(try json.array[0], 0)
        XCTAssertEqual(try json.array[1], 3)
    }

    func testDecodable() {
        let json = try! makeJSON()
        XCTAssertEqual(try json.testDTO, TestDTO(key1: "val1", key2: 39849387498))
    }

    static var allTests = [
        ("testStringKey", testStringKey),
        ("testIntKey", testIntKey),
        ("testNestedKey", testNestedKey),
        ("testArrayIndex", testArrayIndex),
        ("testDecodable", testDecodable),
    ]
}

struct TestDTO: Decodable, Equatable {
    let key1: String
    let key2: Int
}
