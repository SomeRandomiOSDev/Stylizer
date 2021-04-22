//
//  StyleInfo.swift
//  Stylizer
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

import Foundation

// MARK: - StyleInfo Definition

/// An object used to represent a set pattern to match with its replacement and
/// string attributes
@objc public final class StyleInfo: NSObject, NSCopying {

    // MARK: Public Properties

    /// The expression used for style patterns
    @objc public let expression: NSRegularExpression

    /// The template used to replace text using the accompanying expression
    @objc public let replacementTemplate: String

    /// The options used when matching strings using the accompanying expression
    @objc public let matchingOptions: NSRegularExpression.MatchingOptions

    /// The closure used for providing attributes for matches
    @objc public let attributesProvider: ((NSTextCheckingResult, String) -> [NSAttributedString.Key: Any])?

    // MARK: Initialization

    /**
     Creates a new expression using the supplied pattern(s) and options

     - parameters:
       - expression: The expression used for style pattern matching
       - replacementTemplate: The replacement template for use for matched patterns
       - matchingOptions: The options to use when matching with `expression`
       - attributesProvider: The closure to use for providing attributes for style
                             patterns

     - returns: The newly instantied `StyleInfo` object
     */
    @objc public init(expression: NSRegularExpression, replacementTemplate: String, matchingOptions: NSRegularExpression.MatchingOptions = [], attributesProvider: ((NSTextCheckingResult, String) -> [NSAttributedString.Key: Any])? = nil) {
        //swiftlint:disable force_cast
        self.expression = expression.copy() as! NSRegularExpression
        //swiftlint:enable force_cast
        self.replacementTemplate = replacementTemplate
        self.matchingOptions = matchingOptions
        self.attributesProvider = attributesProvider
    }

    // MARK: NSObject Overrides

    override public func isEqual(_ object: Any?) -> Bool {
        guard let info = object as? StyleInfo else { return false }
        guard self !== info else { return true }

        return expression == info.expression &&
               replacementTemplate == info.replacementTemplate &&
               matchingOptions == info.matchingOptions
    }

    override public var hash: Int {
        var hasher = Hasher()

        hasher.combine(expression.hash)
        hasher.combine(replacementTemplate)
        hasher.combine(matchingOptions.rawValue)

        return hasher.finalize()
    }

    // MARK: NSCopying Protocol Requirements

    public func copy(with zone: NSZone? = nil) -> Any {
        return StyleInfo(expression: expression, replacementTemplate: replacementTemplate, matchingOptions: matchingOptions, attributesProvider: attributesProvider)
    }
}
