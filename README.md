# KrwJSON

Simplified manual json decoding using swift `Decoder` like in javaScript.

Swift 5.5 is required as it supports throwable subscripts and property getters 

Example:
```
let jsonText = """
{
    "plain": "value",
    "dict": {
        "strValue": "string",
        "intValue": 111,
        "string value": "another value"
    },
    "stringArray": [
        "a", "b", "c"
    ],
    "varArray": [
        "str",
        0,
        {
            "obj": "deepNestedValue"
        }
    ]
}
"""

struct SampleDTO: JSONDecodable {
    let plain: String
    let dictStrValue: String
    let dictIntValue: Int
    let dictStringValue: String
    let stringArray: [String]
    let deepNestedValue: String
    let optValue: String?
    
    init(json: JSON) throws {
        plain = try json.plain
        dictStrValue = try json.dict.strValue
        dictIntValue = try json.dict.intValue
        dictStringValue = try json.dict["string value"]
        stringArray = try json.stringArray
        deepNestedValue = try json.varArray[2].obj
        optValue = try? json.optValue
    }
}
```
