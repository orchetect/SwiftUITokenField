//
//  FactoryTokens.swift
//  SwiftUITokenField • https://github.com/orchetect/SwiftUITokenField
//  © 2025 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftUI

public enum FactoryTokens {
    public static let foobar = "foobar"
    public static let date = "date"
    public static let time = "time"
    
    public static func allTokens() -> [String] {
        [Self.foobar, Self.date, Self.time]
    }
}

extension String {
    public var tokenSubstitution: String {
        switch self {
        case FactoryTokens.foobar:
            "all messed up"
        case FactoryTokens.date:
            Date().formatted(date: .complete, time: .omitted)
        case FactoryTokens.time:
            Date().formatted(date: .omitted, time: .standard)
        default:
            self
        }
    }
}
