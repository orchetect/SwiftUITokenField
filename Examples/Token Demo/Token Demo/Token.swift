//
//  Token.swift
//  SwiftUITokenField • https://github.com/orchetect/SwiftUITokenField
//  © 2025 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftUI

public enum Token: String {
    case foobar
    case date
    case time
}

extension Token: CaseIterable { }

extension Token: Equatable { }

extension Token: Hashable { }

extension Token: Identifiable {
    public var id: RawValue { rawValue }
}

extension Token: Codable { }

extension Token {
    public var outputString: String {
        switch self {
        case .foobar:
            "all messed up"
        case .date:
            Date().formatted(date: .complete, time: .omitted)
        case .time:
            Date().formatted(date: .omitted, time: .standard)
        }
    }
}
