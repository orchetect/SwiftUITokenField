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
    
    typealias TS = TokenizedString<TestToken>
    
    @Test func initDecodeTS() throws {
        #expect(try TS(from: "").sequence == [])
        #expect(try TS(from: " ").sequence == [.string(" ")])
        #expect(try TS(from: "  ").sequence == [.string("  ")])
        
        #expect(try TS(from: "a").sequence == [.string("a")])
        #expect(try TS(from: "ab").sequence == [.string("ab")])
        #expect(
            try TS(from: "A very long string without any tokens within it.").sequence
                == [.string("A very long string without any tokens within it.")]
        )
        
        #expect(
            try TS(from: "A very long string with %[one], %[t-wo] and %[th ree].").sequence
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
        
        #expect(try TS(from: "%[one]").sequence == [.token(.one)])
        #expect(try TS(from: "%[t-wo]").sequence == [.token(.two)])
        #expect(try TS(from: "%[th ree]").sequence == [.token(.three)])
        
        // allow token IDs to be used in plain-text strings, and don't interpret them as a token
        #expect(try TS(from: "one").sequence == [.string("one")])
        #expect(try TS(from: "one %[one]").sequence == [.string("one "), .token(.one)])
        #expect(try TS(from: " %[one]").sequence == [.string(" "), .token(.one)])
        #expect(try TS(from: "%[one] ").sequence == [.token(.one), .string(" ")])
        #expect(try TS(from: " %[one] ").sequence == [.string(" "), .token(.one), .string(" ")])
        #expect(try TS(from: "%[one]%[t-wo]").sequence == [.token(.one), .token(.two)])
        
        // token IDs are case-sensitive
        #expect(throws: (any Error).self) { try TS(from: "%[ONE]").sequence }
        
        // token IDs must match exactly, not allowing whitespace before or after
        #expect(throws: (any Error).self) { try TS(from: "%[ one]").sequence }
        #expect(throws: (any Error).self) { try TS(from: "%[one ]").sequence }
        #expect(throws: (any Error).self) { try TS(from: "%[ one ]").sequence }
        
        // edge cases
        #expect(throws: (any Error).self) { try TS(from: "%[]").sequence }
        #expect(throws: (any Error).self) { try TS(from: "%[ ]").sequence }
        #expect(throws: (any Error).self) { try TS(from: "%[%[one]]").sequence }
        #expect(try TS(from: "[%[one]]").sequence == [.string("["), .token(.one), .string("]")])
        #expect(try TS(from: "[one]").sequence == [.string("[one]")])
    }
    
    @Test func tokenizedStringEncode() throws {
        #expect(TS(sequence: []).tokenizedString() == "")
        #expect(TS(sequence: [.string("")]).tokenizedString() == "")
        #expect(TS(sequence: [.string(" ")]).tokenizedString() == " ")
        #expect(TS(sequence: [.string("  ")]).tokenizedString() == "  ")
        #expect(TS(sequence: [.string(" "), .string(" ")]).tokenizedString() == "  ")
        #expect(TS(sequence: [.string("a")]).tokenizedString() == "a")
        #expect(TS(sequence: [.string("ab")]).tokenizedString() == "ab")
        #expect(TS(sequence: [.string("a"), .string("b")]).tokenizedString() == "ab")
        
        #expect(TS(sequence: [.token(.one)]).tokenizedString() == "%[one]")
        #expect(TS(sequence: [.token(.one), .token(.two)]).tokenizedString() == "%[one]%[t-wo]")
        #expect(TS(sequence: [.token(.one), .token(.two), .token(.three)]).tokenizedString() == "%[one]%[t-wo]%[th ree]")
        
        #expect(TS(sequence: [
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
        #expect(TS(sequence: []).string(substitution: { "\($0.value)" }) == "")
        #expect(TS(sequence: [.string("")]).string(substitution: { "\($0.value)" }) == "")
        #expect(TS(sequence: [.string(" ")]).string(substitution: { "\($0.value)" }) == " ")
        #expect(TS(sequence: [.string("  ")]).string(substitution: { "\($0.value)" }) == "  ")
        #expect(TS(sequence: [.string(" "), .string(" ")]).string(substitution: { "\($0.value)" }) == "  ")
        #expect(TS(sequence: [.string("a")]).string(substitution: { "\($0.value)" }) == "a")
        #expect(TS(sequence: [.string("ab")]).string(substitution: { "\($0.value)" }) == "ab")
        #expect(TS(sequence: [.string("a"), .string("b")]).string(substitution: { "\($0.value)" }) == "ab")
        
        #expect(TS(sequence: [.token(.one)]).string(substitution: { "\($0.value)" }) == "1")
        #expect(TS(sequence: [.token(.one), .token(.two)]).string(substitution: { "\($0.value)" }) == "12")
        #expect(TS(sequence: [.token(.one), .token(.two), .token(.three)]).string(substitution: { "\($0.value)" }) == "123")
        
        #expect(TS(sequence: [
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
        #expect(TS(sequence: []).string(separator: "-", substitution: { "\($0.value)" }) == "")
        #expect(TS(sequence: [.string("")]).string(separator: "-", substitution: { "\($0.value)" }) == "")
        #expect(TS(sequence: [.string(""), .string("")]).string(separator: "-", substitution: { "\($0.value)" }) == "-")
        #expect(TS(sequence: [.string(" "), .string("")]).string(separator: "-", substitution: { "\($0.value)" }) == " -")
        #expect(TS(sequence: [.string(""), .string(" ")]).string(separator: "-", substitution: { "\($0.value)" }) == "- ")
        #expect(TS(sequence: [.string(" "), .string(" ")]).string(separator: "-", substitution: { "\($0.value)" }) == " - ")
        #expect(TS(sequence: [.string("a")]).string(separator: "-", substitution: { "\($0.value)" }) == "a")
        #expect(TS(sequence: [.string("ab")]).string(separator: "-", substitution: { "\($0.value)" }) == "ab")
        #expect(TS(sequence: [.string("a"), .string("b")]).string(separator: "-", substitution: { "\($0.value)" }) == "a-b")
        
        #expect(TS(sequence: [
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
