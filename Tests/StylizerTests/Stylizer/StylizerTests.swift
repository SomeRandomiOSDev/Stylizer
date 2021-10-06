//
//  StylizerTests.swift
//  StylizerTests
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

@testable import Stylizer
import XCTest

// MARK: - StylizerTests Definition

class StylizerTests: XCTestCase {

    // MARK: Test Methods

    func testCopyStylizer() throws {
        let styleInfo = try [StyleInfo(expression: .init(pattern: "<font:\"([^\"]+)\">(.*?)</font>"), replacementTemplate: "$2", matchingOptions: .anchored, attributesProvider: nil),
                             StyleInfo(expression: .init(pattern: "<font-color:\\(([0-9]{1,3}),([0-9]{1,3}),([0-9]{1,3})\\)>(.*?)</font-color>"), replacementTemplate: "$4", matchingOptions: .withTransparentBounds, attributesProvider: nil)]

        let stylizer = Stylizer(styleInfo: styleInfo)
        let copy = try XCTUnwrap(stylizer.copy() as? Stylizer)

        XCTAssertFalse(stylizer === copy)
        XCTAssertEqual(stylizer.styleInfo, copy.styleInfo)
    }

    func testStylizingSubrange() {
        var string = "**stylized string**, **non-stylized string**"
        var subrange = NSRange(location: 0, length: 19)
        var attributedString = MarkdownStylizer().attributedStringByReplacingMatches(in: string, range: subrange)

        XCTAssertEqual(attributedString.string, "stylized string, **non-stylized string**")

        var range = NSRange(location: 0, length: 0)
        var attributes = attributedString.attributes(at: 0, effectiveRange: &range)

        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(range, NSRange(location: 0, length: 15))
        XCTAssertNotNil(attributes[.stylizerBold])

        attributes = attributedString.attributes(at: 15, effectiveRange: &range)

        XCTAssertTrue(attributes.isEmpty)
        XCTAssertEqual(range, NSRange(location: 15, length: attributedString.length - 15))

        //

        string = "**non-stylized string**, **stylized string**"
        subrange = NSRange(location: 23, length: string.count - 23)
        attributedString = MarkdownStylizer().attributedStringByReplacingMatches(in: string, range: subrange)

        XCTAssertEqual(attributedString.string, "**non-stylized string**, stylized string")

        attributes = attributedString.attributes(at: 0, effectiveRange: &range)

        XCTAssertTrue(attributes.isEmpty)
        XCTAssertEqual(range, NSRange(location: 0, length: 25))

        attributes = attributedString.attributes(at: 25, effectiveRange: &range)

        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(range, NSRange(location: 25, length: 15))
        XCTAssertNotNil(attributes[.stylizerBold])

        //

        string = "**non-stylized string**, **stylized string**, **non-stylized string**"
        subrange = NSRange(location: 23, length: 23)
        attributedString = MarkdownStylizer().attributedStringByReplacingMatches(in: string, range: subrange)

        XCTAssertEqual(attributedString.string, "**non-stylized string**, stylized string, **non-stylized string**")

        attributes = attributedString.attributes(at: 0, effectiveRange: &range)

        XCTAssertTrue(attributes.isEmpty)
        XCTAssertEqual(range, NSRange(location: 0, length: 25))

        attributes = attributedString.attributes(at: 25, effectiveRange: &range)

        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(range, NSRange(location: 25, length: 15))
        XCTAssertNotNil(attributes[.stylizerBold])

        attributes = attributedString.attributes(at: 40, effectiveRange: &range)

        XCTAssertTrue(attributes.isEmpty)
        XCTAssertEqual(range, NSRange(location: 40, length: 25))
    }

    func testStylizingInvalidSubranges() {
        let baseString = NSAttributedString(string: "**bold** *italic* ~~strikethrough~~ [link](https://www.apple.com)")
        let stylizer = MarkdownStylizer()

        var attributedString = stylizer.attributedStringByReplacingMatches(in: baseString, range: NSRange(location: -1, length: baseString.length))
        XCTAssertEqual(baseString, attributedString)

        attributedString = stylizer.attributedStringByReplacingMatches(in: baseString, range: NSRange(location: baseString.length, length: baseString.length))
        XCTAssertEqual(baseString, attributedString)

        attributedString = stylizer.attributedStringByReplacingMatches(in: baseString, range: NSRange(location: baseString.length / 2, length: 0))
        XCTAssertEqual(baseString, attributedString)
    }
}
