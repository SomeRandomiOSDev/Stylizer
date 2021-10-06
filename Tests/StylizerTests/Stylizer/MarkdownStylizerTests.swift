//
//  MarkdownStylizerTests.swift
//  StylizerTests
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

import Stylizer
import XCTest

//swiftlint:disable function_body_length

// MARK: - MarkdownStylizerTests Definition

class MarkdownStylizerTests: StylizerTestCase {

    // MARK: Private Properties

    static let allStyles = allCombinations(of: MarkdownStylizer.Style.allCases)

    // MARK: Test Methods

    func testCopyMarkdownStylizer() throws {
        for styles in MarkdownStylizerTests.allStyles {
            let stylizer = MarkdownStylizer(styles: styles)
            let copy = try XCTUnwrap(stylizer.copy() as? MarkdownStylizer)

            XCTAssertFalse(stylizer === copy)
            XCTAssertEqual(stylizer.styles, copy.styles)
            XCTAssertEqual(stylizer.styleInfo.count, copy.styleInfo.count)

            for i in 0 ..< stylizer.styleInfo.count {
                XCTAssertFalse(stylizer.styleInfo[i] === copy.styleInfo[i])
                XCTAssertEqual(stylizer.styleInfo[i].expression, copy.styleInfo[i].expression)
                XCTAssertEqual(stylizer.styleInfo[i].replacementTemplate, copy.styleInfo[i].replacementTemplate)
                XCTAssertEqual(stylizer.styleInfo[i].matchingOptions, copy.styleInfo[i].matchingOptions)
            }
        }
    }

