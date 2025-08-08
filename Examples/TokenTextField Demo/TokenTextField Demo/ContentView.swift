//
//  ContentView.swift
//  SwiftUITokenField • https://github.com/orchetect/SwiftUITokenField
//  © 2025 Steffan Andrews • Licensed under MIT License
//

import SwiftUI
import SwiftUITokenField

struct ContentView: View {
    @State private var tokenizedString: TokenizedString<Token> = .preset // .init()
    
    @State private var previewID: UUID = UUID()
    @State private var updateTimer: Task<Void, any Error>?
    
    var body: some View {
        Form {
            Section("Token TextField") {
                VStack(alignment: .leading, spacing: 10) {
                    TokenTextField($tokenizedString)
                    Text(previewString).id(previewID)
                }
                
                LabeledContent("Append Token from Menu") {
                    Menu {
                        ForEach(Token.allCases) { token in
                            Button("\(token.rawValue) - \(token.outputString)") {
                                tokenizedString.sequence.append(.token(token))
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
            }
            
            Section("UserDefaults") {
                LabeledContent("Tokenized String") {
                    Button("Save") { saveTokenizedString() }
                    Button("Load") { loadTokenizedString() }
                }
                LabeledContent("Codable JSON") {
                    Button("Save") { saveCodableJSON() }
                    Button("Load") { loadCodableJSON() }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
    }
    
    private var previewString: String {
        tokenizedString.string { token in token.outputString }
    }
    
    private func startTimer() {
        updateTimer?.cancel()
        // since we're using date and time tokens, this timer is only needed to update UI as time passes
        updateTimer = Task {
            while !Task.isCancelled {
                previewID = UUID()
                try await Task.sleep(for: .seconds(1))
            }
        }
    }
    
    private func stopTimer() {
        updateTimer?.cancel()
        updateTimer = nil
    }
}

// MARK: - Serialization

extension ContentView {
    private func saveCodableJSON() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(tokenizedString)
            if let jsonString = String(data: encodedData, encoding: .utf8) {
                print("Saving JSON: \(jsonString)")
            }
            UserDefaults.standard.set(encodedData, forKey: "savedTokensJSON")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func loadCodableJSON() {
        do {
            let decoder = JSONDecoder()
            guard let encodedData = UserDefaults.standard.data(forKey: "savedTokensJSON") else { return }
            if let jsonString = String(data: encodedData, encoding: .utf8) {
                print("Loading JSON: \(jsonString)")
            }
            let decoded = try decoder.decode(TokenizedString<Token>.self, from: encodedData)
            tokenizedString = decoded
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func saveTokenizedString() {
        let encoded = tokenizedString.tokenizedString()
        print("Saving tokenized string: \"\(encoded)\"")
        UserDefaults.standard.set(encoded, forKey: "savedTokenizedString")
    }
    
    private func loadTokenizedString() {
        do {
            guard let encoded = UserDefaults.standard.string(forKey: "savedTokenizedString") else { return }
            print("Loading tokenized string: \"\(encoded)\"")
            tokenizedString = try TokenizedString<Token>(from: encoded)
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Mock Data

extension TokenizedString<Token> {
    /// Sample data for the demo.
    static let preset = Self(sequence: [
        .string("Something is "),
        .token(.foobar),
        .string(" at "),
        .token(.time),
        .string(" on "),
        .token(.date),
        .string(".")
    ])
}
