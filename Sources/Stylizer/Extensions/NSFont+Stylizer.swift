//
//  NSFont+Stylizer.swift
//  Stylizer
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

// MARK: - NSFont Extension

extension NSFont {

    // MARK: Internal Constants

    internal static let defaultFont: NSFont = .systemFont(ofSize: NSFont.systemFontSize)

    // MARK: Internal Methods

    internal func byAddingSymbolicTraits(_ traits: NSFontDescriptor.SymbolicTraits) -> NSFont? {
        return NSFont(descriptor: fontDescriptor.withSymbolicTraits(fontDescriptor.symbolicTraits.union(traits)), size: 0.0)
    }
}
#endif // #if canImport(AppKit) && !targetEnvironment(macCatalyst)
