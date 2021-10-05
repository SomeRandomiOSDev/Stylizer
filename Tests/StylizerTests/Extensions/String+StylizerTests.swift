//
//  String+StylizerTests.swift
//  StylizerTests
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

@testable import Stylizer
import XCTest

//swiftlint:disable function_body_length

// MARK: - StringStylizerTests Definition

class StringStylizerTests: XCTestCase {

    // MARK: Test Methods

    func testStylizeString() {
        let font: StylizerNativeFont = .defaultFont

        //

        let markdownString = "**bold**, __bold__, *italic*, _italic_, ~~strikethrough~~, [link](https://www.apple.com), [link](https://www.apple.com \"title\")"
        let stylizedMarkdownString = markdownString.stylize(with: [MarkdownStylizer()], defaultFont: font)

        XCTAssertEqual(stylizedMarkdownString.string, "bold, bold, italic, italic, strikethrough, link, link")

        var range = NSRange(location: 0, length: 0)
        var testRange = NSRange(location: 0, length: 4)
        var attributes = stylizedMarkdownString.attributes(at: testRange.lowerBound, effectiveRange: &range)

        XCTAssertEqual(range, testRange)
        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(attributes[.font] as? StylizerNativeFont, font.byAddingSymbolicTraits(.bold))

        testRange = NSRange(location: range.upperBound + 2, length: 4)
        attributes = stylizedMarkdownString.attributes(at: testRange.lowerBound, effectiveRange: &range)

        XCTAssertEqual(range, testRange)
        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(attributes[.font] as? StylizerNativeFont, font.byAddingSymbolicTraits(.bold))

        testRange = NSRange(location: range.upperBound + 2, length: 6)
        attributes = stylizedMarkdownString.attributes(at: testRange.lowerBound, effectiveRange: &range)

        XCTAssertEqual(range, testRange)
        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(attributes[.font] as? StylizerNativeFont, font.byAddingSymbolicTraits(.italic))

        testRange = NSRange(location: range.upperBound + 2, length: 6)
        attributes = stylizedMarkdownString.attributes(at: testRange.lowerBound, effectiveRange: &range)

        XCTAssertEqual(range, testRange)
        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(attributes[.font] as? StylizerNativeFont, font.byAddingSymbolicTraits(.italic))

        testRange = NSRange(location: range.upperBound + 2, length: 13)
        attributes = stylizedMarkdownString.attributes(at: testRange.lowerBound, effectiveRange: &range)

        XCTAssertEqual(range, testRange)
        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(attributes[.strikethroughStyle] as? Int, NSUnderlineStyle.single.rawValue)

        testRange = NSRange(location: range.upperBound + 2, length: 4)
        attributes = stylizedMarkdownString.attributes(at: testRange.lowerBound, effectiveRange: &range)

        XCTAssertEqual(range, testRange)
        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual((attributes[.link] as? URL)?.absoluteString ?? ((attributes[.link] as? String) ?? ""), "https://www.apple.com")

        testRange = NSRange(location: range.upperBound + 2, length: 4)
        attributes = stylizedMarkdownString.attributes(at: testRange.lowerBound, effectiveRange: &range)

        XCTAssertEqual(range, testRange)

        #if canImport(UIKit)
        XCTAssertEqual(attributes.count, 1)
        #else
        XCTAssertEqual(attributes.count, 2)
        XCTAssertEqual(attributes[.toolTip] as? String, "title")
        #endif

        XCTAssertEqual((attributes[.link] as? URL)?.absoluteString ?? ((attributes[.link] as? String) ?? ""), "https://www.apple.com")

        //

        let htmlString = "<b>bold</b>, <strong>bold</strong>, <i>italic</i>, <em>italic</em>, <del>strikethrough</del>, <ins>underline</ins>, <sup>superscript</sup>, <p style=\"color:blue;\">text color</p>, <p style=\"background-color:red;\">background color</p>, <a href=\"https://www.apple.com\">link</a>, <a href=\"https://www.apple.com\" title=\"title\">link</a>"
        let stylizedHTMLString = htmlString.stylize(with: [HTMLStylizer()], defaultFont: font)

        XCTAssertEqual(stylizedHTMLString.string, "bold, bold, italic, italic, strikethrough, underline, superscript, text color, background color, link, link")

        range = NSRange(location: 0, length: 0)
        testRange = NSRange(location: 0, length: 4)
        attributes = stylizedHTMLString.attributes(at: 0, effectiveRange: &range)

        XCTAssertEqual(range, testRange)
        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(attributes[.font] as? StylizerNativeFont, font.byAddingSymbolicTraits(.bold))

        testRange = NSRange(location: range.upperBound + 2, length: 4)
        attributes = stylizedMarkdownString.attributes(at: testRange.lowerBound, effectiveRange: &range)

        XCTAssertEqual(range, testRange)
        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(attributes[.font] as? StylizerNativeFont, font.byAddingSymbolicTraits(.bold))

        testRange = NSRange(location: range.upperBound + 2, length: 6)
        attributes = stylizedMarkdownString.attributes(at: testRange.lowerBound, effectiveRange: &range)

        XCTAssertEqual(range, testRange)
        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(attributes[.font] as? StylizerNativeFont, font.byAddingSymbolicTraits(.italic))

        testRange = NSRange(location: range.upperBound + 2, length: 6)
        attributes = stylizedMarkdownString.attributes(at: testRange.lowerBound, effectiveRange: &range)

        XCTAssertEqual(range, testRange)
        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(attributes[.font] as? StylizerNativeFont, font.byAddingSymbolicTraits(.italic))

        testRange = NSRange(location: range.upperBound + 2, length: 13)
        attributes = stylizedMarkdownString.attributes(at: testRange.lowerBound, effectiveRange: &range)

        XCTAssertEqual(range, testRange)
        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(attributes[.strikethroughStyle] as? Int, NSUnderlineStyle.single.rawValue)

        testRange = NSRange(location: range.upperBound + 2, length: 9)
        attributes = stylizedHTMLString.attributes(at: testRange.lowerBound, effectiveRange: &range)

        XCTAssertEqual(range, testRange)
        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(attributes[.underlineStyle] as? Int, NSUnderlineStyle.single.rawValue)

        testRange = NSRange(location: range.upperBound + 2, length: 11)
        attributes = stylizedHTMLString.attributes(at: testRange.lowerBound, effectiveRange: &range)

        #if canImport(UIKit)
        XCTAssertEqual(range, NSRange(location: testRange.location - 2, length: testRange.length + 4))
        XCTAssertTrue(attributes.isEmpty)
        range.length -= 2
        #else
        XCTAssertEqual(range, testRange)
        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(attributes[.superscript] as? Int, 1)
        #endif // #if canImport(UIKit)

        testRange = NSRange(location: range.upperBound + 2, length: 10)
        attributes = stylizedHTMLString.attributes(at: testRange.lowerBound, effectiveRange: &range)

        XCTAssertEqual(range, testRange)
        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(attributes[.foregroundColor] as? StylizerNativeColor, ColorParser.parseColor(from: "blue"))

        testRange = NSRange(location: range.upperBound + 2, length: 16)
        attributes = stylizedHTMLString.attributes(at: testRange.lowerBound, effectiveRange: &range)

        XCTAssertEqual(range, testRange)
        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(attributes[.backgroundColor] as? StylizerNativeColor, ColorParser.parseColor(from: "red"))

        testRange = NSRange(location: range.upperBound + 2, length: 4)
        attributes = stylizedHTMLString.attributes(at: testRange.lowerBound, effectiveRange: &range)

        XCTAssertEqual(range, testRange)
        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual((attributes[.link] as? URL)?.absoluteString ?? ((attributes[.link] as? String) ?? ""), "https://www.apple.com")

        testRange = NSRange(location: range.upperBound + 2, length: 4)
        attributes = stylizedHTMLString.attributes(at: testRange.lowerBound, effectiveRange: &range)

        #if canImport(UIKit)
        XCTAssertEqual(attributes.count, 1)
        #else
        XCTAssertEqual(attributes.count, 2)
        XCTAssertEqual(attributes[.toolTip] as? String, "title")
        #endif // #if canImport(UIKit)

        XCTAssertEqual((attributes[.link] as? URL)?.absoluteString ?? ((attributes[.link] as? String) ?? ""), "https://www.apple.com")
    }

    func testStylizeStringWithNoStylizers() {
        let markdownString = "**bold**, __bold__, *italic*, _italic_, ~~strikethrough~~, [link](https://www.apple.com), [link](https://www.apple.com \"title\")"
        let stylizedMarkdownString = markdownString.stylize(with: [], defaultFont: .defaultFont)

        XCTAssertEqual(markdownString, stylizedMarkdownString.string)

        var attributeCount = 0
        stylizedMarkdownString.enumerateAttributes(in: stylizedMarkdownString.stringRange, options: []) { attributes, _, _ in
            attributeCount += attributes.count
        }

        XCTAssertEqual(attributeCount, 0)
    }
}
