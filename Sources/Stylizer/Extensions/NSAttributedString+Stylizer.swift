//
//  NSAttributedString+Stylizer.swift
//  Stylizer
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - NSAttributedString Extension

extension NSAttributedString {

    // MARK: Internal Properties

    internal var stringRange: NSRange {
        return NSRange(location: 0, length: length)
    }

    // MARK: Internal Methods

    internal func containsAttribute(_ attribute: NSAttributedString.Key, in range: NSRange? = nil) -> Bool {
        var containsAttribute = false
        self.enumerateAttributes(in: range ?? stringRange, options: .longestEffectiveRangeNotRequired) { attributes, _, stop in
            if attributes[attribute] != nil {
                containsAttribute = true
                stop.pointee = true
            }
        }

        return containsAttribute
    }
}

#if canImport(UIKit) || canImport(AppKit)

// MARK: - NSAttributedString Extension

extension NSAttributedString {

    // MARK: Public Methods

    /**
     Stylizes the reciver using the provided list of stylizers

     - parameters:
       - stylizers: The list of stylizers with which to stylize this attributed string.
                    The stylizers are applied in order.
       - defaultFont: The font to use when applying the `.stylizerBold` and
                      `.stylizerItalics` placeholders.
       - customAttributesProvider: A closure used for supplying UIKit/AppKit attributes
                                   for registered custom placeholders.

     - returns: A new attributed string with style patterns defined by the provided
                `stylizers` replaced with the defined replacements and UIKit/AppKit
                attributes.

     For `.stylizerBold` and `.stylizerItalics` placeholders already in the
     attributed string or those parsed from the stylizers, any existing `.font`
     attributes whose range overlaps with the placeholders' ranges will be used first
     when processing the placeholders, otherwise the `defaultFont` parameter is used.
     If no `defaultFont` is provided then those ranges that don't already contain
     `.font` attributes will not receive final `.font` attributes with the stylized
     text.

     Even if no stylizers are provided, any placeholder attributes already existing
     in the attributed string will be processed and replaced with the appropriate
     UIKit/AppKit attributes.
     */
    @objc(stylizeWithStylizers:defaultFont:customAttributesProvider:)
    public func stylize(with stylizers: [Stylizer], defaultFont: StylizerNativeFont? = nil, customAttributesProvider: StylizerCustomAttributesProvider? = nil) -> NSAttributedString {
        return stylize(with: stylizers, defaultFont: defaultFont, customAttributesProvider: customAttributesProvider, placeholderAttributeOverrideProvider: nil)
    }

    // MARK: Internal Methods

