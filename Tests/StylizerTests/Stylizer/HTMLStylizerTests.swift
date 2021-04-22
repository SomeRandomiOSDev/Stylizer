//
//  HTMLStylizerTests.swift
//  Stylizer
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

#if !os(watchOS)
@testable import Stylizer
import XCTest

//swiftlint:disable function_body_length type_body_length file_length

// MARK: - HTMLStylizerTests Definition

class HTMLStylizerTests: StylizerTestCase {

    // MARK: Private Properties

    static let allStyles = allCombinations(of: HTMLStylizer.Style.allCases)

    // MARK: Test Methods

    func testCopyHTMLStylizer() throws {
        for styles in HTMLStylizerTests.allStyles {
            let stylizer = HTMLStylizer(styles: styles)
            let copy = try XCTUnwrap(stylizer.copy() as? HTMLStylizer)

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

    func testAllHTMLStylePermutations() {
        for styles in HTMLStylizerTests.allStyles {
            let stylizers = HTMLStylizerTests.stylizers(for: styles)

            HTMLStylizerTests.iterateAllPermutations(for: styles) { finalText, permutations in
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
                            let attribute = attributedText.attribute(HTMLStylizer.Style.bold.attributeKey, at: boldRange.location, effectiveRange: &range)

                            XCTAssertEqual(boldRange, range)
                            XCTAssertNotNil(attribute)

                            if boldRange.lowerBound > 0 {
                                for i in 0 ..< boldRange.lowerBound {
                                    XCTAssertNil(attributedText.attribute(HTMLStylizer.Style.bold.attributeKey, at: i, effectiveRange: &range), "Expected not to find bold attributes outside of the perscribed range { \(boldRange.lowerBound), \(boldRange.upperBound) }")
                                }
                            }
                            if boldRange.upperBound < attributedText.length - 1 {
                                for i in boldRange.upperBound ..< attributedText.length {
                                    XCTAssertNil(attributedText.attribute(HTMLStylizer.Style.bold.attributeKey, at: i, effectiveRange: &range), "Expected not to find bold attributes outside of the perscribed range { \(boldRange.lowerBound), \(boldRange.upperBound) }")
                                }
                            }
                        } else {
                            for i in 0 ..< attributedText.length {
                                XCTAssertNil(attributedText.attribute(HTMLStylizer.Style.bold.attributeKey, at: i, effectiveRange: nil))
                            }
                        }

                        if styles.contains(.italics) {
                            guard let italicRange = attributedText.string.range(of: "italics").map({ NSRange($0, in: attributedText.string) }) else {
                                XCTFail("Unable to find range of string \"italics\" in \"\(attributedText.string)\"")
                                continue
                            }

                            var range = NSRange(location: 0, length: 0)
                            let attribute = attributedText.attribute(HTMLStylizer.Style.italics.attributeKey, at: italicRange.location, effectiveRange: &range)

                            XCTAssertEqual(italicRange, range)
                            XCTAssertNotNil(attribute)

                            if italicRange.lowerBound > 0 {
                                for i in 0 ..< italicRange.lowerBound {
                                    XCTAssertNil(attributedText.attribute(HTMLStylizer.Style.italics.attributeKey, at: i, effectiveRange: &range), "Expected not to find italics attributes outside of the perscribed range { \(italicRange.lowerBound), \(italicRange.upperBound) }")
                                }
                            }
                            if italicRange.upperBound < attributedText.length - 1 {
                                for i in italicRange.upperBound ..< attributedText.length {
                                    XCTAssertNil(attributedText.attribute(HTMLStylizer.Style.italics.attributeKey, at: i, effectiveRange: &range), "Expected not to find italics attributes outside of the perscribed range { \(italicRange.lowerBound), \(italicRange.upperBound) }")
                                }
                            }
                        } else {
                            for i in 0 ..< attributedText.length {
                                XCTAssertNil(attributedText.attribute(HTMLStylizer.Style.italics.attributeKey, at: i, effectiveRange: nil))
                            }
                        }

                        if styles.contains(.strikethrough) {
                            guard let strikethroughRange = attributedText.string.range(of: "strikethrough").map({ NSRange($0, in: attributedText.string) }) else {
                                XCTFail("Unable to find range of string \"strikethrough\" in \"\(attributedText.string)\"")
                                continue
                            }

                            var range = NSRange(location: 0, length: 0)
                            let attribute = attributedText.attribute(HTMLStylizer.Style.strikethrough.attributeKey, at: strikethroughRange.location, effectiveRange: &range)

                            XCTAssertEqual(strikethroughRange, range)
                            XCTAssertNotNil(attribute)

                            if strikethroughRange.lowerBound > 0 {
                                for i in 0 ..< strikethroughRange.lowerBound {
                                    XCTAssertNil(attributedText.attribute(HTMLStylizer.Style.strikethrough.attributeKey, at: i, effectiveRange: &range), "Expected not to find strikethrough attributes outside of the perscribed range { \(strikethroughRange.lowerBound), \(strikethroughRange.upperBound) }")
                                }
                            }
                            if strikethroughRange.upperBound < attributedText.length - 1 {
                                for i in strikethroughRange.upperBound ..< attributedText.length {
                                    XCTAssertNil(attributedText.attribute(HTMLStylizer.Style.strikethrough.attributeKey, at: i, effectiveRange: &range), "Expected not to find strikethrough attributes outside of the perscribed range { \(strikethroughRange.lowerBound), \(strikethroughRange.upperBound) }")
                                }
                            }
                        } else {
                            for i in 0 ..< attributedText.length {
                                XCTAssertNil(attributedText.attribute(HTMLStylizer.Style.strikethrough.attributeKey, at: i, effectiveRange: nil))
                            }
                        }

                        if styles.contains(.underline) {
                            guard let underlineRange = attributedText.string.range(of: "underline").map({ NSRange($0, in: attributedText.string) }) else {
                                XCTFail("Unable to find range of string \"underline\" in \"\(attributedText.string)\"")
                                continue
                            }

                            var range = NSRange(location: 0, length: 0)
                            let attribute = attributedText.attribute(HTMLStylizer.Style.underline.attributeKey, at: underlineRange.location, effectiveRange: &range)

                            XCTAssertEqual(underlineRange, range)
                            XCTAssertNotNil(attribute)

                            if underlineRange.lowerBound > 0 {
                                for i in 0 ..< underlineRange.lowerBound {
                                    XCTAssertNil(attributedText.attribute(HTMLStylizer.Style.underline.attributeKey, at: i, effectiveRange: &range), "Expected not to find underline attributes outside of the perscribed range { \(underlineRange.lowerBound), \(underlineRange.upperBound) }")
                                }
                            }
                            if underlineRange.upperBound < attributedText.length - 1 {
                                for i in underlineRange.upperBound ..< attributedText.length {
                                    XCTAssertNil(attributedText.attribute(HTMLStylizer.Style.underline.attributeKey, at: i, effectiveRange: &range), "Expected not to find underline attributes outside of the perscribed range { \(underlineRange.lowerBound), \(underlineRange.upperBound) }")
                                }
                            }
                        } else {
                            for i in 0 ..< attributedText.length {
                                XCTAssertNil(attributedText.attribute(HTMLStylizer.Style.underline.attributeKey, at: i, effectiveRange: nil))
                            }
                        }

                        if styles.contains(.superscript) {
                            guard let superscriptRange = attributedText.string.range(of: "superscript").map({ NSRange($0, in: attributedText.string) }) else {
                                XCTFail("Unable to find range of string \"superscript\" in \"\(attributedText.string)\"")
                                continue
                            }

                            var range = NSRange(location: 0, length: 0)
                            let attribute = attributedText.attribute(HTMLStylizer.Style.superscript.attributeKey, at: superscriptRange.location, effectiveRange: &range)

                            XCTAssertEqual(superscriptRange, range)
                            XCTAssertNotNil(attribute)

                            if superscriptRange.lowerBound > 0 {
                                for i in 0 ..< superscriptRange.lowerBound {
                                    XCTAssertNil(attributedText.attribute(HTMLStylizer.Style.superscript.attributeKey, at: i, effectiveRange: &range), "Expected not to find superscript attributes outside of the perscribed range { \(superscriptRange.lowerBound), \(superscriptRange.upperBound) }")
                                }
                            }
                            if superscriptRange.upperBound < attributedText.length - 1 {
                                for i in superscriptRange.upperBound ..< attributedText.length {
                                    XCTAssertNil(attributedText.attribute(HTMLStylizer.Style.superscript.attributeKey, at: i, effectiveRange: &range), "Expected not to find superscript attributes outside of the perscribed range { \(superscriptRange.lowerBound), \(superscriptRange.upperBound) }")
                                }
                            }
                        } else {
                            for i in 0 ..< attributedText.length {
                                XCTAssertNil(attributedText.attribute(HTMLStylizer.Style.superscript.attributeKey, at: i, effectiveRange: nil))
                            }
                        }

                        if styles.contains(.textColor) {
                            guard let textColorRange = attributedText.string.range(of: "textcolor").map({ NSRange($0, in: attributedText.string) }) else {
                                XCTFail("Unable to find range of string \"textcolor\" in \"\(attributedText.string)\"")
                                continue
                            }

                            var range = NSRange(location: 0, length: 0)
                            let attribute = attributedText.attribute(HTMLStylizer.Style.textColor.attributeKey, at: textColorRange.location, effectiveRange: &range)

                            XCTAssertEqual(textColorRange, range)
                            XCTAssertNotNil(attribute)

                            if textColorRange.lowerBound > 0 {
                                for i in 0 ..< textColorRange.lowerBound {
                                    XCTAssertNil(attributedText.attribute(HTMLStylizer.Style.textColor.attributeKey, at: i, effectiveRange: &range), "Expected not to find text color attributes outside of the perscribed range { \(textColorRange.lowerBound), \(textColorRange.upperBound) }")
                                }
                            }
                            if textColorRange.upperBound < attributedText.length - 1 {
                                for i in textColorRange.upperBound ..< attributedText.length {
                                    XCTAssertNil(attributedText.attribute(HTMLStylizer.Style.textColor.attributeKey, at: i, effectiveRange: &range), "Expected not to find text color attributes outside of the perscribed range { \(textColorRange.lowerBound), \(textColorRange.upperBound) }")
                                }
                            }
                        } else {
                            for i in 0 ..< attributedText.length {
                                XCTAssertNil(attributedText.attribute(HTMLStylizer.Style.textColor.attributeKey, at: i, effectiveRange: nil))
                            }
                        }

                        if styles.contains(.backgroundColor) {
                            guard let backgroundColorRange = attributedText.string.range(of: "backgroundcolor").map({ NSRange($0, in: attributedText.string) }) else {
                                XCTFail("Unable to find range of string \"backgroundcolor\" in \"\(attributedText.string)\"")
                                continue
                            }

                            var range = NSRange(location: 0, length: 0)
                            let attribute = attributedText.attribute(HTMLStylizer.Style.backgroundColor.attributeKey, at: backgroundColorRange.location, effectiveRange: &range)

                            XCTAssertEqual(backgroundColorRange, range)
                            XCTAssertNotNil(attribute)

                            if backgroundColorRange.lowerBound > 0 {
                                for i in 0 ..< backgroundColorRange.lowerBound {
                                    XCTAssertNil(attributedText.attribute(HTMLStylizer.Style.backgroundColor.attributeKey, at: i, effectiveRange: &range), "Expected not to find background color attributes outside of the perscribed range { \(backgroundColorRange.lowerBound), \(backgroundColorRange.upperBound) }")
                                }
                            }
                            if backgroundColorRange.upperBound < attributedText.length - 1 {
                                for i in backgroundColorRange.upperBound ..< attributedText.length {
                                    XCTAssertNil(attributedText.attribute(HTMLStylizer.Style.backgroundColor.attributeKey, at: i, effectiveRange: &range), "Expected not to find background color attributes outside of the perscribed range { \(backgroundColorRange.lowerBound), \(backgroundColorRange.upperBound) }")
                                }
                            }
                        } else {
                            for i in 0 ..< attributedText.length {
                                XCTAssertNil(attributedText.attribute(HTMLStylizer.Style.backgroundColor.attributeKey, at: i, effectiveRange: nil))
                            }
                        }

                        if styles.contains(.link) {
                            guard let linkRange = attributedText.string.range(of: "link").map({ NSRange($0, in: attributedText.string) }) else {
                                XCTFail("Unable to find range of string \"link\" in \"\(attributedText.string)\"")
                                continue
                            }

                            var range = NSRange(location: 0, length: 0)
                            let attribute = attributedText.attribute(HTMLStylizer.Style.link.attributeKey, at: linkRange.location, effectiveRange: &range)

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
                                    XCTAssertNil(attributedText.attribute(HTMLStylizer.Style.link.attributeKey, at: i, effectiveRange: &range), "Expected not to find link attributes outside of the perscribed range { \(linkRange.lowerBound), \(linkRange.upperBound) }")
                                }
                            }
                            if linkRange.upperBound < attributedText.length - 1 {
                                for i in linkRange.upperBound ..< attributedText.length {
                                    XCTAssertNil(attributedText.attribute(HTMLStylizer.Style.link.attributeKey, at: i, effectiveRange: &range), "Expected not to find link attributes outside of the perscribed range { \(linkRange.lowerBound), \(linkRange.upperBound) }")
                                }
                            }
                        } else {
                            for i in 0 ..< attributedText.length {
                                XCTAssertNil(attributedText.attribute(HTMLStylizer.Style.link.attributeKey, at: i, effectiveRange: nil))
                            }
                        }
                    }
                }
            }
        }
    }

    //

    func testAllNestedHTMLStyles() throws {
        let color = try XCTUnwrap(ColorParser.parseColor(from: "crimson"))

        for styles in HTMLStylizerTests.allStyles.filter({ $0.count > 1 }) {
            let stylizers = HTMLStylizerTests.stylizers(for: styles)

            HTMLStylizerTests.iterateAllNestedPermutations(for: styles) { finalText, permutations in
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

                            case "underline" where styles.contains(.underline):
                                AssertAttributedString(attributedText, containsAttribute: .stylizerUnderline, inRange: range)
                                AssertAttributedString(attributedText, doesNotContainAttribute: .stylizerUnderline, inRange: NSRange(location: 0, length: range.lowerBound))

                            case "superscript" where styles.contains(.superscript):
                                AssertAttributedString(attributedText, containsAttribute: .stylizerSuperscript, inRange: range)
                                AssertAttributedString(attributedText, doesNotContainAttribute: .stylizerSuperscript, inRange: NSRange(location: 0, length: range.lowerBound))

                            case "textcolor" where styles.contains(.textColor):
                                AssertAttributedString(attributedText, containsAttribute: (.stylizerTextColor, color), inRange: range)
                                AssertAttributedString(attributedText, doesNotContainAttribute: .stylizerTextColor, inRange: NSRange(location: 0, length: range.lowerBound))

                            case "backgroundcolor" where styles.contains(.backgroundColor):
                                AssertAttributedString(attributedText, containsAttribute: (.stylizerBackgroundColor, color), inRange: range)
                                AssertAttributedString(attributedText, doesNotContainAttribute: .stylizerBackgroundColor, inRange: NSRange(location: 0, length: range.lowerBound))

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

    func testColorParsing() {
        let stylizer = HTMLStylizer(styles: [.textColor, .backgroundColor])
        let random: () -> Int = { Int.random(in: 0 ... 255) }
        let iterations = 15

        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            let r = random()

            DispatchQueue.concurrentPerform(iterations: iterations) { _ in
                let g = random()

                DispatchQueue.concurrentPerform(iterations: iterations) { _ in
                    let b = random()

                    //

                    let rgbReference = [CGFloat(r) / 255.0, CGFloat(g) / 255.0, CGFloat(b) / 255.0, 1.0]
                    for colorString in ["#\(String(format: "%02X", r))\(String(format: "%02X", g))\(String(format: "%02X", b))", "rgb(\(r),\(g),\(b))"] {
                        let textColor = "<p style=\"color:\(colorString);\">textcolor</p>"
                        let backgroundColor = "<p style=\"background-color:\(colorString);\">backgroundcolor</p>"

                        //

                        var attributedText = stylizer.attributedStringByReplacingMatches(in: textColor)
                        XCTAssertEqual(attributedText.string, "textcolor")

                        var range = NSRange(location: 0, length: 0)
                        var attributes = attributedText.attributes(at: 0, effectiveRange: &range)

                        XCTAssertEqual(attributes.count, 1)
                        XCTAssertEqual(range, NSRange(location: 0, length: attributedText.length))

                        if let color = (attributes[.stylizerTextColor] as? StylizerNativeColor).map({ $0.cgColor }) {
                            XCTAssertEqual(color.colorSpace?.model, .rgb)
                            XCTAssertEqual(color.components?.count, 4)

                            color.components?.enumerated().map { abs($1 - rgbReference[$0]) }.forEach { XCTAssertLessThanOrEqual($0, 0.001, "ColorString: \"\(colorString)\"") }
                        } else {
                            XCTFail("Unable to parse the color attribute from expression: \(textColor)")
                        }

                        //

                        attributedText = stylizer.attributedStringByReplacingMatches(in: backgroundColor)
                        XCTAssertEqual(attributedText.string, "backgroundcolor")

                        attributes = attributedText.attributes(at: 0, effectiveRange: &range)

                        XCTAssertEqual(attributes.count, 1)
                        XCTAssertEqual(range, NSRange(location: 0, length: attributedText.length))

                        if let color = (attributes[.stylizerBackgroundColor] as? StylizerNativeColor).map({ $0.cgColor }) {
                            XCTAssertEqual(color.colorSpace?.model, .rgb)
                            XCTAssertEqual(color.components?.count, 4)

                            color.components?.enumerated().map { abs($1 - rgbReference[$0]) }.forEach { XCTAssertLessThanOrEqual($0, 0.001, "ColorString: \"\(colorString)\"") }
                        } else {
                            XCTFail("Unable to parse the color attribute from expression: \(backgroundColor)")
                        }
                    }

                    //

                    DispatchQueue.concurrentPerform(iterations: iterations) { _ in
                        let a = CGFloat(random()) / 255.0
                        let rgbaReference = [CGFloat(r) / 255.0, CGFloat(g) / 255.0, CGFloat(b) / 255.0, a]

                        for colorString in ["rgb(\(r),\(g),\(b),\(a))", "displayP3(\(r),\(g),\(b),\(a))"] {
                            let textColor = "<p style=\"color:\(colorString);\">textcolor</p>"
                            let backgroundColor = "<p style=\"background-color:\(colorString);\">backgroundcolor</p>"

                            //

                            var attributedText = stylizer.attributedStringByReplacingMatches(in: textColor)
                            XCTAssertEqual(attributedText.string, "textcolor")

                            var range = NSRange(location: 0, length: 0)
                            var attributes = attributedText.attributes(at: 0, effectiveRange: &range)

                            XCTAssertEqual(attributes.count, 1)
                            XCTAssertEqual(range, NSRange(location: 0, length: attributedText.length))

                            if let color = (attributes[.stylizerTextColor] as? StylizerNativeColor).map({ $0.cgColor }) {
                                XCTAssertEqual(color.colorSpace?.model, .rgb)
                                XCTAssertEqual(color.components?.count, 4)

                                color.components?.enumerated().map { abs($1 - rgbaReference[$0]) }.forEach { XCTAssertLessThanOrEqual($0, 0.001, "ColorString: \"\(colorString)\"") }
                            } else {
                                XCTFail("Unable to parse the color attribute from expression: \(textColor)")
                            }

                            //

                            attributedText = stylizer.attributedStringByReplacingMatches(in: backgroundColor)
                            XCTAssertEqual(attributedText.string, "backgroundcolor")

                            attributes = attributedText.attributes(at: 0, effectiveRange: &range)

                            XCTAssertEqual(attributes.count, 1)
                            XCTAssertEqual(range, NSRange(location: 0, length: attributedText.length))

                            if let color = (attributes[.stylizerBackgroundColor] as? StylizerNativeColor).map({ $0.cgColor }) {
                                XCTAssertEqual(color.colorSpace?.model, .rgb)
                                XCTAssertEqual(color.components?.count, 4)

                                color.components?.enumerated().map { abs($1 - rgbaReference[$0]) }.forEach { XCTAssertLessThanOrEqual($0, 0.001, "ColorString: \"\(colorString)\"") }
                            } else {
                                XCTFail("Unable to parse the color attribute from expression: \(backgroundColor)")
                            }
                        }
                    }
                }
            }
        }
    }

    //

    func testParsingCharacterEntities() {
        let unstylizedString = "<b>\"1 &lt; 2\" is true &amp; \"1 &gt; 2\" is false</b>. &quot; and &apos; are entities that aren't processed."
        var stylizedString = HTMLStylizer().attributedStringByReplacingMatches(in: unstylizedString)

        XCTAssertEqual(stylizedString.string, "\"1 < 2\" is true & \"1 > 2\" is false. &quot; and &apos; are entities that aren't processed.")

        var range = NSRange(location: 0, length: 0)
        var attributes = stylizedString.attributes(at: 0, effectiveRange: &range)

        XCTAssertEqual(range, NSRange(location: 0, length: 34))
        XCTAssertEqual(attributes.count, 1)
        XCTAssertNotNil(attributes[.stylizerBold])

        //

        stylizedString = HTMLStylizer(styles: HTMLStylizer.Style.allCases, options: []).attributedStringByReplacingMatches(in: unstylizedString)

        XCTAssertEqual(stylizedString.string, "\"1 &lt; 2\" is true &amp; \"1 &gt; 2\" is false. &quot; and &apos; are entities that aren't processed.")

        attributes = stylizedString.attributes(at: 0, effectiveRange: &range)

        XCTAssertEqual(range, NSRange(location: 0, length: 44))
        XCTAssertEqual(attributes.count, 1)
        XCTAssertNotNil(attributes[.stylizerBold])
    }

    // MARK: Private Methods

    private class func stylizers(for styles: [HTMLStylizer.Style]) -> [HTMLStylizer] {
        var stylizers: [HTMLStylizer] = [HTMLStylizer(styles: styles)]

        if styles.count == HTMLStylizer.Style.allCases.count {
            stylizers.append(HTMLStylizer())
        }
        if styles.count == 1 {
            stylizers.append(HTMLStylizer(style: styles[0]))
        }

        return stylizers
    }
}
#endif // #if !os(watchOS)
