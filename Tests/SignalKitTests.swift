//
//  SignalKitTests.swift
//  SignalKitTests
//
//  Created by Alexander Kasimir on 09.07.2019.
//  Copyright © 2019 SignalKit. All rights reserved.
//

@testable import SignalKit
import XCTest

class SignalKitTests: XCTestCase {

    func testSignalTypeCoding() throws {

        let signalTypes1 = [
            SignalType.gnd,
            SignalType.special(name: "foo"),
            SignalType.vccNeg(volt: 3.3),
            SignalType.vccPos(volt: 5.0),
            SignalType.digital(direction: .input),
            SignalType.digital(direction: .output),
            SignalType.digital(direction: .inOut),
            SignalType.analog,
            SignalType.undefined,
        ]

        let encoder = JSONEncoder()

        let data = try encoder.encode(signalTypes1)
        guard let jsonString = String(data: data, encoding: .utf8) else { XCTFail(); return }
        print("JSON: \(jsonString)")

        let signalTypes = try JSONDecoder().decode([SignalType].self, from: data)

        print("\(signalTypes)")

        XCTAssertEqual(signalTypes1, signalTypes)
    }

    func testInvalidSignalDecoding() {

        let testData = [
            (json: "[\"vccPos:123:123\"]", expectedError: JSONDecodingError.invalidValue("vccPos:123:123")),
            (json: "[\"foo\"]", expectedError: JSONDecodingError.unknownEnumName("foo")),
            (json: "[\"vccNeg\"]", expectedError: JSONDecodingError.missingValue),
            (json: "[\"vccNeg:abc\"]", expectedError: JSONDecodingError.invalidValue("abc")),
            (json: "[\"vccPos\"]", expectedError: JSONDecodingError.missingValue),
            (json: "[\"vccPos:abc\"]", expectedError: JSONDecodingError.invalidValue("abc")),
            (json: "[\"special\"]", expectedError: JSONDecodingError.missingValue),
            (json: "[\"digital:fff\"]", expectedError: JSONDecodingError.invalidValue("fff")),
            (json: "[\"digital\"]", expectedError: JSONDecodingError.missingValue),
        ]

        for (json, expectedError) in testData {
            let decoder = JSONDecoder()

            XCTAssertThrowsError(try decoder.decode([SignalType].self, from: json.data(using: .utf8)!)) { error in
                print("error:\(error)")
                guard let jsonError = error as? JSONDecodingError else { XCTFail("wrong error is thrown: \(error), expected \(expectedError)"); return }
                XCTAssertEqual(jsonError, expectedError)
            }
        }
    }

    func testSignalConnectionTypes() {

        let signalConnections = [
            (true, SignalConnection(a: .gnd, b: .gnd)),
            (false, SignalConnection(a: .gnd, b: .vccNeg(volt: 12))),
            (true, SignalConnection(a: .vccNeg(volt: 5), b: .vccNeg(volt: 5))),
            (false, SignalConnection(a: .digital(direction: .input), b: .digital(direction: .input))),
            (true, SignalConnection(a: .digital(direction: .output), b: .digital(direction: .input))),
            (true, SignalConnection(a: .digital(direction: .output), b: .digital(direction: .input))),
            (true, SignalConnection(a: .digital(direction: .inOut), b: .digital(direction: .input))),
            (true, SignalConnection(a: .digital(direction: .inOut), b: .digital(direction: .output))),
            (true, SignalConnection(a: .digital(direction: .inOut), b: .digital(direction: .inOut))),
            (false, SignalConnection(a: .special(name: "foo"), b: .special(name: "bar"))),
            (true, SignalConnection(a: .special(name: "foo"), b: .special(name: "foo"))),
            (true, SignalConnection(a: .undefined, b: .gnd)),
            (true, SignalConnection(a: .vccPos(volt: 3.3), b: .vccPos(volt: 3.3))),
            (false, SignalConnection(a: .vccPos(volt: 3.3), b: .vccPos(volt: 5))),
            (true, SignalConnection(a: .analog, b: .analog))
        ]

        for (expected, connection) in signalConnections {
            XCTAssertEqual(expected, connection.isValid, "\(connection).valid is expected to be \(expected)")
        }

    }
    
}
