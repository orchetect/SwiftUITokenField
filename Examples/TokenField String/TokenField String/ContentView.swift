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
    @State private var isNewTokensAllowed: Bool = true
    @State private var tokens: [String] = .presetTokens // []
    
    var body: some View {
        Form {
            Section("Token Field") {
                VStack(alignment: .leading, spacing: 10) {
                    TokenField(
                        $tokens,
                        completions: .factoryTokens,
                        allowNewTokens: isNewTokensAllowed,
                        allowDuplicateTokens: isDuplicateTokensAllowed,
                        isEditable: $isEditable
                    )
                    .id([isDuplicateTokensAllowed, isNewTokensAllowed]) // force refresh when option is toggled
                    
                    Text(tokens.joined(separator: ", "))
                }
                
                LabeledContent("Append Token from Menu") {
                    Menu {
                        ForEach([String].factoryTokens, id: \.self) { token in
                            Button(token) {
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
                        ForEach([String].factoryTokens, id: \.self) { token in
                            Text(token)
                                .textSelection(.disabled)
                                .padding([.leading, .trailing], 5)
                                .background(.tertiary)
                                .border(.secondary)
                                .draggable(token)
                        }
                    }
                }
                
                Toggle("Editable", isOn: $isEditable)
                
                Toggle("Allow Duplicate Tokens", isOn: $isDuplicateTokensAllowed)
                
                Toggle("Allow New Token Creation", isOn: $isNewTokensAllowed)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Mock Data

extension [String] {
    /// Factory tokens the app provides.
    static let factoryTokens: Self = ["foobar", "date", "time"]
    
    /// Sample data for the demo.
    static let presetTokens: Self = ["foobar"]
}