    func testAllMarkdownStylePermutations() {
        for styles in MarkdownStylizerTests.allStyles {
            let stylizers = MarkdownStylizerTests.stylizers(for: styles)

            MarkdownStylizerTests.iterateAllPermutations(for: styles) { finalText, permutations in
                for stylizer in stylizers {
                    for text in permutations {
                        let attributedText = stylizer.attributedStringByReplacingMatches(in: text)
                        XCTAssertEqual(finalText, attributedText.string)

                        if styles.contains(.bold) {
                            guard let boldRange = attributedText.string.range(of: "bold").map({ NSRange($0, in: attributedText.string) }) else {
                                XCTFail("Unable to find range of string \"bold\" in \"\(attributedText.string)\"")
                                continue
                            }

                            var range = NSRange(location: 0, length: 0)
                            let attribute = attributedText.attribute(MarkdownStylizer.Style.bold.attributeKey, at: boldRange.location, effectiveRange: &range)

                            XCTAssertEqual(boldRange, range)
                            XCTAssertNotNil(attribute)

                            if boldRange.lowerBound > 0 {
                                for i in 0 ..< boldRange.lowerBound {
                                    XCTAssertNil(attributedText.attribute(MarkdownStylizer.Style.bold.attributeKey, at: i, effectiveRange: &range), "Expected not to find bold attributes outside of the perscribed range { \(boldRange.lowerBound), \(boldRange.upperBound) }")
                                }
                            }
                            if boldRange.upperBound < attributedText.length - 1 {
                                for i in boldRange.upperBound ..< attributedText.length {
                                    XCTAssertNil(attributedText.attribute(MarkdownStylizer.Style.bold.attributeKey, at: i, effectiveRange: &range), "Expected not to find bold attributes outside of the perscribed range { \(boldRange.lowerBound), \(boldRange.upperBound) }")
                                }
                            }
                        } else {
                            for i in 0 ..< attributedText.length {
                                XCTAssertNil(attributedText.attribute(MarkdownStylizer.Style.bold.attributeKey, at: i, effectiveRange: nil))
                            }
                        }

                        if styles.contains(.italics) {
                            guard let italicRange = attributedText.string.range(of: "italics").map({ NSRange($0, in: attributedText.string) }) else {
                                XCTFail("Unable to find range of string \"italics\" in \"\(attributedText.string)\"")
                                continue
                            }

                            var range = NSRange(location: 0, length: 0)
                            let attribute = attributedText.attribute(MarkdownStylizer.Style.italics.attributeKey, at: italicRange.location, effectiveRange: &range)

                            XCTAssertEqual(italicRange, range)
                            XCTAssertNotNil(attribute)

                            if italicRange.lowerBound > 0 {
                                for i in 0 ..< italicRange.lowerBound {
                                    XCTAssertNil(attributedText.attribute(MarkdownStylizer.Style.italics.attributeKey, at: i, effectiveRange: &range), "Expected not to find italics attributes outside of the perscribed range { \(italicRange.lowerBound), \(italicRange.upperBound) }")
                                }
                            }
                            if italicRange.upperBound < attributedText.length - 1 {
                                for i in italicRange.upperBound ..< attributedText.length {
                                    XCTAssertNil(attributedText.attribute(MarkdownStylizer.Style.italics.attributeKey, at: i, effectiveRange: &range), "Expected not to find italics attributes outside of the perscribed range { \(italicRange.lowerBound), \(italicRange.upperBound) }")
                                }
                            }
                        } else {
                            for i in 0 ..< attributedText.length {
                                XCTAssertNil(attributedText.attribute(MarkdownStylizer.Style.italics.attributeKey, at: i, effectiveRange: nil))
                            }
                        }

                        if styles.contains(.strikethrough) {
                            guard let strikethroughRange = attributedText.string.range(of: "strikethrough").map({ NSRange($0, in: attributedText.string) }) else {
                                XCTFail("Unable to find range of string \"strikethrough\" in \"\(attributedText.string)\"")
                                continue
                            }

                            var range = NSRange(location: 0, length: 0)
                            let attribute = attributedText.attribute(MarkdownStylizer.Style.strikethrough.attributeKey, at: strikethroughRange.location, effectiveRange: &range)

                            XCTAssertEqual(strikethroughRange, range)
                            XCTAssertNotNil(attribute)

                            if strikethroughRange.lowerBound > 0 {
                                for i in 0 ..< strikethroughRange.lowerBound {
                                    XCTAssertNil(attributedText.attribute(MarkdownStylizer.Style.strikethrough.attributeKey, at: i, effectiveRange: &range), "Expected not to find strikethrough attributes outside of the perscribed range { \(strikethroughRange.lowerBound), \(strikethroughRange.upperBound) }")
                                }
                            }
                            if strikethroughRange.upperBound < attributedText.length - 1 {
                                for i in strikethroughRange.upperBound ..< attributedText.length {
                                    XCTAssertNil(attributedText.attribute(MarkdownStylizer.Style.strikethrough.attributeKey, at: i, effectiveRange: &range), "Expected not to find strikethrough attributes outside of the perscribed range { \(strikethroughRange.lowerBound), \(strikethroughRange.upperBound) }")
                                }
                            }
                        } else {
                            for i in 0 ..< attributedText.length {
                                XCTAssertNil(attributedText.attribute(MarkdownStylizer.Style.strikethrough.attributeKey, at: i, effectiveRange: nil))
                            }
                        }

                        if styles.contains(.link) {
                            guard let linkRange = attributedText.string.range(of: "link").map({ NSRange($0, in: attributedText.string) }) else {
                                XCTFail("Unable to find range of string \"link\" in \"\(attributedText.string)\"")
                                continue
                            }

                            var range = NSRange(location: 0, length: 0)
                            let attribute = attributedText.attribute(MarkdownStylizer.Style.link.attributeKey, at: linkRange.location, effectiveRange: &range)

                            XCTAssertEqual(linkRange, range)
                            XCTAssertNotNil(attribute as? [String])

                            if (attribute as? [String])?.count == 1 {
                                XCTAssertEqual((attribute as? [String])?[0], "https://link.com")
                            } else if (attribute as? [String])?.count == 2 {
                                XCTAssertEqual((attribute as? [String])?[0], "https://link.com")
                                XCTAssertEqual((attribute as? [String])?[1], "optional")
                            } else {
                                XCTFail("Expected link attribute to contain either 1 or 2 elements")
                            }

                            if linkRange.lowerBound > 0 {
                                for i in 0 ..< linkRange.lowerBound {
                                    XCTAssertNil(attributedText.attribute(MarkdownStylizer.Style.link.attributeKey, at: i, effectiveRange: &range), "Expected not to find link attributes outside of the perscribed range { \(linkRange.lowerBound), \(linkRange.upperBound) }")
                                }
                            }
                            if linkRange.upperBound < attributedText.length - 1 {
                                for i in linkRange.upperBound ..< attributedText.length {
                                    XCTAssertNil(attributedText.attribute(MarkdownStylizer.Style.link.attributeKey, at: i, effectiveRange: &range), "Expected not to find link attributes outside of the perscribed range { \(linkRange.lowerBound), \(linkRange.upperBound) }")
                                }
                            }
                        } else {
                            for i in 0 ..< attributedText.length {
                                XCTAssertNil(attributedText.attribute(MarkdownStylizer.Style.link.attributeKey, at: i, effectiveRange: nil))
                            }
                        }
                    }
                }
            }
        }
    }

