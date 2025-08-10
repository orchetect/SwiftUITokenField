//
//  TokenizedString Codable.swift
//  SwiftUITokenField • https://github.com/orchetect/SwiftUITokenField
//  © 2025 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftUITokenField

/// Custom Codable implementation to serialize to/from an array of elements.
///
/// Each array element maps to a sequence element.
extension TokenizedString<String>: @retroactive Codable {
    public enum CodingKeys: String, CodingKey {
        case token
        case string
    }
    
    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        var sequence: [Element] = []
        while let element = try container.decodeIfPresent(Element.self) {
            sequence.append(element)
        }
        self.init(sequence)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        for element in sequence {
            try container.encode(element)
        }
    }
}

/// Custom Codable implementation to serialize a tokenized string element to/from a single-element dictionary.
///
/// The dictionary key determines if the element is a token or a plain-text string.
/// The dictionary value holds either the raw token identifier or the plain text string, respectively.
extension TokenizedString<String>.Element: @retroactive Codable {
    public enum CodingKeys: String, CodingKey {
        case token
        case string
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        let value = try container.decode([String: String].self)
        guard value.count == 1,
              let (keyString, valueString) = value.first
        else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Expected exactly one dictionary entry.")
        }
        guard let key = CodingKeys(rawValue: keyString) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unrecognized key: \(keyString).")
        }
        switch key {
        case .token:
            self = .token(valueString)
        case .string:
            self = .string(valueString)
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case let .token(token):
            try container.encode([CodingKeys.token.rawValue: token])
        case let .string(string):
            try container.encode([CodingKeys.string.rawValue: string])
        }
    }
}
