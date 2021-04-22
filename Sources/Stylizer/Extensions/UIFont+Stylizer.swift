//
//  UIFont+Stylizer.swift
//  Stylizer
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

#if canImport(UIKit)
import UIKit

// MARK: - UIFont Extension

extension UIFont {

    // MARK: Internal Constants

    internal static let defaultFont: UIFont = .preferredFont(forTextStyle: .body)

    // MARK: Internal Methods

    internal func byAddingSymbolicTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont? {
        return fontDescriptor.withSymbolicTraits(fontDescriptor.symbolicTraits.union(traits)).map { UIFont(descriptor: $0, size: 0.0) }
    }
}

// MARK: - UIFontDescriptor.SymbolicTraits Extension

extension UIFontDescriptor.SymbolicTraits {

    // MARK: Internal Constants

    internal static let bold = UIFontDescriptor.SymbolicTraits.traitBold
    internal static let italic = UIFontDescriptor.SymbolicTraits.traitItalic
}
#endif // #if canImport(UIKit)
