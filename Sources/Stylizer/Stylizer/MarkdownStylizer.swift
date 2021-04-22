//
//  MarkdownStylizer.swift
//  Stylizer
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

import Foundation

// MARK: - MarkdownStylizer Definition

/**
 A `Stylizer` subclass for matching Markdown style patterns for `bold`, `italic`,
 and `strikethrough` text as well as `link`s.

 For ensuring that attributes don't get overwritten between the time that they're
 parsed from the string and when they're rendered, `MarkdownStylizer` uses
 placeholder attributes in lieu of the standard UIKit/AppKit attributes. Since
 these placeholders don't mean anything UIKit/AppKit they have to be convered to
 attributes recognized by these frameworks. To replace these placeholder
 attributes use either `StylizerLabel` which handles this automatically or by
 using the `NSAttributedString.stylize(with:defaultFont:customAttributesProvider:)`
 method.
 */
@objc open class MarkdownStylizer: Stylizer {

    // MARK: Private Constants

    private static let escapedControlCharactersStylizer = Stylizer(styleInfo: [
        .init(expression: NSRegularExpression(verifiedPattern: "\\\\([*_~\\[\\]()])"), replacementTemplate: "$1")
    ])

    // MARK: Public Properties

    /// The Markdown styles this object is setup to search for
    open private(set) var styles: [Style]

    /// The options to use when stylizing strings. Defaults to
    /// `.processEscapedControlCharacters`. Options are applied after stylizing
    open var options: Options

    // MARK: Initialization

    /**
     Creates a new `MarkdownStylizer` setup for matching any/all of the supplied
     Markdown styles

     - parameters:
       - styles: The Markdown styles to search for

     - returns: The newly instantiated `MarkdownStylizer` object
     */
    public init(styles: [Style], options: Options = .processEscapedControlCharacters) {
        let styles = styles.makeUnique()
        self.styles = styles
        self.options = options

        let styleInfo = styles.reduce(into: []) { result, style in
            style.expressions.forEach { expression in
                result.append(StyleInfo(expression: expression, replacementTemplate: "$1") { MarkdownStylizer.attributes(for: $0, in: $1, style: style) })
            }
        }

        super.init(styleInfo: styleInfo)
    }

    /**
     Creates a new `MarkdownStylizer` setup for matching the supplied Markdown style

     - parameters:
       - style: The Markdown style to search for

     - returns: The newly instantiated `MarkdownStylizer` object
     */
    @objc public convenience init(style: Style) {
        self.init(styles: [style])
    }

    /**
     Creates a new `MarkdownStylizer` setup for matching all of the defined Markdown
     styles

     - returns: The newly instantiated `MarkdownStylizer` object
     */
    @objc public convenience init() {
        self.init(styles: Style.allCases)
    }

    // MARK: NSCopying Protocol Requirements

    override public func copy(with zone: NSZone? = nil) -> Any {
        return MarkdownStylizer(styles: styles)
    }

    // MARK: Stylizer Overrides

    @objc(attributedStringByReplacingMatchesInAttributedString:range:)
    override open func attributedStringByReplacingMatches(in attributedString: NSAttributedString, range: NSRange) -> NSAttributedString {
        var stylizedString = super.attributedStringByReplacingMatches(in: attributedString, range: range)

        if options.contains(.processEscapedControlCharacters) {
            stylizedString = MarkdownStylizer.escapedControlCharactersStylizer.attributedStringByReplacingMatches(in: stylizedString)
        }

        return stylizedString
    }

    // MARK: Private Methods

    private class func attributes(for match: NSTextCheckingResult, in string: String, style: Style) -> [NSAttributedString.Key: Any] {
        let attributes: [NSAttributedString.Key: Any]
        switch style {
        case .bold, .italics, .strikethrough:
            attributes = [style.attributeKey: 0]

        case .link:
            var values: [String] = []
            if let link = Range(match.range(at: 2), in: string).map({ String(string[$0]) }) {
                values.append(link)

                if let title = match.numberOfRanges > 3 ? Range(match.range(at: 3), in: string).map({ String(string[$0]) }) : nil {
                    values.append(title)
                }
            }

            attributes = [style.attributeKey: values]
        }

        return attributes
    }
}

// MARK: - MarkdownStylizer.Style Definition

extension MarkdownStylizer {

