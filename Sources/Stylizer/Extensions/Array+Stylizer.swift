//
//  Array+Stylizer.swift
//  Stylizer
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

// MARK: - Array Extension

extension Array where Element: Hashable {

    // MARK: Internal Methods

    internal func makeUnique() -> [Element] {
        var set: Set<Element> = []
        var array: [Element] = []

        for element in self {
            if set.insert(element).inserted {
                array.append(element)
            }
        }

        return array
    }
}
