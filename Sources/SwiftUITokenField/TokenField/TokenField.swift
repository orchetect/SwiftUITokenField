//
//  TokenField.swift
//  SwiftUITokenField • https://github.com/orchetect/SwiftUITokenField
//  © 2025 Steffan Andrews • Licensed under MIT License
//

#if os(macOS)

import AppKit
import SwiftUI

/// A text field that allows entry of strongly-typed tokens.
public struct TokenField<Token>: View, NSViewRepresentable where Token: Hashable {
    @Binding private var tokens: [Token]
    @Binding private var isEditable: Bool
    
    private var decode: (Token) -> String
    private var encode: (String) -> Token?
    private var completions: [Token: String]
    private var allowNewStringTokens: Bool
    private var allowDuplicateTokens: Bool
    
    // MARK: - View Creation
    
    public func makeNSView(context: Context) -> NSTokenField {
        let tokenField = NSTokenField()
        tokenField.delegate = context.coordinator
        
        // appearance
        tokenField.tokenStyle = .rounded
        
        // behavior
        tokenField.isEditable = isEditable
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
        nsView.objectValue = tokens.map { TokenWrapper(token: $0) }
        if !allowDuplicateTokens {
            DispatchQueue.main.async { context.coordinator.removeDuplicateTokens() }
        }
        
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
        var parent: TokenField<Token>
        
        init(_ parent: TokenField<Token>) {
            self.parent = parent
        }
        
        public func tokenField(
            _ tokenField: NSTokenField,
            displayStringForRepresentedObject representedObject: Any
        ) -> String? {
            // TODO: allow a different display string than the token's raw identifier string
            switch representedObject {
            case let wrappedToken as TokenWrapper: parent.decode(wrappedToken.token)
            case let string as String: string
            default: nil
            }
        }
        
        public func tokenField(
            _ tokenField: NSTokenField,
            editingStringForRepresentedObject representedObject: Any
        ) -> String? {
            switch representedObject {
            case let wrappedToken as TokenWrapper: parent.decode(wrappedToken.token)
            case let string as String: string
            default: nil
            }
        }
        
        public func tokenField(
            _ tokenField: NSTokenField,
            shouldAdd tokens: [Any],
            at index: Int
        ) -> [Any] {
            var output: [TokenWrapper] = []
            
            // if token type is String, we can allow arbitrary entry of new tokens not defined
            // if token type is non-String, we are limited to valid instances of the token
            
            for case let item as String in tokens {
                if let token = parent.encode(item) {
                    // reject new String token if not allowed
                    if Token.self is String,
                        !parent.allowNewStringTokens,
                        !parent.completions.keys.contains(token)
                    {
                        continue
                    }
                    
                    // reject duplicate token if not allowed
                    if !parent.allowDuplicateTokens,
                       parent._tokens.wrappedValue.contains(token) == true
                    {
                        // print("Rejecting duplicate token: \(token)")
                        continue
                    }
                    
                    output.append(TokenWrapper(token: token))
                }
            }
            
            return output
        }
        
        public func tokenField(
            _ tokenField: NSTokenField,
            styleForRepresentedObject representedObject: Any
        ) -> NSTokenField.TokenStyle {
            .rounded
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
            guard let anyArray = textField.objectValue as? [Any]
            else {
                // print("Control text did change, but object value data unexpected type: \(type(of: textField.objectValue))")
                return
            }
            let mapped = anyArray
                .compactMap { $0 as? TokenWrapper }
                .map(\.token)
            parent._tokens.wrappedValue = mapped
        }
        
        // not used
        public func tokenField(_ tokenField: NSTokenField, hasMenuForRepresentedObject representedObject: Any) -> Bool {
            false
        }
        
        // not used
        public func tokenField(_ tokenField: NSTokenField, menuForRepresentedObject representedObject: Any) -> NSMenu? {
            nil
        }
        
        func removeDuplicateTokens() {
            let tokens = parent._tokens.wrappedValue.removingDuplicates()
            
            if parent._tokens.wrappedValue != tokens {
                parent._tokens.wrappedValue = tokens
            }
        }
    }
    
    /// Token wrapper used to differentiate tokens from in-progress user text input,
    /// since it's possible for Token to be of type `String`.
    private struct TokenWrapper {
        var token: Token
    }
}

// MARK: - Inits

extension TokenField {
    /// Initialize by supplying token encoding and decoding logic.
    public init(
        _ tokens: Binding<[Token]>,
        completions: [Token: String] = [:],
        allowDuplicateTokens: Bool = false,
        isEditable: Binding<Bool> = .constant(true),
        decode: @escaping (_ token: Token) -> String,
        encode: @escaping (_ string: String) -> Token?
    ) {
        _tokens = tokens
        self.completions = completions
        _isEditable = isEditable
        self.decode = decode
        self.encode = encode
        allowNewStringTokens = false // unused
        self.allowDuplicateTokens = allowDuplicateTokens
    }
}

extension TokenField where Token == String {
    /// Initialize with `String` tokens.
    public init(
        _ tokens: Binding<[Token]>,
        completions: [String] = [],
        allowNewTokens: Bool = true,
        allowDuplicateTokens: Bool = false,
        isEditable: Binding<Bool> = .constant(true)
    ) {
        _tokens = tokens
        self.completions = completions.mapToDictionaryKeys(withValues: { $0 })
        _isEditable = isEditable
        decode = { $0 }
        encode = { $0 }
        allowNewStringTokens = allowNewTokens
        self.allowDuplicateTokens = allowDuplicateTokens
    }
}

extension TokenField where Token: RawRepresentable, Token.RawValue == String {
    /// Initialize using a token type that is `RawRepresentable` as a `String`, tokenizing string input based on its raw value.
    public init(
        _ tokens: Binding<[Token]>,
        completions: [Token: String] = [:],
        allowDuplicateTokens: Bool = false,
        isEditable: Binding<Bool> = .constant(true)
    ) {
        _tokens = tokens
        self.completions = completions
        _isEditable = isEditable
        decode = { $0.rawValue }
        encode = { Token(rawValue: $0) }
        allowNewStringTokens = false // unused
        self.allowDuplicateTokens = allowDuplicateTokens
    }
}

extension TokenField where Token: RawRepresentable, Token.RawValue == String, Token: CaseIterable {
    /// Initialize using a token type that is `RawRepresentable` as a `String` & `CaseIterable`, tokenizing string input
    /// based on its raw value and auto-populating completions.
    public init(
        _ tokens: Binding<[Token]>,
        allowDuplicateTokens: Bool = false,
        isEditable: Binding<Bool> = .constant(true)
    ) {
        _tokens = tokens
        completions = Token.allCases.mapToDictionaryKeys(withValues: { $0.rawValue })
        _isEditable = isEditable
        decode = { $0.rawValue }
        encode = { Token(rawValue: $0) }
        allowNewStringTokens = false // unused
        self.allowDuplicateTokens = allowDuplicateTokens
    }
}

#endif
