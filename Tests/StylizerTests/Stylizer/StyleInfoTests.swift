//
//  StyleInfoTests.swift
//  StylizerTests
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

@testable import Stylizer
import XCTest

// MARK: - StyleInfoTests Definition

class StyleInfoTests: StylizerTestCase {

    // MARK: Test Methods

    func testStyleInfoInitialization() throws {
        try StyleInfoTests.iterateAllExpressionPermutations { pattern, options, matchingOptions in
            let expression = try NSRegularExpression(pattern: pattern, options: options)
            let styleInfo = StyleInfo(expression: expression, replacementTemplate: "$0", matchingOptions: matchingOptions) { _, _ in [NSAttributedString.Key(rawValue: "key"): "value"] }

            XCTAssertEqual(styleInfo.expression, expression)
            XCTAssertEqual(styleInfo.replacementTemplate, "$0")
            XCTAssertEqual(styleInfo.matchingOptions, matchingOptions)
        }
    }

    func testStyleInfoCopy() throws {
        try StyleInfoTests.iterateAllExpressionPermutations { pattern, options, matchingOptions in
            let styleInfo = try StyleInfo(expression: .init(pattern: pattern, options: options), replacementTemplate: "$0", matchingOptions: matchingOptions) { _, _ in [NSAttributedString.Key(rawValue: "key"): "value"] }
            let copy = try XCTUnwrap(styleInfo.copy() as? StyleInfo)

            XCTAssertFalse(copy === styleInfo)
            XCTAssertEqual(copy.expression, styleInfo.expression)
            XCTAssertEqual(copy.replacementTemplate, styleInfo.replacementTemplate)
            XCTAssertEqual(copy.matchingOptions, styleInfo.matchingOptions)
        }
    }

    func testStyleInfoEquality() throws {
        try StyleInfoTests.iterateAllExpressionPermutations { pattern, options, matchingOptions in
            let expression = try NSRegularExpression(pattern: pattern, options: options)
            let lhs = StyleInfo(expression: expression, replacementTemplate: "$0", matchingOptions: matchingOptions) { _, _ in [NSAttributedString.Key(rawValue: "key"): "value"] }
            let rhs = StyleInfo(expression: expression, replacementTemplate: "$0", matchingOptions: matchingOptions) { _, _ in [NSAttributedString.Key(rawValue: "key"): "value"] }

            XCTAssertFalse(lhs === rhs)
            XCTAssertTrue(lhs == rhs)
            XCTAssertTrue(rhs == lhs)

            XCTAssertTrue(lhs.isEqual(lhs))
            XCTAssertTrue(lhs.isEqual(rhs))
            XCTAssertTrue(rhs.isEqual(lhs))
            XCTAssertTrue(rhs.isEqual(rhs))

            // -isEqual: returning `true` implies that their hash values are also equivalent
            XCTAssertEqual(lhs.hash, rhs.hash)
            XCTAssertEqual(rhs.hash, lhs.hash)
            XCTAssertEqual(lhs.hashValue, rhs.hashValue)
            XCTAssertEqual(rhs.hashValue, lhs.hashValue)

            XCTAssertFalse(lhs.isEqual(NSObject()))
            XCTAssertFalse(rhs.isEqual(NSObject()))
        }
    }

    // MARK: Private Methods

    private class func iterateAllExpressionPermutations(using block: (String, NSRegularExpression.Options, NSRegularExpression.MatchingOptions) throws -> Void) rethrows {
        let allMatchingOptions = allCombinations(of: [NSRegularExpression.MatchingOptions.reportProgress, .reportCompletion, .anchored, .withTransparentBounds, .withoutAnchoringBounds])
        try iterateAllExpressionPermutations { pattern, options in
            for matchingOptions in allMatchingOptions {
                try block(pattern, options, matchingOptions.reduce(into: []) { $0.insert($1) })
            }
        }
    }

    private class func iterateAllExpressionPermutations(using block: (String, NSRegularExpression.Options) throws -> Void) rethrows {
        let pattern = "<b>.*?<\\/b>"
        let allOptions = allCombinations(of: [NSRegularExpression.Options.caseInsensitive, .allowCommentsAndWhitespace, .ignoreMetacharacters, .dotMatchesLineSeparators, .anchorsMatchLines, .useUnixLineSeparators, .useUnicodeWordBoundaries])

        for options in allOptions {
            try block(pattern, options.reduce(into: []) { $0.insert($1) })
        }
    }
}
