//
//  Utilities.swift
//  SwiftUITokenField • https://github.com/orchetect/SwiftUITokenField
//  © 2025 Steffan Andrews • Licensed under MIT License
//
//  Created by Steffan Andrews on 2025-08-07.
//

extension Sequence where Element: Hashable {
    func mapToDictionaryValues<T>(withKeys key: (Element) -> T) -> [T: Element] {
        reduce(into: [:]) { base, element in
            base[key(element)] = element
        }
    }
    
    func mapToDictionaryKeys<T>(withValues value: (Element) -> T) -> [Element: T] {
        reduce(into: [:]) { base, element in
            base[element] = value(element)
        }
    }
}

#if os(macOS)

import AppKit

extension NSTokenField {
    /// Returns true if the token field or any of its subviews are currently the first responder.
    @MainActor
    var isFirstResponder: Bool {
        guard let responder = window?.firstResponder else { return false }
        return responder == self
            || responder == cell
            || responder.nextResponder?.nextResponder == self // typically the nested NSTextEditView
    }
    
    @MainActor
    func removeFirstResponderIfFocused() {
        guard isFirstResponder else { return }
        
        DispatchQueue.main.async {
            let target = self.superview ?? self.window
            self.window?.makeFirstResponder(target)
        }
    }
}

#endif
