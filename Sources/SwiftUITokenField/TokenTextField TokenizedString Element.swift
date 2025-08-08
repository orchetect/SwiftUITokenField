//
//  TokenTextField TokenizedString Element.swift
//  SwiftUITokenField • https://github.com/orchetect/SwiftUITokenField
//  © 2025 Steffan Andrews • Licensed under MIT License
//

#if os(macOS)

extension TokenTextField.TokenizedString {
    public enum Element {
        case token(Token)
        case string(String)
    }
}

extension TokenTextField.TokenizedString.Element: Equatable where Token: Equatable { }

extension TokenTextField.TokenizedString.Element: Hashable where Token: Hashable { }

extension TokenTextField.TokenizedString.Element: Sendable where Token: Sendable { }

extension TokenTextField.TokenizedString.Element: Identifiable where Token: Hashable {
    public var id: Self { self }
}

// MARK: - Conveniences

extension TokenTextField.TokenizedString.Element where Token: RawRepresentable, Token.RawValue == String {
    public var rawValue: Token.RawValue {
        switch self {
        case let .token(token): token.rawValue
        case let .string(string): string
        }
    }
}

#endif
