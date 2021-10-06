//
//  HTMLStylizer.swift
//  Stylizer
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

import Foundation

// MARK: - HTMLStylizer Definition

/**
 A `Stylizer` subclass for matching HTML style patterns for `bold`, `italic`,
 `strikethrough`, `underline`, and `superscript` text as well as
 `background/foreground color` and `link`s.

 For ensuring that attributes don't get overwritten between the time that they're
 parsed from the string and when they're rendered, `HTMLStylizer` uses
 placeholder attributes in lieu of the standard UIKit/AppKit attributes. Since
 these placeholders don't mean anything UIKit/AppKit they have to be convered to
 attributes recognized by these frameworks. To replace these placeholder
 attributes use either `StylizerLabel` which handles this automatically or by
 using the `NSAttributedString.stylize(with:defaultFont:customAttributesProvider:)`
 method.
 */
@objc open class HTMLStylizer: Stylizer {

    // MARK: Private Constants

    private static let characterEntitiesStylizer = Stylizer(styleInfo: [
        .init(expression: NSRegularExpression(verifiedPattern: "&lt;"), replacementTemplate: "<"),
        .init(expression: NSRegularExpression(verifiedPattern: "&gt;"), replacementTemplate: ">"),
        .init(expression: NSRegularExpression(verifiedPattern: "&amp;"), replacementTemplate: "&")
    ])

    // MARK: Public Properties

    /// The HTML styles this object is setup to search for
    open private(set) var styles: [Style]

    /// The options to use when stylizing strings. Defaults to
    /// `.processCharacterEntities`. Options are applied after stylizing
    open var options: Options

    // MARK: Initialization

    /**
     Creates a new `HTMLStylizer` setup for matching any/all of the supplied HTML
     styles

     - parameters:
       - styles: The HTML styles to search for

     - returns: The newly instantiated `HTMLStylizer` object
     */
    public init(styles: [Style], options: Options = .processCharacterEntities) {
        let styles = styles.makeUnique()
        self.styles = styles
        self.options = options

        let styleInfo: [StyleInfo] = styles.reduce(into: []) { result, style in
            let replacementTemplate = style.replacementTemplate
            for expression in style.expressions {
                result.append(StyleInfo(expression: expression, replacementTemplate: replacementTemplate) { HTMLStylizer.attributes(for: $0, in: $1, style: style) })
            }
        }

        super.init(styleInfo: styleInfo)
    }

    /**
     Creates a new `HTMLStylizer` setup for matching the supplied HTML style

     - parameters:
       - style: The HTML style to search for

     - returns: The newly instantiated `HTMLStylizer` object
     */
    @objc public convenience init(style: Style) {
        self.init(styles: [style])
    }

    /**
     Creates a new `HTMLStylizer` setup for matching all of the defined HTML styles

     - returns: The newly instantiated `HTMLStylizer` object
     */
    @objc public convenience init() {
        self.init(styles: Style.allCases)
    }

    // MARK: NSCopying Protocol Requirements

    override public func copy(with zone: NSZone? = nil) -> Any {
        return HTMLStylizer(styles: styles, options: options)
    }

    // MARK: Stylizer Overrides

    @objc(attributedStringByReplacingMatchesInAttributedString:range:)
    override open func attributedStringByReplacingMatches(in attributedString: NSAttributedString, range: NSRange) -> NSAttributedString {
        var stylizedString = super.attributedStringByReplacingMatches(in: attributedString, range: range)

        if options.contains(.processCharacterEntities) {
            stylizedString = HTMLStylizer.characterEntitiesStylizer.attributedStringByReplacingMatches(in: stylizedString)
        }

        return stylizedString
    }

    // MARK: Private Methods

