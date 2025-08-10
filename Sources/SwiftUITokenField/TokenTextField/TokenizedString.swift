//
//  TokenizedString.swift
//  SwiftUITokenField • https://github.com/orchetect/SwiftUITokenField
//  © 2025 Steffan Andrews • Licensed under MIT License
//

/// Tokenized string model.
public struct TokenizedString<Token> {
    public var sequence: [Element]
    
    public init(_ sequence: [Element] = []) {
        self.sequence = sequence
    }
}

extension TokenizedString: Equatable where Token: Equatable { }

extension TokenizedString: Hashable where Token: Hashable { }

extension TokenizedString: Sendable where Token: Sendable { }

extension TokenizedString: Identifiable where Token: Hashable {
    public var id: Self { self }
}

extension TokenizedString {
    public func string(
        separator: String = "",
        substitution: (_ token: Token) -> String
    ) -> String {
        sequence
            .map {
                switch $0 {
                case let .token(token): substitution(token)
                case let .string(string): string
                }
            }
            .joined(separator: separator)
    }
}

// MARK: - Tokenized String

extension TokenizedString {
    /// Initializes by decoding a tokenized string.
    public init(
        from tokenized: String,
        tokenPrefix: String = "%[",
        tokenSuffix: String = "]",
        decode: (_ string: String) -> Token?
    ) throws {
        assert(tokenPrefix != "")
        assert(tokenSuffix != "")
        
        var sequence: [Element] = []
        
        var index = tokenized.startIndex
        
        while index < tokenized.endIndex {
            if let tokenStart = tokenized
                .range(of: tokenPrefix, options: [], range: index ..< tokenized.endIndex, locale: nil)
            {
                guard let tokenEnd = tokenized
                    .range(
                        of: tokenSuffix,
                        options: [],
                        range: tokenStart.upperBound ..< tokenized.endIndex,
                        locale: nil
                    )
                else {
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(
                            codingPath: [],
                            debugDescription: "Encountered token prefix without a corresponding suffix."
                        )
                    )
                }
                
                let tokenString = String(tokenized[tokenStart.upperBound ..< tokenEnd.lowerBound])
                
                guard let token = decode(tokenString) else {
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(codingPath: [], debugDescription: "Unrecognized token: \(tokenString).")
                    )
                }
                
                // add intermediate string if necessary
                if tokenStart.lowerBound > index {
                    let string = String(tokenized[index ..< tokenStart.lowerBound])
                    sequence.append(.string(string))
                }
                
                sequence.append(.token(token))
                index = tokenEnd.upperBound
            } else {
                let string = String(tokenized[index ..< tokenized.endIndex])
                sequence.append(.string(string))
                index = tokenized.endIndex
            }
        }
        
        self.init(sequence)
    }
    
    /// Returns the sequence as a tokenized string.
    public func tokenizedString(
        tokenPrefix: String = "%[",
        tokenSuffix: String = "]",
        encode: (_ token: Token) -> String
    ) -> String {
        assert(tokenPrefix != "")
        assert(tokenSuffix != "")
        
        return sequence
            .map {
                switch $0 {
                case let .token(token): tokenPrefix + encode(token) + tokenSuffix
                case let .string(string): string
                }
            }
            .joined()
    }
}

extension TokenizedString where Token == String {
    /// Initializes by decoding a tokenized string.
    public init(
        from tokenized: String,
        tokenPrefix: String = "%[",
        tokenSuffix: String = "]"
    ) throws {
        try self.init(from: tokenized, tokenPrefix: tokenPrefix, tokenSuffix: tokenSuffix, decode: { $0 })
    }
    
    /// Returns the sequence as a tokenized string.
    public func tokenizedString(
        tokenPrefix: String = "%[",
        tokenSuffix: String = "]"
    ) -> String {
        tokenizedString(tokenPrefix: tokenPrefix, tokenSuffix: tokenSuffix, encode: { $0 })
    }
}

extension TokenizedString where Token: RawRepresentable, Token.RawValue == String {
    /// Initializes by decoding a tokenized string.
    @_disfavoredOverload
    public init(
        from tokenized: String,
        tokenPrefix: String = "%[",
        tokenSuffix: String = "]"
    ) throws {
        try self.init(
            from: tokenized,
            tokenPrefix: tokenPrefix,
            tokenSuffix: tokenSuffix,
            decode: { Token(rawValue: $0) }
        )
    }
    
    /// Returns the sequence as a tokenized string.
    @_disfavoredOverload
    public func tokenizedString(
        tokenPrefix: String = "%[",
        tokenSuffix: String = "]"
    ) -> String {
        tokenizedString(tokenPrefix: tokenPrefix, tokenSuffix: tokenSuffix, encode: { $0.rawValue })
    }
}

// MARK: - Sequence Category Methods

extension TokenizedString where Element: Equatable {
    /// Returns true if the sequence contains the given token.
    public func contains(_ token: Token) -> Bool {
        sequence.contains(where: { $0 == token })
    }
    
    /// Returns true if the sequence contains the given plain-text string.
    @_disfavoredOverload
    public func contains(_ string: String) -> Bool {
        sequence.contains(where: { $0 == .string(string) })
    }
}
