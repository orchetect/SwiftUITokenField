//
//  Tokens.swift
//  SwiftUITokenField • https://github.com/orchetect/SwiftUITokenField
//  © 2025 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftUITokenField

extension TokenTextField<Token>.TokenizedString: @retroactive Codable {
    public enum CodingKeys: String, CodingKey {
        case token
        case string
    }
    
    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        var sequence: [Element] = []
        while let value = try container.decodeIfPresent([String: String].self) {
            guard value.count == 1, let (keyString, valueString) = value.first else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Expected exactly one dictionary entry.")
            }
            guard let key = CodingKeys(rawValue: keyString) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unrecognized key: \(keyString).")
            }
            switch key {
            case .token:
                guard let token = Token(rawValue: valueString) else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unrecognized token: \(valueString).")
                }
                sequence.append(.token(token))
            case .string:
                sequence.append(.string(valueString))
            }
        }
        self.init(sequence: sequence)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        for element in sequence {
            switch element {
            case let .token(token):
                try container.encode([CodingKeys.token.rawValue: token.rawValue])
            case let .string(string):
                try container.encode([CodingKeys.string.rawValue: string])
            }
        }
    }
}
