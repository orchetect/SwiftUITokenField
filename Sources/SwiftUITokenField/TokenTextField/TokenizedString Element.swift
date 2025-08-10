//
//  TokenTextField TokenizedString Element.swift
//  SwiftUITokenField • https://github.com/orchetect/SwiftUITokenField
//  © 2025 Steffan Andrews • Licensed under MIT License
//

#if os(macOS)

extension TokenizedString {
    public enum Element {
        case token(Token)
        case string(String)
    }
}

extension TokenizedString.Element: Equatable where Token: Equatable { }

extension TokenizedString.Element: Hashable where Token: Hashable { }

extension TokenizedString.Element: Sendable where Token: Sendable { }

extension TokenizedString.Element: Identifiable where Token: Hashable {
    public var id: Self { self }
}

// MARK: - Conveniences

extension TokenizedString.Element where Token: RawRepresentable, Token.RawValue == String {
    public var rawValue: Token.RawValue {
        switch self {
        case let .token(token): token.rawValue
        case let .string(string): string
        }
    }
}

// MARK: - Additional Equatable methods

extension TokenizedString.Element where Token: Equatable {
    public static func == (lhs: Self, rhs: Token) -> Bool {
        lhs == .token(rhs)
    }
    
    public static func == (lhs: Token, rhs: Self) -> Bool {
        .token(lhs) == rhs
    }
}

extension TokenizedString.Element where Token == String {
    /// Returns true if either the token string or the plain-text string matches the given predicate.
    public func isEqual(toTokenOrString string: String) -> Bool {
        self == .token(string) || self == .string(string)
    }
}

#endif