    //

    func testAllNestedMarkdownStyles() {
        for styles in MarkdownStylizerTests.allStyles {
            let stylizers = MarkdownStylizerTests.stylizers(for: styles)

            MarkdownStylizerTests.iterateAllNestedPermutations(for: styles) { finalText, permutations in
                for stylizer in stylizers {
                    for text in permutations {
                        let attributedText = stylizer.attributedStringByReplacingMatches(in: text)
                        XCTAssertEqual(finalText, attributedText.string)

                        for component in finalText.components(separatedBy: ", ") {
                            guard var range = finalText.range(of: component).map({ NSRange($0, in: finalText) }) else {
                                XCTFail("Unexpected issue while processing attributes for \"\(component)\" in \"\(finalText)\"")
                                continue
                            }

                            range = NSRange(location: range.location, length: finalText.count - range.location)

                            switch component {
                            case "bold" where styles.contains(.bold):
                                AssertAttributedString(attributedText, containsAttribute: .stylizerBold, inRange: range)
                                AssertAttributedString(attributedText, doesNotContainAttribute: .stylizerBold, inRange: NSRange(location: 0, length: range.lowerBound))

                            case "italics" where styles.contains(.italics):
                                AssertAttributedString(attributedText, containsAttribute: .stylizerItalics, inRange: range)
                                AssertAttributedString(attributedText, doesNotContainAttribute: .stylizerItalics, inRange: NSRange(location: 0, length: range.lowerBound))

                            case "strikethrough" where styles.contains(.strikethrough):
                                AssertAttributedString(attributedText, containsAttribute: .stylizerStrikethrough, inRange: range)
                                AssertAttributedString(attributedText, doesNotContainAttribute: .stylizerStrikethrough, inRange: NSRange(location: 0, length: range.lowerBound))

                            case "link" where styles.contains(.link):
                                AssertAttributedString(attributedText, containsAttribute: (.stylizerLink, ["https://link.com"], ["https://link.com", "optional"]), inRange: range)
                                AssertAttributedString(attributedText, doesNotContainAttribute: .stylizerLink, inRange: NSRange(location: 0, length: range.lowerBound))

                            default:
                                XCTFail("Unexpected issue while processing attributes for \"\(component)\" in \"\(finalText)\"")
                            }
                        }
                    }
                }
            }
        }
    }

    //