    private class func attributes(for match: NSTextCheckingResult, in string: String, style: Style) -> [NSAttributedString.Key: Any] {
        let attributes: [NSAttributedString.Key: Any]
        switch style {
        case .bold, .italics, .strikethrough,
             .underline, .superscript:
            attributes = [style.attributeKey: 0]

        case .textColor, .backgroundColor:
            if let colorString = Range(match.range(at: 1), in: string).map({ String(string[$0]) }) {
                if let color = ColorParser.parseColor(from: colorString) {
                    attributes = [style.attributeKey: color]
                } else {
                    attributes = [style.attributeKey: colorString]
                }
            } else {
                attributes = [style.attributeKey: 0]
            }

        case .writingDirection:
            if let writingDirectionString = Range(match.range(at: 1), in: string).map({ string[$0] }) {
                attributes = [style.attributeKey: writingDirectionString]
            } else {
                attributes = [style.attributeKey: 0]
            }

        case .link:
            var values: [String] = []
            if let link = Range(match.range(at: 1), in: string).map({ String(string[$0]) }) {
                values.append(link)

                if let title = Range(match.range(at: 2), in: string).map({ String(string[$0]) }) {
                    values.append(title)
                }
            }

            attributes = [style.attributeKey: values]
        }

        return attributes
    }
}

// MARK: - HTMLStylizer.Style Definition

extension HTMLStylizer {

    /// An enumeration that lists out all of the HTML styles that can be used by
    /// `HTMLStylizer`
    @objc(HTMLStylizerStyle)
    public enum Style: Int, CaseIterable {

        // MARK: Cases

        /**
         Bold HTML style

         In text, the bold HTML style can be represented by enclosing text within a pair
         of `<b>` tags or a pair of `<strong` tags:

         ```<b>this is bold text</b>, <strong>and this is bold text too</strong>```
         */
        case bold = 1 // $1 is the bolded text

        /**
         Italic HTML style

         In text, the italic HTML style can be represented by enclosing text within a
         pair of `<i>` tag or a pair of `<em>` tags:

         ```<i>this is italic text</i>, <em>and this is italic text too</em>```
         */
        case italics = 2 // $1 is the italicized text

        /**
         Strikethrough HTML style

         In text, the strikethrough HTML style can be represented by enclosing text
         within a pair of `<del>` tags:

         ```<del>this text has a strikethrough</del>```
         */
        case strikethrough = 3 // $1 is the struckthrough text

        /**
         Underline HTML style

         In text, the underline HTML style can be represented by enclosing text within a
         pair of `<ins>` tags:

         ```<ins>this text is underlined</ins>```
         */
        case underline = 4 // $1 is the underlined text

        /**
         Superscript HTML style

         In text, the superscript HTML style can be represented by enclosing text within a
         pair of `<sup>` tags:

         ```<sup>this text is in a superscript</sup>```
         */
        case superscript = 5 // $1 is the superscript text

        /**
         Text Color HTML style

         In text, the text color HTML style can be represented by enclosing text within a
         pair of `<p>` tags with a `style:color` attribute:

         ```<p style="color:crimson;">this text is colored crimson</p>```

         The specified color can be any one of the well-named HTML colors, an HTML hex
         color code (e.g. `#2554C7`), the rgb/rgba color function (e.g.
         `rgba(255, 99, 71, 0.25)`) or the hsl/hsla color function (e.g.
         `hsla(9, 85%, 32%, 0.5)`)
         */
        case textColor = 6 // $1 is the color, $2 is the colored text

        /**
         Background Color HTML style

         In text, the background color HTML style can be represented by enclosing text within a
         pair of `<p>` tags with a `style:background-color` attribute:

         ```<p style="background-color:blue;">this text has a blue background</p>```

         The specified color can be any one of the well-named HTML colors, an HTML hex
         color code (e.g. `#2554C7`), the rgb/rgba color function (e.g.
         `rgba(255, 99, 71, 0.25)`) or the hsl/hsla color function (e.g.
         `hsla(9, 85%, 32%, 0.5)`)
         */
        case backgroundColor = 7 // $1 is the color, $2 is the text

        /**
         Link HTML style

         In text, the link HTML style is represented by placing the link text within a pair `<a>` tags with a `href` attribute:

         ```<a href="https://link.com">link</a>```

         Additionally, an optional title can be used by adding a `title` attribute:

         ```<a href="https://link.com" title="title">link</a>```
         */
        case link = 8 // $1 is the link, $2 is the optional link title, and $3 is the link text

