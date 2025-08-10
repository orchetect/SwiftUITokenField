//
//  ContentView.swift
//  SwiftUITokenField • https://github.com/orchetect/SwiftUITokenField
//  © 2025 Steffan Andrews • Licensed under MIT License
//

import SwiftUI
import SwiftUITokenField

struct ContentView: View {
    @State private var isEditable: Bool = true
    @State private var isDuplicateTokensAllowed: Bool = false
    @State private var isTokenSubstitutedInline: Bool = false
    @State private var tokens: [Token] = .preset // []
    
    var body: some View {
        Form {
            Section("Token Field") {
                VStack(alignment: .leading, spacing: 10) {
                    TokenField(
                        $tokens,
                        allowDuplicateTokens: isDuplicateTokensAllowed,
                        isEditable: $isEditable,
                        decode: { isTokenSubstitutedInline ? $0.substitutionString : $0.rawValue }
                    )
                    .id([isDuplicateTokensAllowed, isTokenSubstitutedInline]) // force refresh when options are toggled
                    
                    Text(tokens.map(\.rawValue).joined(separator: ", "))
                }
                
                LabeledContent("Append Token from Menu") {
                    Menu {
                        ForEach(Token.allCases) { token in
                            Button("\(token.rawValue) - \(token.substitutionString)") {
                                tokens.append(token)
                            }
                        }
                    } label: {
                        Text("Tokens")
                    }
                    .frame(width: 80)
                    .multilineTextAlignment(.trailing)
                }
                
                LabeledContent("Insert Token by Dragging") {
                    HStack {
                        ForEach(Token.allCases) { token in
                            Text(token.rawValue)
                                .textSelection(.disabled)
                                .padding([.leading, .trailing], 5)
                                .background(.tertiary)
                                .border(.secondary)
                                .draggable(token.rawValue)
                        }
                    }
                }
                
                Toggle("Editable", isOn: $isEditable)
                
                Toggle("Allow Duplicate Tokens", isOn: $isDuplicateTokensAllowed)
                
                Toggle("Inline Token Substitutions", isOn: $isTokenSubstitutedInline)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Mock Data

extension [Token] {
    /// Sample data for the demo.
    static let preset: Self = [.foobar]
}
