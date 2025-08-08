//
//  TokenTextField TokenizedString.swift
//  SwiftUITokenField • https://github.com/orchetect/SwiftUITokenField
//  © 2025 Steffan Andrews • Licensed under MIT License
//

#if os(macOS)

extension TokenTextField {
    public struct TokenizedString {
        public var sequence: [Element]
        
        public init(sequence: [Element] = []) {
            self.sequence = sequence
        }
    }
}

extension TokenTextField.TokenizedString: Equatable where Token: Equatable { }

extension TokenTextField.TokenizedString: Hashable where Token: Hashable { }

extension TokenTextField.TokenizedString: Sendable where Token: Sendable { }

extension TokenTextField.TokenizedString: Identifiable where Token: Hashable {
    public var id: Self { self }
}

extension TokenTextField.TokenizedString {
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

extension TokenTextField.TokenizedString where Token: RawRepresentable, Token.RawValue == String {
    /// Initializes by decoding a tokenized string.
    public init(from tokenizedString: String, tokenPrefix: String = "%[", tokenSuffix: String = "]") throws {
        assert(tokenPrefix != "")
        assert(tokenSuffix != "")
        
        var sequence: [Element] = []
        
        var index = tokenizedString.startIndex
        
        while index < tokenizedString.endIndex {
            if let tokenStart = tokenizedString
                .range(of: tokenPrefix, options: [], range: index ..< tokenizedString.endIndex, locale: nil)
            {
                guard let tokenEnd = tokenizedString
                    .range(of: tokenSuffix, options: [], range: tokenStart.upperBound ..< tokenizedString.endIndex, locale: nil)
                else {
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(codingPath: [], debugDescription: "Encountered token prefix without a corresponding suffix.")
                    )
                }
                
                let tokenString = String(tokenizedString[tokenStart.upperBound ..< tokenEnd.lowerBound])
                
                guard let token = Token(rawValue: tokenString) else {
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(codingPath: [], debugDescription: "Unrecognized token: \(tokenString).")
                    )
                }
                
                // add intermediate string if necessary
                if tokenStart.lowerBound > index {
                    let string = String(tokenizedString[index ..< tokenStart.lowerBound])
                    sequence.append(.string(string))
                }
                
                sequence.append(.token(token))
                index = tokenEnd.upperBound
            } else {
                let string = String(tokenizedString[index ..< tokenizedString.endIndex])
                sequence.append(.string(string))
                index = tokenizedString.endIndex
            }
        }
        
        self.init(sequence: sequence)
    }
    
    /// Returns the sequence as a tokenized string.
    public func tokenizedString(tokenPrefix: String = "%[", tokenSuffix: String = "]") -> String {
        assert(tokenPrefix != "")
        assert(tokenSuffix != "")
        
        return sequence
            .map {
                switch $0 {
                case let .token(token): tokenPrefix + token.rawValue + tokenSuffix
                case let .string(string): string
                }
            }
            .joined()
    }
}

#endif
