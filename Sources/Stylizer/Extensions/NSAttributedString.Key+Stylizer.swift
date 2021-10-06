//
//  NSAttributedString.Key+Stylizer.swift
//  Stylizer
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

//swiftlint:disable function_body_length

// MARK: - NSAttributedString.Key Definition

extension NSAttributedString.Key {

    // MARK: Internal Properties

    internal private(set) static var customStylizerPlaceholderAttributes: Set<NSAttributedString.Key> = []
    internal static let predefinedStylizerPlaceholderAttributes: [NSAttributedString.Key] = [.stylizerBold, .stylizerItalics, .stylizerStrikethrough, .stylizerUnderline, .stylizerSuperscript, .stylizerTextColor, .stylizerBackgroundColor, .stylizerLink, .stylizerWritingDirection]

    // MARK: Public Constants

    /// Bold placeholder attribute. This is used to signify that the text that this
    /// attribute applies to should be rendered as bold. This attribute is substituted
    /// with the `.font` UIKit/AppKit attribute with the appropriate bolded font for the
    /// text.
    public static let stylizerBold = NSAttributedString.Key(rawValue: "com.stylizer.bold")

    /// Italic placeholder attribute. This is used to signify that the text that this
    /// attribute applies to should be rendered as italic. This attribute is substituted
    /// with the `.font` UIKit/AppKit attribute with the appropriate italicized font for
    /// the text.
    public static let stylizerItalics = NSAttributedString.Key(rawValue: "com.stylizer.italics")

    /// Strikethrough placeholder attribute. This is used to signify that the text that
    /// this attribute applies to should be rendered with a strikethrough. This
    /// attribute is substituted with the `.strikethroughStyle` UIKit/AppKit attribute
    /// with a value of `NSUnderlineStyle.single`
    public static let stylizerStrikethrough = NSAttributedString.Key(rawValue: "com.stylizer.strikethrough")

    /// Underline placeholder attribute. This is used to signify that the text that this
    /// attribute applies to should be rendered with an underline. This attribute is
    /// substituted with the `.underlineStyle` UIKit/AppKit attribute with a value of
    /// `NSUnderlineStyle.single`
    public static let stylizerUnderline = NSAttributedString.Key(rawValue: "com.stylizer.underline")

    /// Superscript placeholder attribute. This is used to signify that the text that
    /// this attribute applies to should be rendered with as a superscript. On macOS,
    /// this attribute is substituted with the `.superscript` AppKit attribute with a
    /// value of `1`. As the other platforms don't have an equivalent UIKit attribute,
    /// this placeholder is simply removed prior to rendering for the other platforms
    /// (including Mac Catalyst)
    public static let stylizerSuperscript = NSAttributedString.Key(rawValue: "com.stylizer.superscript")

    /// Text Color placeholder attribute. This is used to signify that the text that
    /// this attribute applies to should be rendered with the specified color. This
    /// attribute is substituted with the `.foregroundColor` UIKit/AppKit attribute with
    /// a value of the parsed `UIColor`/`NSColor` instance
    public static let stylizerTextColor = NSAttributedString.Key(rawValue: "com.stylizer.textcolor")

    /// Background Color placeholder attribute. This is used to signify that the text
    /// that this attribute applies to should be rendered with a background of the
    /// specified color. This attribute is substituted with the `.backgroundColor`
    /// UIKit/AppKit attribute with a value of the parsed `UIColor`/`NSColor` instance
    public static let stylizerBackgroundColor = NSAttributedString.Key(rawValue: "com.stylizer.backgroundcolor")

    /// Link placeholder attribute. This is used to signify that the text that this
    /// attribute applies contains a specified link. This attribute is substituted with
    /// the `.link` UIKit/AppKit attribute with a value of the parsed `URL` instance, or
    /// `String` if the parsed string not directly convertible to a `URL`. Additionally
    /// on macOS if the parsed link contains an optional title, this is added as an
    /// additional attribute using the AppKit `.toolTip` attribute
    public static let stylizerLink = NSAttributedString.Key(rawValue: "com.stylizer.link")

    /// Writing direction placeholder attribute. This is used to signify that the text
    /// that this attribute applies should use the specified writing direction. This
    /// attribute is substituted with the `.writingDirection` UIKit attribute with the
    /// value of the parsed writing direction, or'ed with `NSWritingDirectionEmbedding`.
    /// As this attribute is not available on macOS this placeholder is simply removed
    /// prior to rendering.
    public static let stylizerWritingDirection = NSAttributedString.Key(rawValue: "com.stylizer.writingdirection")