    func testVerifyBoldItalicsAndStrikethroughPatterns() {
        func randomLetter() -> String {
            let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            return String(letters.shuffled()[0])
        }
        let styleAttributes: [NSAttributedString.Key] = [
            .stylizerBold, .stylizerBold,
            .stylizerItalics, .stylizerItalics,
            .stylizerStrikethrough
        ]

        for replaceEscapedControlCharacters in [false, true] {
            let stylizer = MarkdownStylizer(styles: MarkdownStylizer.Style.allCases, options: replaceEscapedControlCharacters ? [.processEscapedControlCharacters] : [])
            let escape = replaceEscapedControlCharacters ? "" : "\\"
            let offset = replaceEscapedControlCharacters ? 1 : 2

            for (i, controlCharacter) in ["**", "__", "*", "_", "~~"].enumerated() {
                let text = UUID().uuidString.replacingOccurrences(of: "-", with: "")
                let string = "\(controlCharacter)\(text)\(controlCharacter)"
                let char = "\(controlCharacter[controlCharacter.startIndex])"

                let stylizedString = stylizer.attributedStringByReplacingMatches(in: string)
                XCTAssertEqual(stylizedString.string, text, "Control Character: \"\(controlCharacter)\"")

                var range = NSRange(location: 0, length: 0)
                let attributes = stylizedString.attributes(at: 0, effectiveRange: &range)

                XCTAssertEqual(attributes.count, 1, "Control Character: \"\(controlCharacter)\"")
                XCTAssertNotNil(attributes[styleAttributes[i]], "Control Character: \"\(controlCharacter)\"")
                XCTAssertEqual(range, NSRange(location: 0, length: stylizedString.length), "Control Character: \"\(controlCharacter)\"")

                //

                do { // Extra control character at the beginning (e.g. ***text**)
                    let testString = "\(char)\(string)"
                    XCTAssertEqual(stylizer.attributedStringByReplacingMatches(in: testString).string, testString, "Control Character: \"\(controlCharacter)\"") // no matches
                }

                do { // Extra control character at the end (e.g. **text***)
                    let testString = "\(string)\(char)"
                    XCTAssertEqual(stylizer.attributedStringByReplacingMatches(in: testString).string, testString, "Control Character: \"\(controlCharacter)\"") // no matches
                }

                if controlCharacter.count != 1 { // Extra control character at the beginning and end (e.g. ***text***)
                    let testString = "\(char)\(string)\(char)"
                    XCTAssertEqual(stylizer.attributedStringByReplacingMatches(in: testString).string, testString, "Control Character: \"\(controlCharacter)\"") // no matches
                }

                do { // Extra control character at the beginning preceeded by a random character (e.g. a***text**)
                    let testString = "\(randomLetter())\(char)\(string)"
                    XCTAssertEqual(stylizer.attributedStringByReplacingMatches(in: testString).string, testString, "Control Character: \"\(controlCharacter)\"") // no matches
                }

                //

                do { // Escaped control character at the beginning (e.g. \***text**)
                    let testString = "\\\(char)\(string)"
                    let stylizedString = stylizer.attributedStringByReplacingMatches(in: testString)

                    XCTAssertEqual(stylizedString.string, "\(escape)\(char)\(text)", "Control Character: \"\(controlCharacter)\"")

                    var attributes = stylizedString.attributes(at: 0, effectiveRange: &range)

                    XCTAssertTrue(attributes.isEmpty, "Control Character: \"\(controlCharacter)\"")
                    XCTAssertEqual(range, NSRange(location: 0, length: offset), "Control Character: \"\(controlCharacter)\"")

                    attributes = stylizedString.attributes(at: offset, effectiveRange: &range)

                    XCTAssertEqual(attributes.count, 1, "Control Character: \"\(controlCharacter)\"")
                    XCTAssertNotNil(attributes[styleAttributes[i]], "Control Character: \"\(controlCharacter)\"")
                    XCTAssertEqual(range, NSRange(location: offset, length: stylizedString.length - offset), "Control Character: \"\(controlCharacter)\"")
                }

                do { // Escaped control character at the end (e.g. **text**\*)
                    let testString = "\(string)\\\(char)"
                    let stylizedString = stylizer.attributedStringByReplacingMatches(in: testString)

                    XCTAssertEqual(stylizedString.string, "\(text)\(escape)\(char)", "Control Character: \"\(controlCharacter)\"")

                    var attributes = stylizedString.attributes(at: 0, effectiveRange: &range)

                    XCTAssertEqual(attributes.count, 1, "Control Character: \"\(controlCharacter)\"")
                    XCTAssertNotNil(attributes[styleAttributes[i]], "Control Character: \"\(controlCharacter)\"")
                    XCTAssertEqual(range, NSRange(location: 0, length: stylizedString.length - offset), "Control Character: \"\(controlCharacter)\"")

                    attributes = stylizedString.attributes(at: stylizedString.length - offset, effectiveRange: &range)

                    XCTAssertTrue(attributes.isEmpty, "Control Character: \"\(controlCharacter)\"")
                    XCTAssertEqual(range, NSRange(location: stylizedString.length - offset, length: offset), "Control Character: \"\(controlCharacter)\"")
                }

                do { // Escaped control character inside the match at the beginning (e.g. **\*text**)
                    let testString = "\(controlCharacter)\\\(char)\(text)\(controlCharacter)"
                    let stylizedString = stylizer.attributedStringByReplacingMatches(in: testString)

                    XCTAssertEqual(stylizedString.string, "\(escape)\(char)\(text)", "Control Character: \"\(controlCharacter)\"")

                    let attributes = stylizedString.attributes(at: 0, effectiveRange: &range)

                    XCTAssertEqual(attributes.count, 1, "Control Character: \"\(controlCharacter)\"")
                    XCTAssertNotNil(attributes[styleAttributes[i]], "Control Character: \"\(controlCharacter)\"")
                    XCTAssertEqual(range, NSRange(location: 0, length: stylizedString.length), "Control Character: \"\(controlCharacter)\"")
                }

                do { // Escaped control character inside the match at the end (e.g. **text\***)
                    let testString = "\(controlCharacter)\(text)\\\(char)\(controlCharacter)"
                    let stylizedString = stylizer.attributedStringByReplacingMatches(in: testString)

                    XCTAssertEqual(stylizedString.string, "\(text)\(escape)\(char)", "Control Character: \"\(controlCharacter)\"")

                    let attributes = stylizedString.attributes(at: 0, effectiveRange: &range)

                    XCTAssertEqual(attributes.count, 1, "Control Character: \"\(controlCharacter)\"")
                    XCTAssertNotNil(attributes[styleAttributes[i]], "Control Character: \"\(controlCharacter)\"")
                    XCTAssertEqual(range, NSRange(location: 0, length: stylizedString.length), "Control Character: \"\(controlCharacter)\"")
                }

                do { // Escaped control character at the beginning and end (outside) (e.g. \***text**\*)
                    let testString = "\\\(char)\(string)\\\(char)"
                    let stylizedString = stylizer.attributedStringByReplacingMatches(in: testString)

                    XCTAssertEqual(stylizedString.string, "\(escape)\(char)\(text)\(escape)\(char)", "Control Character: \"\(controlCharacter)\"")

                    var attributes = stylizedString.attributes(at: 0, effectiveRange: &range)

                    XCTAssertTrue(attributes.isEmpty, "Control Character: \"\(controlCharacter)\"")
                    XCTAssertEqual(range, NSRange(location: 0, length: offset), "Control Character: \"\(controlCharacter)\"")

                    attributes = stylizedString.attributes(at: offset, effectiveRange: &range)

                    XCTAssertEqual(attributes.count, 1, "Control Character: \"\(controlCharacter)\"")
                    XCTAssertNotNil(attributes[styleAttributes[i]], "Control Character: \"\(controlCharacter)\"")
                    XCTAssertEqual(range, NSRange(location: offset, length: stylizedString.length - (2 * offset)), "Control Character: \"\(controlCharacter)\"")

                    attributes = stylizedString.attributes(at: stylizedString.length - offset, effectiveRange: &range)

                    XCTAssertTrue(attributes.isEmpty, "Control Character: \"\(controlCharacter)\"")
                    XCTAssertEqual(range, NSRange(location: stylizedString.length - offset, length: offset), "Control Character: \"\(controlCharacter)\"")
                }

                do { // Escaped control character at the beginning and end (in->out) (e.g. **\*text**\*)
                    let testString = "\(controlCharacter)\\\(char)\(text)\(controlCharacter)\\\(char)"
                    let stylizedString = stylizer.attributedStringByReplacingMatches(in: testString)

                    XCTAssertEqual(stylizedString.string, "\(escape)\(char)\(text)\(escape)\(char)", "Control Character: \"\(controlCharacter)\"")

                    var attributes = stylizedString.attributes(at: 0, effectiveRange: &range)

                    XCTAssertEqual(attributes.count, 1, "Control Character: \"\(controlCharacter)\"")
                    XCTAssertNotNil(attributes[styleAttributes[i]], "Control Character: \"\(controlCharacter)\"")
                    XCTAssertEqual(range, NSRange(location: 0, length: stylizedString.length - offset), "Control Character: \"\(controlCharacter)\"")

                    attributes = stylizedString.attributes(at: stylizedString.length - offset, effectiveRange: &range)

                    XCTAssertTrue(attributes.isEmpty, "Control Character: \"\(controlCharacter)\"")
                    XCTAssertEqual(range, NSRange(location: stylizedString.length - offset, length: offset), "Control Character: \"\(controlCharacter)\"")
                }

                do { // Escaped control character at the beginning and end (out->in) (e.g. \***text\***)
                    let testString = "\\\(char)\(controlCharacter)\(text)\\\(char)\(controlCharacter)"
                    let stylizedString = stylizer.attributedStringByReplacingMatches(in: testString)

                    XCTAssertEqual(stylizedString.string, "\(escape)\(char)\(text)\(escape)\(char)", "Control Character: \"\(controlCharacter)\"")

                    var attributes = stylizedString.attributes(at: 0, effectiveRange: &range)

                    XCTAssertTrue(attributes.isEmpty, "Control Character: \"\(controlCharacter)\"")
                    XCTAssertEqual(range, NSRange(location: 0, length: offset), "Control Character: \"\(controlCharacter)\"")

                    attributes = stylizedString.attributes(at: offset, effectiveRange: &range)

                    XCTAssertEqual(attributes.count, 1, "Control Character: \"\(controlCharacter)\"")
                    XCTAssertNotNil(attributes[styleAttributes[i]], "Control Character: \"\(controlCharacter)\"")
                    XCTAssertEqual(range, NSRange(location: offset, length: stylizedString.length - offset), "Control Character: \"\(controlCharacter)\"")
                }

                do { // Escaped control character at the beginning and end (inside) (e.g. **\*text\***)
                    let testString = "\(controlCharacter)\\\(char)\(text)\\\(char)\(controlCharacter)"
                    let stylizedString = stylizer.attributedStringByReplacingMatches(in: testString)

                    XCTAssertEqual(stylizedString.string, "\(escape)\(char)\(text)\(escape)\(char)", "Control Character: \"\(controlCharacter)\"")

                    let attributes = stylizedString.attributes(at: 0, effectiveRange: &range)

                    XCTAssertEqual(attributes.count, 1, "Control Character: \"\(controlCharacter)\"")
                    XCTAssertNotNil(attributes[styleAttributes[i]], "Control Character: \"\(controlCharacter)\"")
                    XCTAssertEqual(range, NSRange(location: 0, length: stylizedString.length), "Control Character: \"\(controlCharacter)\"")
                }
            }
        }
    }