    internal func stylize(with stylizers: [Stylizer], defaultFont: StylizerNativeFont? = nil, customAttributesProvider: StylizerCustomAttributesProvider? = nil, placeholderAttributeOverrideProvider: StylizerPlaceholderAttributeOverrideProvider? = nil) -> NSAttributedString {
        var stylizedText: NSAttributedString
        if !stylizers.isEmpty {
            stylizedText = stylizers.reduce(into: self) { $0 = $1.attributedStringByReplacingMatches(in: $0) }
        } else {
            stylizedText = self
        }

        do {
            let mutableStylizedText = NSMutableAttributedString(attributedString: stylizedText)
            var superscriptAttribute: (NSAttributedString.Key, NSNumber)?

            #if canImport(AppKit) && !targetEnvironment(macCatalyst)
            superscriptAttribute = (.superscript, NSNumber(value: 1))
            #endif // #if canImport(AppKit) && !targetEnvironment(macCatalyst)

            replaceFontPlaceholderAttribute(.stylizerBold, in: mutableStylizedText, with: .bold, defaultFont: defaultFont, placeholderAttributeOverrideProvider: placeholderAttributeOverrideProvider)
            replaceFontPlaceholderAttribute(.stylizerItalics, in: mutableStylizedText, with: .italic, defaultFont: defaultFont, placeholderAttributeOverrideProvider: placeholderAttributeOverrideProvider)
            replaceNumberPlaceholderAttribute(.stylizerStrikethrough, in: mutableStylizedText, with: (.strikethroughStyle, NSNumber(value: NSUnderlineStyle.single.rawValue)), placeholderAttributeOverrideProvider: placeholderAttributeOverrideProvider)
            replaceNumberPlaceholderAttribute(.stylizerUnderline, in: mutableStylizedText, with: (.underlineStyle, NSNumber(value: NSUnderlineStyle.single.rawValue)), placeholderAttributeOverrideProvider: placeholderAttributeOverrideProvider)
            replaceNumberPlaceholderAttribute(.stylizerSuperscript, in: mutableStylizedText, with: superscriptAttribute, placeholderAttributeOverrideProvider: placeholderAttributeOverrideProvider)
            replaceColorPlaceholderAttribute(.stylizerTextColor, in: mutableStylizedText, with: .foregroundColor, placeholderAttributeOverrideProvider: placeholderAttributeOverrideProvider)
            replaceColorPlaceholderAttribute(.stylizerBackgroundColor, in: mutableStylizedText, with: .backgroundColor, placeholderAttributeOverrideProvider: placeholderAttributeOverrideProvider)
            replaceLinkPlaceholderAttributes(in: mutableStylizedText, placeholderAttributeOverrideProvider: placeholderAttributeOverrideProvider)
            replaceCustomPlaceholderAttributes(in: mutableStylizedText, customAttributesProvider: customAttributesProvider, placeholderAttributeOverrideProvider: placeholderAttributeOverrideProvider)

            stylizedText = NSAttributedString(attributedString: mutableStylizedText)
        }

        return stylizedText
    }

    internal func insertingBaseFont(_ font: StylizerNativeFont) -> NSAttributedString {
        let mutableAttributedText = NSMutableAttributedString(string: string, attributes: [.font: font])
        self.enumerateAttributes(in: stringRange, options: []) { attributes, range, _ in
            if !attributes.isEmpty {
                mutableAttributedText.addAttributes(attributes, range: range)
            }
        }

        return NSAttributedString(attributedString: mutableAttributedText)
    }

    // MARK: Private Methods

    private func replaceFontPlaceholderAttribute(_ attribute: NSAttributedString.Key, in stylizedText: NSMutableAttributedString, with traits: StylizerNativeFontDescriptor.SymbolicTraits, defaultFont: StylizerNativeFont?, placeholderAttributeOverrideProvider: StylizerPlaceholderAttributeOverrideProvider?) {
        stylizedText.enumerateAttributes(in: stylizedText.stringRange, options: []) { attributes, range, _ in
            guard let value = attributes[attribute] else { return }

            stylizedText.removeAttribute(attribute, range: range)

            var proposedAttributes: [NSAttributedString.Key: Any] = [:]
            if let font = attributes[.font] as? StylizerNativeFont {
                proposedAttributes = [.font: font.byAddingSymbolicTraits(traits) ?? font]
            } else if let defaultFont = defaultFont {
                proposedAttributes = [.font: defaultFont.byAddingSymbolicTraits(traits) ?? defaultFont]
            }

            if let placeholderAttributeOverrideProvider = placeholderAttributeOverrideProvider,
               let replacementAttributes = placeholderAttributeOverrideProvider(attribute, value, range, proposedAttributes) {
                proposedAttributes = replacementAttributes
            }

            stylizedText.addAttributes(proposedAttributes, range: range)
        }
    }

    private func replaceNumberPlaceholderAttribute(_ attribute: NSAttributedString.Key, in stylizedText: NSMutableAttributedString, with newAttribute: (key: NSAttributedString.Key, value: NSNumber)?, placeholderAttributeOverrideProvider: StylizerPlaceholderAttributeOverrideProvider?) {
        stylizedText.enumerateAttributes(in: stylizedText.stringRange, options: []) { attributes, range, _ in
            guard let value = attributes[attribute] else { return }

            stylizedText.removeAttribute(attribute, range: range)

            var proposedAttributes: [NSAttributedString.Key: Any] = [:]
            if let newAttribute = newAttribute {
                proposedAttributes = [newAttribute.key: newAttribute.value]
            }

            if let placeholderAttributeOverrideProvider = placeholderAttributeOverrideProvider,
               let replacementAttributes = placeholderAttributeOverrideProvider(attribute, value, range, proposedAttributes) {
                proposedAttributes = replacementAttributes
            }

            stylizedText.addAttributes(proposedAttributes, range: range)
        }
    }

