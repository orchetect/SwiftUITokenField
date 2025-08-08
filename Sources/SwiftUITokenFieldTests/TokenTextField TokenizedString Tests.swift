//
//  TokenTextField TokenizedString Tests.swift
//  SwiftUITokenField • https://github.com/orchetect/SwiftUITokenField
//  © 2025 Steffan Andrews • Licensed under MIT License
//

import SwiftUI
import SwiftUITokenField
import Testing

@Suite struct TokenTextField_TokenizedString_Tests {
    enum TestToken: String {
        case one
        case two = "t-wo" // test a token containing a hyphen
        case three = "th ree" // test a token containing a whitespace
        
        var value: Int {
            switch self {
            case .one: 1
            case .two: 2
            case .three: 3
            }
        }
    }
    
    typealias TokenizedString = TokenTextField<TestToken>.TokenizedString
    
    @Test func initDecodeTokenizedString() throws {
        #expect(try TokenizedString(from: "").sequence == [])
        #expect(try TokenizedString(from: " ").sequence == [.string(" ")])
        #expect(try TokenizedString(from: "  ").sequence == [.string("  ")])
        
        #expect(try TokenizedString(from: "a").sequence == [.string("a")])
        #expect(try TokenizedString(from: "ab").sequence == [.string("ab")])
        #expect(
            try TokenizedString(from: "A very long string without any tokens within it.").sequence
                == [.string("A very long string without any tokens within it.")]
        )
        