    //

    func testParsingEscapedControlCharacters() {
        let unstylizedString = "**This is an asterisk: \\*, **_this is an underline: \\_,_ ~~and this is a tilde: \\~.~~ Lastly, these are Markdown control characters for links: [\\[, \\], \\(, \\)](https://guides.github.com/features/mastering-markdown)"
        var stylizedString = MarkdownStylizer().attributedStringByReplacingMatches(in: unstylizedString)

        XCTAssertEqual(stylizedString.string, "This is an asterisk: *, this is an underline: _, and this is a tilde: ~. Lastly, these are Markdown control characters for links: [, ], (, )")

        var range = NSRange(location: 0, length: 0)
        var attributes = stylizedString.attributes(at: 0, effectiveRange: &range)

        XCTAssertEqual(range, NSRange(location: 0, length: 24))
        XCTAssertEqual(attributes.count, 1)
        XCTAssertNotNil(attributes[.stylizerBold])

        attributes = stylizedString.attributes(at: 24, effectiveRange: &range)

        XCTAssertEqual(range, NSRange(location: 24, length: 24))
        XCTAssertEqual(attributes.count, 1)
        XCTAssertNotNil(attributes[.stylizerItalics])

        attributes = stylizedString.attributes(at: 49, effectiveRange: &range)

        XCTAssertEqual(range, NSRange(location: 49, length: 23))
        XCTAssertEqual(attributes.count, 1)
        XCTAssertNotNil(attributes[.stylizerStrikethrough])

        attributes = stylizedString.attributes(at: 130, effectiveRange: &range)

        XCTAssertEqual(range, NSRange(location: 130, length: 10))
        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(attributes[.stylizerLink] as? [String], ["https://guides.github.com/features/mastering-markdown"])

        //

        stylizedString = MarkdownStylizer(styles: MarkdownStylizer.Style.allCases, options: []).attributedStringByReplacingMatches(in: unstylizedString)

        XCTAssertEqual(stylizedString.string, "This is an asterisk: \\*, this is an underline: \\_, and this is a tilde: \\~. Lastly, these are Markdown control characters for links: \\[, \\], \\(, \\)")

        attributes = stylizedString.attributes(at: 0, effectiveRange: &range)

        XCTAssertEqual(range, NSRange(location: 0, length: 25))
        XCTAssertEqual(attributes.count, 1)
        XCTAssertNotNil(attributes[.stylizerBold])

        attributes = stylizedString.attributes(at: 25, effectiveRange: &range)

        XCTAssertEqual(range, NSRange(location: 25, length: 25))
        XCTAssertEqual(attributes.count, 1)
        XCTAssertNotNil(attributes[.stylizerItalics])

        attributes = stylizedString.attributes(at: 51, effectiveRange: &range)

        XCTAssertEqual(range, NSRange(location: 51, length: 24))
        XCTAssertEqual(attributes.count, 1)
        XCTAssertNotNil(attributes[.stylizerStrikethrough])

        attributes = stylizedString.attributes(at: 133, effectiveRange: &range)

        XCTAssertEqual(range, NSRange(location: 133, length: 14))
        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(attributes[.stylizerLink] as? [String], ["https://guides.github.com/features/mastering-markdown"])
    }

    // MARK: Private Methods

    private class func stylizers(for styles: [MarkdownStylizer.Style]) -> [MarkdownStylizer] {
        var stylizers: [MarkdownStylizer] = [MarkdownStylizer(styles: styles)]

        if styles.count == MarkdownStylizer.Style.allCases.count {
            stylizers.append(MarkdownStylizer())
        }
        if styles.count == 1 {
            stylizers.append(MarkdownStylizer(style: styles[0]))
        }

        return stylizers
    }
}
