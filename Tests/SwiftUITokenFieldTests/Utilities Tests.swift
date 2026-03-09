//
//  Utilities Tests.swift
//  SwiftUITokenField • https://github.com/orchetect/SwiftUITokenField
//  © 2025 Steffan Andrews • Licensed under MIT License
//

import SwiftUI
@testable import SwiftUITokenField
import Testing

@Suite struct Utilities_Tests {
    @Test
    func removingDuplicates() throws {
        #expect(([] as [String]).removingDuplicates() == [])
        #expect((["a"]).removingDuplicates() == ["a"])
        #expect((["a", "b"]).removingDuplicates() == ["a", "b"])
        #expect((["a", "b", "c"]).removingDuplicates() == ["a", "b", "c"])
        #expect((["a", "b", "B"]).removingDuplicates() == ["a", "b", "B"])
        
        #expect((["a", "a"]).removingDuplicates() == ["a"])
        #expect((["a", "a", "a"]).removingDuplicates() == ["a"])
        #expect((["a", "b", "a"]).removingDuplicates() == ["a", "b"])
        #expect((["b", "a", "a"]).removingDuplicates() == ["b", "a"])
        #expect((["a", "a", "b", "b"]).removingDuplicates() == ["a", "b"])
        #expect((["a", "b", "a", "b"]).removingDuplicates() == ["a", "b"])
    }
}