    /// An enumeration that lists out all of the Markdown styles that can be used by
    /// `MarkdownStylizer`
    @objc(MarkdownStylizerStyle)
    public enum Style: Int, CaseIterable {

        // MARK: Cases

        /**
         Bold Markdown style

         In text, the bold Markdown style can be represented by enclosing text within a
         pair of double asterisks or a pair of double underlines:

         ```**this is bold text**, __and this is bold text too__```
         */
        case bold = 1 // $1 is the bolded text

        /**
         Italic Markdown style

         In text, the italic Markdown style can be represented by enclosing text within a
         pair of single asterisks or a pair of single underlines:

         ```*this is italic text*, _and this is italic text too_```
         */
        case italics = 2 // $1 is the italicized text

        /**
         Strikethrough Markdown style

         In text, the strikethrough Markdown style can be represented by enclosing text
         within a pair of double tildes:

         ```~~this text has a strikethrough~~```
         */
        case strikethrough = 3 // $1 is the struckthrough text

        /**
         Link Markdown style

         In text, the link Markdown style is represented by placing the link text within a pair of brackets, which is immediately followed by the link text surrounded by a pair of parentheses:

         ```[link](https://link.com)```

         Additionally, an optional title can be placed immediately after the link in quotes:

         ```[link](https://link.com "title")```
         */
        case link = 4 // $1 is the link text, $2 is the link, and $3 is the optional link title

        // MARK: Public Properties

        /// The placeholder attribute inserted by `MarkdownStylizer` for the respective
        /// style
        public var attributeKey: NSAttributedString.Key {
            let attributeKey: NSAttributedString.Key
            switch self {
            case .bold:          attributeKey = .stylizerBold
            case .italics:       attributeKey = .stylizerItalics
            case .strikethrough: attributeKey = .stylizerStrikethrough
            case .link:          attributeKey = .stylizerLink
            }

            return attributeKey
        }

        // MARK: Private Properties

        fileprivate var expressions: [NSRegularExpression] {
            let options: NSRegularExpression.Options = [.dotMatchesLineSeparators]
            let expressions: [NSRegularExpression]

            switch self {
            case .bold:          expressions = [.init(verifiedPattern: "(?<!\\\\)(?<!^\\*)(?<![^\\\\]\\*)\\*\\*(?!\\*)(.+?)(?<!\\\\)(?<![^\\\\]\\*)\\*\\*(?!\\*)", options: options),
                                                .init(verifiedPattern: "(?<!\\\\)(?<!^_)(?<![^\\\\]_)__(?!_)(.+?)(?<!\\\\)(?<![^\\\\]_)__(?!_)", options: options)]
            case .italics:       expressions = [.init(verifiedPattern: "(?<!\\\\)(?<!^\\*)(?<![^\\\\]\\*)\\*(?!\\*)(.+?)(?<!\\\\)(?<![^\\\\]\\*)\\*(?!\\*)", options: options),
                                                .init(verifiedPattern: "(?<!\\\\)(?<!^_)(?<![^\\\\]_)_(?!_)(.+?)(?<!\\\\)(?<![^\\\\]_)_(?!_)", options: options)]
            case .strikethrough: expressions = [.init(verifiedPattern: "(?<!\\\\)(?<!^~)(?<![^\\\\]~)~~(?!~)(.+?)(?<!\\\\)(?<![^\\\\]~)~~(?!~)", options: options)]
            case .link:          expressions = [.init(verifiedPattern: "(?<!\\\\)\\[(.+?)(?<!\\\\)\\]\\(([^) ]+)(?:[ ]+\"(.*?)(?<!\\\\)\")?\\)", options: options)]
            }

            return expressions
        }
    }
}

// MARK: - MarkdownStylizer.Options Definition

extension MarkdownStylizer {

    /// Options to use when stylizing strings with `MarkdownStylizer`
    public struct Options: OptionSet {

        // MARK: RawRepresentable Protocol Requirements

        public let rawValue: UInt

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        // MARK: Public Constants

        /// When this option is set, `MarkdownStylizer` will search for an replace for
        /// escaped control characters: `\*`, `\_`, `\~`, `\[`, `\]`, `\(`, and `\)`
        public static let processEscapedControlCharacters = Options(rawValue: 1 << 0)
    }
}
