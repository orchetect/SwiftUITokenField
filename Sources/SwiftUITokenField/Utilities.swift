//
//  Utilities.swift
//  SwiftUITokenField
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
