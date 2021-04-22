//
//  Stylizer.swift
//  Stylizer
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

import Foundation

// MARK: - Stylizer Definition

/// An object used for "stylizing" strings, that is, pattern matching to
/// automatically parse out and add attributes to strings and `NSAttributedString`
/// instances
@objc open class Stylizer: NSObject, NSCopying {

    // MARK: Public Properties

    /// An array of `StyleInfo` objects that specify the style patterns to search for,
    /// how to replace matches, and the attributes to add.
    @objc open private(set) var styleInfo: [StyleInfo]

    // MARK: Initialization

    /**
     Creates a new `Stylizer` using the supplied parameters

     - parameters:
       - styleInfo: The styles to use for styling strings

     - returns: The newly instantiated `Stylizer` object
     */
    @objc public init(styleInfo: [StyleInfo]) {
        self.styleInfo = styleInfo.compactMap { $0.copy() as? StyleInfo }
        super.init()
    }

    // MARK: Public Methods

    /**
     Replaces all style patterns described by the `Stylizer`'s `styleInfo` property
     with their repective text replacements and attributes.

     - parameters:
       - string: The string to stylize

     - returns: An `NSAttributedString` object created by replacing all style
                patterns with their respective replacement strings and attributes
     */
    @objc(attributedStringByReplacingMatchesInString:)
    open func attributedStringByReplacingMatches(in string: String) -> NSAttributedString {
        return attributedStringByReplacingMatches(in: NSAttributedString(string: string))
    }

    /**
     Replaces all style patterns within the given range described by the `Stylizer`'s
     `styleInfo` property with their repective text replacements and attributes.

     - parameters:
       - string: The string to stylize
       - range: The range in which to search for style patterns

     - returns: An `NSAttributedString` object created by replacing all style
                patterns with their respective replacement strings and attributes
     */
    @objc(attributedStringByReplacingMatchesInString:range:)
    open func attributedStringByReplacingMatches(in string: String, range: NSRange) -> NSAttributedString {
        return attributedStringByReplacingMatches(in: NSAttributedString(string: string), range: range)
    }

    //

    /**
     Replaces all style patterns described by the `Stylizer`'s `styleInfo` property
     with their repective text replacements and attributes.

     - parameters:
       - attributedString: The string to stylize

     - returns: An `NSAttributedString` object created by replacing all style
                patterns with their respective replacement strings and attributes.
     */
    @objc(attributedStringByReplacingMatchesInAttributedString:)
    open func attributedStringByReplacingMatches(in attributedString: NSAttributedString) -> NSAttributedString {
        return attributedStringByReplacingMatches(in: attributedString, range: NSRange(location: 0, length: .max))
    }

    /**
     Replaces all style patterns within the given range described by the `Stylizer`'s
     `styleInfo` property with their repective text replacements and attributes.

     - parameters:
       - attributedString: The string to stylize
       - range: The range in which to search for style patterns

     - returns: An `NSAttributedString` object created by replacing all style
                patterns with their respective replacement strings and attributes
     */
    @objc(attributedStringByReplacingMatchesInAttributedString:range:)
    open func attributedStringByReplacingMatches(in attributedString: NSAttributedString, range: NSRange) -> NSAttributedString {
        guard range.location >= 0 && range.location < attributedString.length && range.length > 0 else { return attributedString }

        let substrings = AttributedSubstrings(attributedString: attributedString, range: range)
        let attributedString = NSMutableAttributedString(attributedString: substrings.string)

        func process(_ match: NSTextCheckingResult, with styleInfo: StyleInfo) {
            let replacement = NSMutableAttributedString(string: styleInfo.expression.replacementString(for: match, in: attributedString.string, offset: 0, template: styleInfo.replacementTemplate))
            if let attributes = styleInfo.attributesProvider?(match, attributedString.string), !attributes.isEmpty {
                replacement.addAttributes(attributes, range: replacement.stringRange)
            }

            if let searchRange = Range(match.range, in: attributedString.string),
               let rangeOfReplacement = attributedString.string.range(of: replacement.string, options: [], range: searchRange).map({ NSRange($0, in: attributedString.string) }) {
                attributedString.enumerateAttributes(in: rangeOfReplacement, options: []) { attributes, attributesRange, _ in
                    if !attributes.isEmpty {
                        replacement.addAttributes(attributes, range: NSRange(location: attributesRange.location - rangeOfReplacement.location, length: attributesRange.length))
                    }
                }
            } else {
                attributedString.enumerateAttributes(in: match.range, options: []) { attributes, _, _ in
                    if !attributes.isEmpty {
                        replacement.addAttributes(attributes, range: replacement.stringRange)
                    }
                }
            }

            attributedString.replaceCharacters(in: match.range, with: replacement)
        }

        var allMatches: [(styleInfo: StyleInfo, match: NSTextCheckingResult)] = []
        let sync = DispatchQueue(label: "com.stylizer.\(String(describing: type(of: self)).lowercased()).sync")
        let styleInfo = self.styleInfo

        repeat {
            allMatches = []
            let string = attributedString.string
            let range = attributedString.stringRange

            DispatchQueue.concurrentPerform(iterations: styleInfo.count) { i in
                let styleInfo = styleInfo[i]
                let matches = styleInfo.expression.matches(in: string, options: styleInfo.matchingOptions, range: range)

                if !matches.isEmpty {
                    sync.sync { allMatches.append(contentsOf: matches.map { (styleInfo, $0) }) }
                }
            }

            if !allMatches.isEmpty {
                allMatches.sort { $0.match.range.location > $1.match.range.location }

                process(allMatches[0].match, with: allMatches[0].styleInfo)
            }
        } while !allMatches.isEmpty

        return substrings.composedString(with: attributedString)
    }

    // MARK: NSCopying Protocol Requirements

    public func copy(with zone: NSZone? = nil) -> Any {
        return Stylizer(styleInfo: styleInfo)
    }
}

// MARK: - AttributedSubstrings Definition

private struct AttributedSubstrings {

    // MARK: Properties

    private let prefix: NSAttributedString?
    private let suffix: NSAttributedString?

    let string: NSAttributedString

    // MARK: Initialization

    init(attributedString: NSAttributedString, range: NSRange) {
        if range.lowerBound == 0 && range.upperBound >= attributedString.length {
            string = attributedString
            prefix = nil
            suffix = nil
        } else {
            if range.lowerBound > 0 {
                prefix = attributedString.attributedSubstring(from: NSRange(location: 0, length: range.lowerBound))
            } else {
                prefix = nil
            }

            string = attributedString.attributedSubstring(from: range)

            if range.upperBound < attributedString.length {
                suffix = attributedString.attributedSubstring(from: NSRange(location: range.upperBound, length: attributedString.length - range.upperBound))
            } else {
                suffix = nil
            }
        }
    }

    // MARK: Methods

    func composedString(with newString: NSAttributedString) -> NSAttributedString {
        guard prefix != nil || suffix != nil else { return newString }
        let result = NSMutableAttributedString(attributedString: newString)

        if let prefix = prefix {
            result.insert(prefix, at: 0)
        }
        if let suffix = suffix {
            result.append(suffix)
        }

        return NSAttributedString(attributedString: result)
    }
}
