//
//  Utilities.swift
//  SwiftUITokenField • https://github.com/orchetect/SwiftUITokenField
//  © 2025 Steffan Andrews • Licensed under MIT License
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

extension RangeReplaceableCollection where Self: RandomAccessCollection, Element: Equatable {
    mutating func removeDuplicates() {
        guard var index = indices.last else { return }
        while count > 1, index > startIndex {
            let element = self[index]
            if self[startIndex ..< index].contains(element) {
                self.remove(at: index)
            }
            index = self.index(before: index)
        }
    }
    
    func removingDuplicates() -> Self {
        var copy = self
        copy.removeDuplicates()
        return copy
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
