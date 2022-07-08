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
                "compactArray": [
                    0,
                    3,
                    "string"
                ],
                "testDTO": {
                    "key1": "val1",
                    "key2": 39849387498
                },
                "objectArray": [
                    { "message": "asdf1" },
                    { "message": "asdf2" },
                    { "message": "asdf3" },
                    { "wrongMessage": "fdsa" },
                    { "message": "asdf4" }
                ]
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
        struct TestDTO: Decodable, Equatable {
            let key1: String
            let key2: Int
        }

        let json = try! makeJSON()
        XCTAssertEqual(try json.testDTO, TestDTO(key1: "val1", key2: 39849387498))
    }

    func testSingleValue() {
        let json = try! JSONDecoder().decode(JSON.self, from: "1".data(using: .utf8)!)
        XCTAssertEqual(try json.int, 1)
    }

    func testFlatMap() {
        let json = try! JSONDecoder().decode(JSON.self, from: "[1, 2, 3]".data(using: .utf8)!)
        XCTAssertEqual(try json.flatMap { $0 }, [1, 2, 3])
    }

    func testCompactMap() {
        let json = try! makeJSON()
        XCTAssertEqual(try json.objectArray.compactMap { try? $0.message }, ["asdf1", "asdf2", "asdf3", "asdf4"])
    }

    func testShortCompactMap() {
        let json = try! makeJSON()
        XCTAssertEqual(try json.array.compactMap(), [0, 3])
    }

    func testMap() {
        let json = try! makeJSON()
        XCTAssertThrowsError(try json.objectArray.map { try $0.message.string })
    }

    func testSafePropertyWrapper() {
        struct Foo: Decodable {
            @JSONSafe
            var foo: Int?
        }

        do {
            let json = try makeJSON()
            let foo: Foo = try json.as(Foo.self)
            XCTAssertEqual(foo.foo, nil)
        } catch {
            XCTFail("Error: \(error).\nThere should be no exception in parsing")
        }
    }

    func testCompactMapPropertyWrapper() {
        struct Foo: Decodable {
            @JSONCompactMap
            var compactArray: [String]
        }

        do {
            let json = try makeJSON()
            let foo: Foo = try json.as(Foo.self)
            XCTAssertEqual(foo.compactArray, ["string"])
        } catch {
            XCTFail("Error: \(error).\nThere should be no exception in parsing")
        }
    }

    func testSafeCompactMapPropertyWrapper() {
        struct Foo: Decodable {
            @JSONSafeCompactMap
            var testDTO: [String]?
        }

        do {
            let json = try makeJSON()
            let foo: Foo = try json.as(Foo.self)
            XCTAssertEqual(foo.testDTO, nil)
        } catch {
            XCTFail("Error: \(error).\nThere should be no exception in parsing")
        }
    }

    static var allTests = [
        ("testStringKey", testStringKey),
        ("testIntKey", testIntKey),
        ("testNestedKey", testNestedKey),
        ("testArrayIndex", testArrayIndex),
        ("testDecodable", testDecodable),
        ("testSingleValue", testSingleValue),
        ("testFlatMap", testFlatMap),
        ("testCompactMap", testCompactMap),
        ("testShortCompactMap", testShortCompactMap),
        ("testMap", testMap),
        ("testSafePropertyWrapper", testSafePropertyWrapper),
        ("testCompactMapPropertyWrapper", testCompactMapPropertyWrapper),
        ("testSafeCompactMapPropertyWrapper", testSafeCompactMapPropertyWrapper),
    ]
}
