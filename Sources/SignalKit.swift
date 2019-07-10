//
//  Signals.swift
//  PartDesigner
//
//  Created by Alexander Kasimir on 08.07.19.
//  Copyright © 2019 Alexander Kasimir. All rights reserved.
//

import Foundation

/// Describes the logical direction of an signal
///
/// - input: accepts input
/// - output: sends output
/// - inOut: bidirectional signal
enum SignalDirection: String, Codable, Hashable, Equatable {
    case input
    case output
    case inOut
}

struct SignalConnection {
    let a: SignalType
    let b: SignalType

    var isValid: Bool {
        return a.isValidConnection(to: b)
    }
}

/// Specifies the type of an signal
///
/// - vccPos: positive Voltage signal
/// - vccNeg: negative Voltage signal
/// - gnd: connection to ground
/// - digital: digital signal
/// - analog: analog signal
/// - special: named special purpose signal
/// - undefined: undefined signal
enum SignalType: Codable, Hashable, Equatable {
    case vccPos(volt:Double)
    case vccNeg(volt:Double)
    case gnd
    case digital(direction: SignalDirection)
    case analog
    case special(name: String)
    case undefined

    private var stringValueName: String {
        switch self {
        case .gnd: return "gnd"
        case .vccPos: return "vccPos"
        case .vccNeg: return "vccNeg"
        case .digital: return "digital"
        case .analog: return "analog"
        case .special: return "special"
        case .undefined: return "undefined"
        }
    }

    private var stringValue: String? {
        switch self {
        case .vccPos(let volt): return "\(volt)"
        case .vccNeg(let volt): return "\(volt)"
        case .gnd: return nil
        case .digital(let direction): return "\(direction.rawValue)"
        case .analog: return nil
        case .special(let name): return "\(name)"
        case .undefined: return nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let stringValue = self.stringValue {
            try container.encode("\(self.stringValueName):\(stringValue)")
        } else {
            try container.encode("\(self.stringValueName)")
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)

        let propertyName: String
        let propertyValue: String?
        if stringValue.contains(":") {
            let parts = stringValue.split(separator: ":")
            guard parts.count == 2 else { throw JSONDecodingError.invalidValue(stringValue) }
            propertyName = String(parts[0])
            propertyValue = String(parts[1])
        } else {
            propertyName = stringValue
            propertyValue = nil
        }

        if propertyName == "gnd" { self = .gnd } else
        if propertyName == "vccPos" {
            guard let stringValue = propertyValue else { throw JSONDecodingError.missingValue }
            guard let value = Double(stringValue) else { throw JSONDecodingError.invalidValue(stringValue) }
            self = .vccPos(volt: value)
        } else
        if propertyName == "vccNeg" {
            guard let stringValue = propertyValue else { throw JSONDecodingError.missingValue }
            guard let value = Double(stringValue) else { throw JSONDecodingError.invalidValue(stringValue) }
            self = .vccNeg(volt: value)
        } else
        if propertyName == "digital" {
            guard let stringValue = propertyValue else { throw JSONDecodingError.missingValue }
            guard let value = SignalDirection(rawValue: stringValue) else { throw JSONDecodingError.invalidValue(stringValue) }
            self = .digital(direction: value)
        } else
        if propertyName == "analog" { self = .analog } else
        if propertyName == "special" {
            guard let stringValue = propertyValue else { throw JSONDecodingError.missingValue }
            self = .special(name: stringValue)
        } else
        if propertyName == "undefined" { self = .undefined } else {
            throw JSONDecodingError.unknownEnumName(propertyName)
        }
    }
}

extension SignalType {

    /// Checks if a signal connection is valid
    ///
    /// - Parameter type: other connection
    /// - Returns: true if the connection is ok
    func isValidConnection(to type: SignalType) -> Bool {
        switch self {
        case .vccPos(let volt): return type == .vccPos(volt: volt)
        case .vccNeg(let volt): return type == .vccNeg(volt: volt)
        case .gnd: return type == .gnd
        case .digital(let direction):
            switch direction {
            case .input: return type == SignalType.digital(direction: .output)
            case .output: return type == SignalType.digital(direction: .input)
            case .inOut: return type == SignalType.digital(direction: .inOut) || type == SignalType.digital(direction: .input) || type == SignalType.digital(direction: .output)
            }
        case .analog: return type == .analog
        case .special(let name): return type == .special(name: name)
        case .undefined: return true
        }
    }
}
