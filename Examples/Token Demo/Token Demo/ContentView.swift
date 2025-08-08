//
//  ContentView.swift
//  SwiftUITokenField • https://github.com/orchetect/SwiftUITokenField
//  © 2025 Steffan Andrews • Licensed under MIT License
//

import SwiftUI
import SwiftUITokenField

struct ContentView: View {
    @State private var tokens: TokenTextField<Token>.TokenizedString = .preset // .init()
    
    @State private var previewID: UUID = UUID()
    @State private var updateTimer: Task<Void, any Error>?
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 40) {
                Menu {
                    ForEach(Token.allCases) { token in
                        Button(token.rawValue) { tokens.sequence.append(.token(token)) }
                    }
                } label: {
                    Text("Append Token")
                }
                .frame(width: 150)
                
                Text("OR")
                    .font(.title2)
                
                VStack(spacing: 5) {
                    Text("Insert Token by Dragging:")
                    HStack {
                        ForEach(Token.allCases) { token in
                            Text(token.rawValue)
                                .padding([.leading, .trailing], 5)
                                .background(.tertiary)
                                .border(.secondary)
                                .draggable(token.rawValue)
                        }
                    }
                }
            }
            
            TokenTextField(
                $tokens,
                completions: [:], // Token.allCases.reduce(into: [:]) { $0[$1] = $1.rawValue },
                decode: { token in token.rawValue },
                encode: { string in Token(rawValue: string) }
            )
            
            Text("Preview output:")
            Text(previewString).id(previewID)
            
            HStack {
                Button("Save as Tokenized String") { saveTokenizedString() }
                Button("Load as Tokenized String") { loadTokenizedString() }
            }
            
            HStack {
                Button("Save as Codable JSON") { saveCodableJSON() }
                Button("Load as Codable JSON") { loadCodableJSON() }
            }
        }
        .padding()
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
    }
    
    private var previewString: String {
        tokens.string { token in token.outputString }
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
    
    private func saveCodableJSON() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(tokens)
            UserDefaults.standard.set(encodedData, forKey: "savedTokensJSON")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func loadCodableJSON() {
        do {
            let decoder = JSONDecoder()
            guard let encodedData = UserDefaults.standard.data(forKey: "savedTokensJSON") else { return }
            let decoded = try decoder.decode(TokenTextField<Token>.TokenizedString.self, from: encodedData)
            tokens = decoded
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func saveTokenizedString() {
        let tokenizedString = tokens.tokenizedString()
        UserDefaults.standard.set(tokenizedString, forKey: "savedTokenizedString")
    }
    
    private func loadTokenizedString() {
        do {
            guard let tokenizedString = UserDefaults.standard.string(forKey: "savedTokenizedString") else { return }
            tokens = try TokenTextField<Token>.TokenizedString(from: tokenizedString)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension TokenTextField<Token>.TokenizedString {
    // Sample data for the demo.
    static let preset = Self(sequence: [
        .string("This is all "),
        .token(.foobar),
        .string(" at "),
        .token(.time),
        .string(" on "),
        .token(.date),
        .string(".")
    ])
}
