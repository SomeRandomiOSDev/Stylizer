//
//  String+Stylizer.swift
//  Stylizer
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

import Foundation

// MARK: - String Extension

extension String {

    // MARK: Public Methods

    /**
     Creates a `NSAttributedString` by stylizing the receiver using the provided list
     of stylizers.

     - parameters:
       - stylizers: The list of stylizers with which to stylize this string. The
                    stylizers are applied in order.
       - defaultFont: The font to use when applying the `.stylizerBold` and
                      `.stylizerItalics` placeholders.
       - customAttributesProvider: A closure used for supplying UIKit/AppKit attributes
                                   for registered custom placeholders.

     - returns: A new attributed string with style patterns defined by the provided
                `stylizers` replaced with the defined replacements and UIKit/AppKit
                attributes.

     For `.stylizerBold` and `.stylizerItalics` placeholders parsed from the
     stylizers the `defaultFont` parameter is used to create a bold or italicized
     font for the ranges where those placeholder attributes apply. If no
     `defaultFont` is provided then any `.stylizerBold` and `.stylizerItalics` are
     removed but are not replaced with other attributes.
     */
    public func stylize(with stylizers: [Stylizer], defaultFont: StylizerNativeFont? = nil, customAttributesProvider: StylizerCustomAttributesProvider? = nil) -> NSAttributedString {
        guard !stylizers.isEmpty else { return NSAttributedString(string: self) }

        return NSAttributedString(string: self).stylize(with: stylizers, defaultFont: defaultFont, customAttributesProvider: customAttributesProvider)
    }
}
