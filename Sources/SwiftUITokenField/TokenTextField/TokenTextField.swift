//
//  TokenTextField.swift
//  SwiftUITokenField • https://github.com/orchetect/SwiftUITokenField
//  © 2025 Steffan Andrews • Licensed under MIT License
//

#if os(macOS)

import AppKit
import SwiftUI

/// A text field that allows mixed entry of text and strongly-typed tokens.
public struct TokenTextField<Token>: View, NSViewRepresentable where Token: Hashable {
    @Binding private var tokens: TokenizedString<Token>
    
    private var isEditable: Bool
    private var decode: (Token) -> String
    private var encode: (String) -> Token?
    private var completions: [Token: String]
    private var allowDuplicateTokens: Bool
    
    // MARK: - View Creation
    
    public func makeNSView(context: Context) -> NSTokenField {
        let tokenField = NSTokenField()
        tokenField.delegate = context.coordinator
        
        // prevents auto-tokenizing user keyboard input from comma entry
        tokenField.tokenizingCharacterSet = CharacterSet()
        tokenField.tokenStyle = .rounded
        tokenField.allowsEditingTextAttributes = false
        
        // geometry
        tokenField.autoresizingMask = [.width, .height]
        
        // configure cell
        let cell = tokenField.cell as? NSTokenFieldCell
        cell?.setCellAttribute(.cellIsBordered, to: 0)
        cell?.tokenStyle = tokenField.tokenStyle
        
        return tokenField
    }
    
    // MARK: - View Update
    
    public func updateNSView(_ nsView: NSTokenField, context: Context) {
        if let bounds = nsView.superview?.bounds {
            nsView.frame = bounds
        }
        
        // data
        nsView.objectValue = unwrap(tokens: tokens)
        
        // editable
        let wasEditable = nsView.isEditable
        nsView.isEditable = isEditable
        if wasEditable, !isEditable {
            // print("Removing focus from token field.")
            nsView.removeFirstResponderIfFocused()
        }
    }
    
    // MARK: - Coordinator
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public final class Coordinator: NSObject, NSTokenFieldDelegate, ObservableObject {
        var parent: TokenTextField<Token>
        
        init(_ parent: TokenTextField<Token>) {
            self.parent = parent
        }
        
        public func tokenField(
            _ tokenField: NSTokenField,
            displayStringForRepresentedObject representedObject: Any
        ) -> String? {
            switch representedObject {
            case let token as Token: parent.decode(token)
            case let string as String: string
            default: nil
            }
        }
        
        public func tokenField(
            _ tokenField: NSTokenField,
            editingStringForRepresentedObject representedObject: Any
        ) -> String? {
            switch representedObject {
            case let token as Token: parent.decode(token)
            case let string as String: string
            default: nil
            }
        }
        
        // implementing this method prevents the default behavior of trimming whitespaces from tokens
        public func tokenField(
            _ tokenField: NSTokenField,
            representedObjectForEditing editingString: String
        ) -> Any? {
            editingString
        }
        
        public func tokenField(
            _ tokenField: NSTokenField,
            shouldAdd tokens: [Any],
            at index: Int
        ) -> [Any] {
            var output: [Any] = [] // TODO: may need to refactor using TokenWrapper from TokenField to avoid typing issues when `Token` is `String`
            
            func add(token: Token) {
                // reject duplicate token if not allowed
                if !parent.allowDuplicateTokens,
                   parent._tokens.wrappedValue.contains(token) == true
                {
                    // print("Rejecting duplicate token: \(token)")
                    return
                }
                output.append(token)
            }
            
            for token in tokens {
                if let cast = token as? Token {
                    // print("Cast as token: \(String(describing: cast))")
                    output.append(cast)
                } else if let string = token as? String {
                    // try converting to token first
                    if let cast = parent.encode(string) {
                        // print("Converted string to token: \(String(describing: cast))")
                        add(token: cast)
                    } else {
                        // print("Cast as string: \(String(describing: string))")
                        output.append(string)
                    }
                } else {
                    // print("Unhandled token object: \(String(describing: token))")
                }
            }
            
            return output
        }
        
        public func tokenField(
            _ tokenField: NSTokenField,
            styleForRepresentedObject representedObject: Any
        ) -> NSTokenField.TokenStyle {
            switch representedObject {
            case is Token: .rounded
            case is String: .none
            default: .none
            }
        }
        
        public func tokenField(
            _ tokenField: NSTokenField,
            completionsForSubstring substring: String,
            indexOfToken tokenIndex: Int,
            indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>?
        ) -> [Any]? {
            guard substring.count >= 2 else { return nil } // minimum text length
            
            let candidates = parent.completions.filter { $0.value.starts(with: substring) }.values
            return candidates.isEmpty ? nil : Array(candidates)
        }
        
        public func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTokenField else {
                // print("Control text did change, but object not a token field")
                return
            }
            guard let anyArray = textField.objectValue as? [Any],
                  let mapped = mapToTokensElements(anyArray)
            else {
                // print("Control text did change, but encountered unexpected type: \(type(of: textField.objectValue))")
                return
            }
            parent._tokens.wrappedValue.sequence = mapped
        }
        