        #expect(
            try TokenizedString(from: "A very long string with %[one], %[t-wo] and %[th ree].").sequence
                == [
                    .string("A very long string with "),
                    .token(.one),
                    .string(", "),
                    .token(.two),
                    .string(" and "),
                    .token(.three),
                    .string(".")
                ]
        )
        
        #expect(try TokenizedString(from: "%[one]").sequence == [.token(.one)])
        #expect(try TokenizedString(from: "%[t-wo]").sequence == [.token(.two)])
        #expect(try TokenizedString(from: "%[th ree]").sequence == [.token(.three)])
        
        // allow token IDs to be used in plain-text strings, and don't interpret them as a token
        #expect(try TokenizedString(from: "one").sequence == [.string("one")])
        #expect(try TokenizedString(from: "one %[one]").sequence == [.string("one "), .token(.one)])
        #expect(try TokenizedString(from: " %[one]").sequence == [.string(" "), .token(.one)])
        #expect(try TokenizedString(from: "%[one] ").sequence == [.token(.one), .string(" ")])
        #expect(try TokenizedString(from: " %[one] ").sequence == [.string(" "), .token(.one), .string(" ")])
        #expect(try TokenizedString(from: "%[one]%[t-wo]").sequence == [.token(.one), .token(.two)])
        
        // token IDs are case-sensitive
        #expect(throws: (any Error).self) { try TokenizedString(from: "%[ONE]").sequence }
        
        // token IDs must match exactly, not allowing whitespace before or after
        #expect(throws: (any Error).self) { try TokenizedString(from: "%[ one]").sequence }
        #expect(throws: (any Error).self) { try TokenizedString(from: "%[one ]").sequence }
        #expect(throws: (any Error).self) { try TokenizedString(from: "%[ one ]").sequence }
        
        // edge cases
        #expect(throws: (any Error).self) { try TokenizedString(from: "%[]").sequence }
        #expect(throws: (any Error).self) { try TokenizedString(from: "%[ ]").sequence }
        #expect(throws: (any Error).self) { try TokenizedString(from: "%[%[one]]").sequence }
        #expect(try TokenizedString(from: "[%[one]]").sequence == [.string("["), .token(.one), .string("]")])
        #expect(try TokenizedString(from: "[one]").sequence == [.string("[one]")])
    }
    
    @Test func tokenizedStringEncode() throws {
        #expect(TokenizedString(sequence: []).tokenizedString() == "")
        #expect(TokenizedString(sequence: [.string("")]).tokenizedString() == "")
        #expect(TokenizedString(sequence: [.string(" ")]).tokenizedString() == " ")
        #expect(TokenizedString(sequence: [.string("  ")]).tokenizedString() == "  ")
        #expect(TokenizedString(sequence: [.string(" "), .string(" ")]).tokenizedString() == "  ")
        #expect(TokenizedString(sequence: [.string("a")]).tokenizedString() == "a")
        #expect(TokenizedString(sequence: [.string("ab")]).tokenizedString() == "ab")
        #expect(TokenizedString(sequence: [.string("a"), .string("b")]).tokenizedString() == "ab")
        
        #expect(TokenizedString(sequence: [.token(.one)]).tokenizedString() == "%[one]")
        #expect(TokenizedString(sequence: [.token(.one), .token(.two)]).tokenizedString() == "%[one]%[t-wo]")
        #expect(TokenizedString(sequence: [.token(.one), .token(.two), .token(.three)]).tokenizedString() == "%[one]%[t-wo]%[th ree]")
        
        #expect(TokenizedString(sequence: [
            .string("A very long string with "),
            .token(.one),
            .string(", "),
            .token(.two),
            .string(" and "),
            .token(.three),
            .string(".")
        ]).tokenizedString() == "A very long string with %[one], %[t-wo] and %[th ree].")
    }
    
    @Test func tokenizedStringStringSubstitution() throws {
        #expect(TokenizedString(sequence: []).string(substitution: { "\($0.value)" }) == "")
        #expect(TokenizedString(sequence: [.string("")]).string(substitution: { "\($0.value)" }) == "")
        #expect(TokenizedString(sequence: [.string(" ")]).string(substitution: { "\($0.value)" }) == " ")
        #expect(TokenizedString(sequence: [.string("  ")]).string(substitution: { "\($0.value)" }) == "  ")
        #expect(TokenizedString(sequence: [.string(" "), .string(" ")]).string(substitution: { "\($0.value)" }) == "  ")
        #expect(TokenizedString(sequence: [.string("a")]).string(substitution: { "\($0.value)" }) == "a")
        #expect(TokenizedString(sequence: [.string("ab")]).string(substitution: { "\($0.value)" }) == "ab")
        #expect(TokenizedString(sequence: [.string("a"), .string("b")]).string(substitution: { "\($0.value)" }) == "ab")
        
        #expect(TokenizedString(sequence: [.token(.one)]).string(substitution: { "\($0.value)" }) == "1")
        #expect(TokenizedString(sequence: [.token(.one), .token(.two)]).string(substitution: { "\($0.value)" }) == "12")
        #expect(TokenizedString(sequence: [.token(.one), .token(.two), .token(.three)]).string(substitution: { "\($0.value)" }) == "123")
        
        #expect(TokenizedString(sequence: [
            .string("A very long string with "),
            .token(.one),
            .string(", "),
            .token(.two),
            .string(" and "),
            .token(.three),
            .string(".")
        ]).string(substitution: { "\($0.value)" })
            == "A very long string with 1, 2 and 3."
        )
    }
    
    @Test func tokenizedStringStringSubstitution_WithSeparator() throws {
        #expect(TokenizedString(sequence: []).string(separator: "-", substitution: { "\($0.value)" }) == "")
        #expect(TokenizedString(sequence: [.string("")]).string(separator: "-", substitution: { "\($0.value)" }) == "")
        #expect(TokenizedString(sequence: [.string(""), .string("")]).string(separator: "-", substitution: { "\($0.value)" }) == "-")
        #expect(TokenizedString(sequence: [.string(" "), .string("")]).string(separator: "-", substitution: { "\($0.value)" }) == " -")
        #expect(TokenizedString(sequence: [.string(""), .string(" ")]).string(separator: "-", substitution: { "\($0.value)" }) == "- ")
        #expect(TokenizedString(sequence: [.string(" "), .string(" ")]).string(separator: "-", substitution: { "\($0.value)" }) == " - ")
        #expect(TokenizedString(sequence: [.string("a")]).string(separator: "-", substitution: { "\($0.value)" }) == "a")
        #expect(TokenizedString(sequence: [.string("ab")]).string(separator: "-", substitution: { "\($0.value)" }) == "ab")
        #expect(TokenizedString(sequence: [.string("a"), .string("b")]).string(separator: "-", substitution: { "\($0.value)" }) == "a-b")
        
        #expect(TokenizedString(sequence: [
            .string("A very long string with "),
            .token(.one),
            .string(", "),
            .token(.two),
            .string(" and "),
            .token(.three),
            .string(".")
        ]).string(separator: "-", substitution: { "\($0.value)" })
                == "A very long string with -1-, -2- and -3-."
        )
    }
}