        /**
         Writing Direction HTML style

         In text, the writing direction HTML style is represented by placing text within a pair `<p>` tags with a `dir` attribute:

         ```<p dir="rtl">Right-to-left text</p>```

         Only the `ltr` and `rtl` values are currently supported.
         */
        case writingDirection = 9 // $1 is the writing direction, $2 is the text

        // MARK: Public Properties

        /// The placeholder attribute inserted by `HTMLStylizer` for the respective style
        public var attributeKey: NSAttributedString.Key {
            let attributeKey: NSAttributedString.Key
            switch self {
            case .bold:             attributeKey = .stylizerBold
            case .italics:          attributeKey = .stylizerItalics
            case .strikethrough:    attributeKey = .stylizerStrikethrough
            case .underline:        attributeKey = .stylizerUnderline
            case .superscript:      attributeKey = .stylizerSuperscript
            case .textColor:        attributeKey = .stylizerTextColor
            case .backgroundColor:  attributeKey = .stylizerBackgroundColor
            case .link:             attributeKey = .stylizerLink
            case .writingDirection: attributeKey = .stylizerWritingDirection
            }

            return attributeKey
        }

        // MARK: Private Properties

        // Future Style Attributes:
        // cursor, font, font-family, font-size, font-stretch, font-style, font-variant, font-weight, line-height, letter-spacing, text-align, text-decoration, text-decoration-color, text-decoration-line, text-decoration-style, text-decoration-thickness, text-shadow, text-transform, writing-mode

        fileprivate var expressions: [NSRegularExpression] {
            let options: NSRegularExpression.Options = .dotMatchesLineSeparators
            let expressions: [NSRegularExpression]

            switch self {
            case .bold:             expressions = [.init(verifiedPattern: "<b>(.*?)<\\/b>", options: options),
                                                   .init(verifiedPattern: "<strong>(.*?)<\\/strong>", options: options)]
            case .italics:          expressions = [.init(verifiedPattern: "<i>(.*?)<\\/i>", options: options),
                                                   .init(verifiedPattern: "<em>(.*?)<\\/em>", options: options)]
            case .strikethrough:    expressions = [.init(verifiedPattern: "<del>(.*?)<\\/del>", options: options)]
            case .underline:        expressions = [.init(verifiedPattern: "<ins>(.*?)<\\/ins>", options: options)]
            case .superscript:      expressions = [.init(verifiedPattern: "<sup>(.*?)<\\/sup>", options: options)]
            case .textColor:        expressions = [.init(verifiedPattern: "<p\\s+style=\"color:([^;]*);\">(.*?)<\\/p>", options: options)]
            case .backgroundColor:  expressions = [.init(verifiedPattern: "<p\\s+style=\"background-color:([^;]*);\">(.*?)<\\/p>", options: options)]
            case .link:             expressions = [.init(verifiedPattern: "<a\\s+href=\"([^\"]*)\"(?:\\s+title=\"([^\"]*)\")?>(.*?)<\\/a>", options: options)]
            case .writingDirection: expressions = [.init(verifiedPattern: "<p\\s+dir=\"([^\"]+)\">(.*?)<\\/p>", options: options)]
            }

            return expressions
        }

        fileprivate var replacementTemplate: String {
            let replacementTemplate: String
            switch self {
            case .bold, .italics, .strikethrough,
                 .underline, .superscript:        replacementTemplate = "$1"
            case .textColor, .backgroundColor,
                 .writingDirection:               replacementTemplate = "$2"
            case .link:                           replacementTemplate = "$3"
            }

            return replacementTemplate
        }
    }
}

// MARK: - HTMLStylizer.Options Definition

extension HTMLStylizer {

    /// Options to use when stylizing strings with `HTMLStylizer`
    public struct Options: OptionSet {

        // MARK: RawRepresentable Protocol Requirements

        public let rawValue: UInt

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        // MARK: Public Constants

        /// When this option is set, `HTMLStylizer` will search for an replace for the
        /// following HTML Character Entities: '`&lt;`', '`&gt;`', and '`&amp;`'
        public static let processCharacterEntities = Options(rawValue: 1 << 0)
    }
}