        // not used
        public func tokenField(_ tokenField: NSTokenField, hasMenuForRepresentedObject representedObject: Any) -> Bool {
            false
        }
        
        // not used
        public func tokenField(_ tokenField: NSTokenField, menuForRepresentedObject representedObject: Any) -> NSMenu? {
            nil
        }
        
        /// Utility method to wrap the raw objects in ``TokenizedString/Element``-wrapped enum cases.
        func mapToTokensElements(_ objects: [Any]) -> [TokenizedString<Token>.Element]? {
            var mapped: [TokenizedString<Token>.Element] = []
            for object in objects {
                switch object {
                case let token as Token: mapped.append(.token(token))
                case let string as String: mapped.append(.string(string))
                default: return nil
                }
            }
            return mapped
        }
    }
    
    /// Utility method to unwrap ``TokenizedString/Element``-wrapped objects and return an array to use with `NSTokenField`.
    func unwrap(tokens: TokenizedString<Token>) -> [Any] {
        tokens.sequence.map {
            switch $0 {
            case let .token(token): token
            case let .string(string): string
            }
        }
    }
}

// MARK: - Inits

extension TokenTextField {
    /// Initialize by supplying token encoding and decoding logic.
    public init(
        _ tokens: Binding<TokenizedString<Token>>,
        completions: [Token: String] = [:],
        allowDuplicateTokens: Bool = true,
        isEditable: Bool = true,
        decode: @escaping (_ token: Token) -> String,
        encode: @escaping (_ string: String) -> Token?
    ) {
        _tokens = tokens
        self.completions = completions
        self.allowDuplicateTokens = allowDuplicateTokens
        self.isEditable = isEditable
        self.decode = decode
        self.encode = encode
    }
}

extension TokenTextField where Token: RawRepresentable, Token.RawValue == String {
    /// Initialize using a token type that is `RawRepresentable` as a `String`, tokenizing string input based on its raw value.
    public init(
        _ tokens: Binding<TokenizedString<Token>>,
        completions: [Token: String] = [:],
        allowDuplicateTokens: Bool = true,
        isEditable: Bool = true
    ) {
        _tokens = tokens
        self.completions = completions
        self.allowDuplicateTokens = allowDuplicateTokens
        self.isEditable = isEditable
        decode = { $0.rawValue }
        encode = { Token(rawValue: $0) }
    }
}

extension TokenTextField where Token: RawRepresentable, Token.RawValue == String, Token: CaseIterable {
    /// Initialize using a token type that is `RawRepresentable` as a `String` & `CaseIterable`, tokenizing string input
    /// based on its raw value and auto-populating completions.
    public init(
        _ tokens: Binding<TokenizedString<Token>>,
        allowDuplicateTokens: Bool = true,
        isEditable: Bool = true
    ) {
        _tokens = tokens
        completions = Token.allCases.mapToDictionaryKeys(withValues: { $0.rawValue })
        self.allowDuplicateTokens = allowDuplicateTokens
        self.isEditable = isEditable
        decode = { $0.rawValue }
        encode = { Token(rawValue: $0) }
    }
}

#endif