    // MARK: Public Methods

    /**
     Registers custom placeholder attributes to be parsed out by
     `NSAttributedString.stylize(with:defaultFont:customAttributesProvider:)`

     - parameters:
       - attributes: The custom placeholder attributes to register with the stylizer
                     engine

     When creating custom stylizers one can either provide the UIKit/AppKit
     compatible attributes directly in the attributes provider that the use for the
     custom stylizer's `StyleInfo` instances, or you use placeholders as
     `HTMLStylizer` and `MarkdownStylizer` do.

     If your stylizer uses placeholders but the appropriate placeholder doesn't exist
     you can create a custom placeholder and register it with this method.
     Registering it allows notifies the
     `NSAttributedString.stylize(with:defaultFont:customAttributesProvider:)` method
     to search for it and replace it using the `customAttributesProvider` supplied to
     that method. If you don't register your custom placeholders then the method will
     simply ignore and won't process them.
     */
    public static func registerCustomStylizerPlaceholderAttributes<S>(_ attributes: S) where S: Sequence, S.Element == NSAttributedString.Key {
        let attributes = Set(attributes)
        guard !attributes.isEmpty else { return }

        validateCustomAttributes(attributes)
        customStylizerPlaceholderAttributes.formUnion(attributes)
    }

    // MARK: Private Methods

    private static func validateCustomAttributes(_ attributes: Set<NSAttributedString.Key>) {
        var sdkDefinedAttributes: [NSAttributedString.Key] = [
            .attachment, .backgroundColor, .baselineOffset,
            .expansion, .font, .foregroundColor,
            .kern, .ligature, .link,
            .obliqueness, .paragraphStyle, .shadow,
            .strikethroughColor, .strikethroughStyle, .strokeColor,
            .strokeWidth, .textEffect, .underlineColor,
            .underlineStyle, .verticalGlyphForm
        ]

        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            sdkDefinedAttributes.append(.tracking)
        }

        #if canImport(UIKit)
        sdkDefinedAttributes.append(contentsOf: [
            .writingDirection, .accessibilitySpeechLanguage,
            .accessibilitySpeechPitch, .accessibilitySpeechPunctuation
        ])

        if #available(iOS 11.0, tvOS 11.0, watchOS 4.0, *) {
            sdkDefinedAttributes.append(contentsOf: [
                .accessibilitySpeechQueueAnnouncement, .accessibilitySpeechIPANotation,
                .accessibilityTextHeadingLevel, .accessibilityTextCustom
            ])

            if #available(iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
                sdkDefinedAttributes.append(contentsOf: [.accessibilitySpeechSpellOut, .UIAccessibilityTextAttributeContext])
            }
        }
        #elseif canImport(AppKit)
        sdkDefinedAttributes.append(contentsOf: [
            .cursor, .glyphInfo, .markedClauseSegment,
            .spellingState, .superscript, .textAlternatives,
            .toolTip,

            .accessibilityAttachment, .accessibilityAutocorrected, .accessibilityBackgroundColor,
            .accessibilityFont, .accessibilityForegroundColor, .accessibilityLink,
            .accessibilityMarkedMisspelled, .accessibilityShadow, .accessibilityStrikethrough,
            .accessibilityStrikethroughColor, .accessibilitySuperscript, .accessibilityUnderline,
            .accessibilityUnderlineColor
        ])

        if #available(macOS 10.11, *) {
            sdkDefinedAttributes.append(contentsOf: [
                .writingDirection, .accessibilityListItemIndex,
                .accessibilityListItemLevel, .accessibilityListItemPrefix
            ])

            if #available(macOS 10.12, *) {
                sdkDefinedAttributes.append(.accessibilityAlignment)

                if #available(macOS 10.13, *) {
                    sdkDefinedAttributes.append(contentsOf: [.accessibilityAnnotationTextAttribute, .accessibilityCustomText, .accessibilityLanguage])
                }
            }
        }

        // Deprecated
        sdkDefinedAttributes.append(contentsOf: [.characterShapeAttributeName, .usesScreenFontsDocumentAttribute])
        #endif

        precondition(attributes.isDisjoint(with: predefinedStylizerPlaceholderAttributes), "Cannot register the predefined stylizer placeholder attributes as custom placeholder attributes")
        precondition(attributes.isDisjoint(with: sdkDefinedAttributes), "Cannot register the UIKit/AppKit predefined attributes as custom placeholder attributes")
    }
}
