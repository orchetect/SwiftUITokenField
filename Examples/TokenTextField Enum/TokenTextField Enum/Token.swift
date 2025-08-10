//
//  Token.swift
//  SwiftUITokenField • https://github.com/orchetect/SwiftUITokenField
//  © 2025 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftUI

public enum Token: String, CaseIterable {
    case foobar
    case date
    case time
}

extension Token: Identifiable {
    public var id: RawValue { rawValue }
}

extension Token {
    public var substitutionString: String {
        switch self {
        case .foobar:
            "all messed up"
        case .date:
            Date().formatted(date: .abbreviated, time: .omitted)
        case .time:
            Date().formatted(date: .omitted, time: .standard)
        }
    }
}