    private func replaceColorPlaceholderAttribute(_ attribute: NSAttributedString.Key, in stylizedText: NSMutableAttributedString, with newAttribute: NSAttributedString.Key, placeholderAttributeOverrideProvider: StylizerPlaceholderAttributeOverrideProvider?) {
        stylizedText.enumerateAttributes(in: stylizedText.stringRange, options: []) { attributes, range, _ in
            guard let value = attributes[attribute] else { return }

            stylizedText.removeAttribute(attribute, range: range)

            var proposedAttributes: [NSAttributedString.Key: Any] = [:]
            if let color = value as? StylizerNativeColor {
                proposedAttributes = [newAttribute: color]
            }

            if let placeholderAttributeOverrideProvider = placeholderAttributeOverrideProvider,
               let replacementAttributes = placeholderAttributeOverrideProvider(attribute, value, range, proposedAttributes) {
                proposedAttributes = replacementAttributes
            }

            stylizedText.addAttributes(proposedAttributes, range: range)
        }
    }

    private func replaceLinkPlaceholderAttributes(in stylizedText: NSMutableAttributedString, placeholderAttributeOverrideProvider: StylizerPlaceholderAttributeOverrideProvider?) {
        stylizedText.enumerateAttributes(in: stylizedText.stringRange, options: []) { attributes, range, _ in
            guard let value = attributes[.stylizerLink] else { return }

            stylizedText.removeAttribute(.stylizerLink, range: range)

            var proposedAttributes: [NSAttributedString.Key: Any] = [:]
            if let linkStrings = value as? [String], !linkStrings.isEmpty {
                if let url = URL(string: linkStrings[0]) {
                    proposedAttributes[.link] = url
                } else {
                    proposedAttributes[.link] = linkStrings[0]
                }

                #if canImport(AppKit) && !targetEnvironment(macCatalyst)
                if linkStrings.count >= 2 {
                    proposedAttributes[.toolTip] = linkStrings[1]
                }
                #endif // #if canImport(AppKit) && !targetEnvironment(macCatalyst)
            }

            if let placeholderAttributeOverrideProvider = placeholderAttributeOverrideProvider,
               let replacementAttributes = placeholderAttributeOverrideProvider(.stylizerLink, value, range, proposedAttributes) {
                proposedAttributes = replacementAttributes
            }

            stylizedText.addAttributes(proposedAttributes, range: range)
        }
    }

    private func replaceCustomPlaceholderAttributes(in stylizedText: NSMutableAttributedString, customAttributesProvider: StylizerCustomAttributesProvider?, placeholderAttributeOverrideProvider: StylizerPlaceholderAttributeOverrideProvider?) {
        guard customAttributesProvider != nil || placeholderAttributeOverrideProvider != nil else { return }

        for attribute in NSAttributedString.Key.customStylizerPlaceholderAttributes {
            stylizedText.enumerateAttributes(in: stylizedText.stringRange, options: []) { attributes, range, _ in
                guard let value = attributes[attribute] else { return }

                stylizedText.removeAttribute(attribute, range: range)

                var proposedAttributes: [NSAttributedString.Key: Any] = customAttributesProvider?(attribute, value, range) ?? [:]
                if let placeholderAttributeOverrideProvider = placeholderAttributeOverrideProvider,
                   let replacementAttributes = placeholderAttributeOverrideProvider(attribute, value, range, proposedAttributes) {
                    proposedAttributes = replacementAttributes
                }

                stylizedText.addAttributes(proposedAttributes, range: range)
            }
        }
    }
}
#endif // #if canImport(UIKit) || canImport(AppKit)
