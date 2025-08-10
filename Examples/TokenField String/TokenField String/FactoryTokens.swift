//
//  FactoryTokens.swift
//  SwiftUITokenField • https://github.com/orchetect/SwiftUITokenField
//  © 2025 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftUI
import SwiftUITokenField

public enum FactoryTokens {
    public static let foobar = "foobar"
    public static let date = "date"
    public static let time = "time"
    
    public static func allTokens() -> [String] {
        [foobar, date, time]
    }
    
    public static func substitution(for token: String) -> String {
        switch token {
        case foobar:
            "all messed up"
        case date:
            Date().formatted(date: .abbreviated, time: .omitted)
        case time:
            Date().formatted(date: .omitted, time: .standard)
        default:
            token
        }
    }
}
