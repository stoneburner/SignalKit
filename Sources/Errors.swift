//
//  Errors.swift
//  SignalKit-iOS
//
//  Created by Alexander Kasimir on 09.07.19.
//  Copyright © 2019 SignalKit. All rights reserved.
//

import Foundation

enum JSONDecodingError: Error, Equatable {
    case missingValue
    case unknownEnumName(String)
    case unknownKey(String)
    case invalidValue(String)
}
