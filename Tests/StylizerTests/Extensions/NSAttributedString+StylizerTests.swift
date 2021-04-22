//
//  NSAttributedString+StylizerTests.swift
//  Stylizer
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

#if !os(watchOS)
@testable import Stylizer
import XCTest

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

//swiftlint:disable function_body_length

// MARK: - NSAttributedStringStylizerTests Definition

class NSAttributedStringStylizerTests: StylizerTestCase {

    // MARK: Test Methods

    func testStringRange() {
        let attributedString = NSAttributedString(string: String(repeating: Character(Unicode.Scalar(UUID().uuid.0)), count: Int.random(in: 128 ..< 256)))
        let stringRange = attributedString.stringRange

        XCTAssertEqual(stringRange, NSRange(location: 0, length: attributedString.length))
    }

    #if canImport(UIKit) || canImport(AppKit)
    func testStylizeString() throws {
        let stylizer = HTMLStylizer()
        let font = StylizerNativeFont.defaultFont
        let color = try XCTUnwrap(ColorParser.parseColor(from: "crimson"))

        XCTAssertNotNil(font.familyName)
        XCTAssertFalse(font.fontDescriptor.symbolicTraits.contains([.bold, .italic]))

        let attributedString = NSAttributedString(string: "<b>bold, <i>italics, <del>strikethrough, <ins>underline, <sup>superscript, <p style=\"color:crimson;\">textcolor, <p style=\"background-color:crimson;\">backgroundcolor, <a href=\"https://link.com\" title=\"optional\">link</a></p></p></sup></ins></del></i></b>")
        let prestylizedString = stylizer.attributedStringByReplacingMatches(in: attributedString) // has stylizer placeholders

        for (attributedString, stylizers) in [(attributedString, [stylizer]), (prestylizedString, [])] {
            let stylizedString = attributedString.stylize(with: stylizers, defaultFont: font)
            var extraAttributeCount = 0

            #if canImport(AppKit) && !targetEnvironment(macCatalyst)
            extraAttributeCount += 1
            #endif // #if canImport(AppKit) && !targetEnvironment(macCatalyst)

            XCTAssertEqual(stylizedString.string, "bold, italics, strikethrough, underline, superscript, textcolor, backgroundcolor, link")

            var range = NSRange(location: 0, length: 0)
            var testRange = NSRange(location: 0, length: 6)
            var attributes = stylizedString.attributes(at: range.upperBound, effectiveRange: &range)

            XCTAssertEqual(attributes.count, 1)
            XCTAssertEqual(range, testRange)

            AssertFont(in: attributes, equalTo: font, with: .bold, range: testRange)

            //

            attributes = stylizedString.attributes(at: range.upperBound, effectiveRange: &range)
            testRange = NSRange(location: 6, length: 9)

            XCTAssertEqual(attributes.count, 1)
            XCTAssertEqual(range, testRange)

            AssertFont(in: attributes, equalTo: font, with: [.bold, .italic], range: testRange)

            //

            attributes = stylizedString.attributes(at: range.upperBound, effectiveRange: &range)
            testRange = NSRange(location: 15, length: 15)

            XCTAssertEqual(attributes.count, 2)
            XCTAssertEqual(range, testRange)

            AssertFont(in: attributes, equalTo: font, with: [.bold, .italic], range: testRange)
            AssertStrikethrough(in: attributes, equalTo: .single, range: testRange)

            //

            attributes = stylizedString.attributes(at: range.upperBound, effectiveRange: &range)

            XCTAssertEqual(attributes.count, 3)
            #if canImport(AppKit) && !targetEnvironment(macCatalyst)
            XCTAssertEqual(range, NSRange(location: 30, length: 11))
            #else
            XCTAssertEqual(range, NSRange(location: 30, length: 24))
            #endif // #if canImport(AppKit) && !targetEnvironment(macCatalyst)

            AssertFont(in: attributes, equalTo: font, with: [.bold, .italic], range: testRange)
            AssertStrikethrough(in: attributes, equalTo: .single, range: testRange)
            AssertUnderline(in: attributes, equalTo: .single, range: testRange)

            //

            #if canImport(AppKit) && !targetEnvironment(macCatalyst)
            attributes = stylizedString.attributes(at: range.upperBound, effectiveRange: &range)

            XCTAssertEqual(attributes.count, 3 + extraAttributeCount)
            XCTAssertEqual(range, NSRange(location: 41, length: 13))

            AssertFont(in: attributes, equalTo: font, with: [.bold, .italic], range: testRange)
            AssertStrikethrough(in: attributes, equalTo: .single, range: testRange)
            AssertUnderline(in: attributes, equalTo: .single, range: testRange)
            AssertSuperscript(in: attributes, range: testRange)
            #endif // #if canImport(AppKit) && !targetEnvironment(macCatalyst)

            //

            attributes = stylizedString.attributes(at: range.upperBound, effectiveRange: &range)

            XCTAssertEqual(attributes.count, 4 + extraAttributeCount)
            XCTAssertEqual(range, NSRange(location: 54, length: 11))

            AssertFont(in: attributes, equalTo: font, with: [.bold, .italic], range: testRange)
            AssertStrikethrough(in: attributes, equalTo: .single, range: testRange)
            AssertUnderline(in: attributes, equalTo: .single, range: testRange)
            AssertSuperscript(in: attributes, range: testRange)
            AssertTextColor(in: attributes, equalTo: color, range: testRange)

            //

            attributes = stylizedString.attributes(at: range.upperBound, effectiveRange: &range)

            XCTAssertEqual(attributes.count, 5 + extraAttributeCount)
            XCTAssertEqual(range, NSRange(location: 65, length: 17))

            AssertFont(in: attributes, equalTo: font, with: [.bold, .italic], range: testRange)
            AssertStrikethrough(in: attributes, equalTo: .single, range: testRange)
            AssertUnderline(in: attributes, equalTo: .single, range: testRange)
            AssertSuperscript(in: attributes, range: testRange)
            AssertTextColor(in: attributes, equalTo: color, range: testRange)
            AssertBackgroundColor(in: attributes, equalTo: color, range: testRange)

            //

            attributes = stylizedString.attributes(at: range.upperBound, effectiveRange: &range)

            #if canImport(AppKit) && !targetEnvironment(macCatalyst)
            extraAttributeCount += 1 // When working with AppKit the link title is inserted as a tooltip attribute
            #endif // #if canImport(AppKit) && !targetEnvironment(macCatalyst)

            XCTAssertEqual(attributes.count, 6 + extraAttributeCount)
            XCTAssertEqual(range, NSRange(location: 82, length: 4))

            AssertFont(in: attributes, equalTo: font, with: [.bold, .italic], range: testRange)
            AssertStrikethrough(in: attributes, equalTo: .single, range: testRange)
            AssertUnderline(in: attributes, equalTo: .single, range: testRange)
            AssertSuperscript(in: attributes, range: testRange)
            AssertTextColor(in: attributes, equalTo: color, range: testRange)
            AssertBackgroundColor(in: attributes, equalTo: color, range: testRange)
            AssertLink(in: attributes, equalTo: ["https://link.com", "optional"], range: testRange)
        }
    }

    func testStylizingWithCustomAttributes() throws {
        //swiftlint:disable nesting
        class ShadowStylizer: Stylizer {
            static let customAttribute = NSAttributedString.Key(rawValue: "com.stylizer.shadowstylizer.\(UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: ""))")

            init() { super.init(styleInfo: [.init(expression: .init(verifiedPattern: "<shadow:\\(([0-9]+\\.[0-9]+),([0-9]+\\.[0-9]+),([0-9]+\\.[0-9]+)\\)>(.*?)</shadow>"), replacementTemplate: "$4", attributesProvider: ShadowStylizer.attributesProvider(_:in:))]) }

            private class func attributesProvider(_ match: NSTextCheckingResult, in string: String) -> [NSAttributedString.Key: Any] {
                guard let width = Range(match.range(at: 1), in: string).flatMap({ Double(string[$0]).map { CGFloat($0) } }),
                      let height = Range(match.range(at: 2), in: string).flatMap({ Double(string[$0]).map { CGFloat($0) } }),
                      let radius = Range(match.range(at: 3), in: string).flatMap({ Double(string[$0]).map { CGFloat($0) } }) else {
                    XCTFail("Unexpected issue while parsing \"\(string)\"")
                    return [:]
                }

                let shadow = NSShadow()
                shadow.shadowOffset = CGSize(width: width, height: height)
                shadow.shadowBlurRadius = radius

                return [customAttribute: shadow]
            }
        }
        //swiftlint:enable nesting

        NSAttributedString.Key.registerCustomStylizerPlaceholderAttributes([ShadowStylizer.customAttribute])

        let shadowString = "<shadow:(5.0,7.5,3.25)>this text has a shadow</shadow>"
        let attributedString = NSAttributedString(string: shadowString).stylize(with: [ShadowStylizer()], defaultFont: nil) { key, value, _ in
            XCTAssertEqual(key, ShadowStylizer.customAttribute)

            var attributes: [NSAttributedString.Key: Any] = [:]
            if let shadow = value as? NSShadow {
                XCTAssertEqual(shadow.shadowOffset, CGSize(width: 5.0, height: 7.5))
                XCTAssertEqual(shadow.shadowBlurRadius, 3.25)

                attributes = [.shadow: shadow]
            } else {
                XCTFail("Expected value of custom attribute to be an instance of NSShadow")
            }

            return attributes
        }

        XCTAssertEqual(attributedString.string, "this text has a shadow")

        var range = NSRange(location: 0, length: 0)
        let attributes = attributedString.attributes(at: 0, effectiveRange: &range)

        XCTAssertEqual(range, NSRange(location: 0, length: attributedString.length))
        XCTAssertEqual(attributes.count, 1)

        let shadow = try XCTUnwrap(attributes[.shadow] as? NSShadow)

        XCTAssertEqual(shadow.shadowOffset, CGSize(width: 5.0, height: 7.5))
        XCTAssertEqual(shadow.shadowBlurRadius, 3.25)
    }

    func testStylingLinkWithInvalidURL() {
        let stylizer = MarkdownStylizer()

        let attributedString = NSAttributedString(string: "[link](https://<invalidlink>.com \"title\")")
        let prestylizedString = stylizer.attributedStringByReplacingMatches(in: attributedString) // has stylizer placeholders

        for (attributedString, stylizers) in [(attributedString, [stylizer]), (prestylizedString, [])] {
            let stylizedString = attributedString.stylize(with: stylizers)
            XCTAssertEqual(stylizedString.string, "link")

            var range = NSRange(location: 0, length: 0)
            let testRange = NSRange(location: 0, length: 4)
            let attributes = stylizedString.attributes(at: range.upperBound, effectiveRange: &range)

            #if canImport(AppKit) && !targetEnvironment(macCatalyst)
            XCTAssertEqual(attributes.count, 2) // When working with AppKit the link title is inserted as a tooltip attribute
            #else
            XCTAssertEqual(attributes.count, 1)
            #endif // #if canImport(AppKit) && !targetEnvironment(macCatalyst)

            XCTAssertEqual(range, testRange)
            AssertLink(in: attributes, equalTo: ["https://<invalidlink>.com", "title"], range: testRange)
        }
    }

    // MARK: Private Methods

    //swiftlint:disable identifier_name
    private func AssertFont(in attributes: [NSAttributedString.Key: Any], equalTo font: StylizerNativeFont, with symbolicTraits: StylizerNativeFontDescriptor.SymbolicTraits, range: NSRange, file: StaticString = #file, line: UInt = #line) {
        if let attributedFont = attributes[.font] as? StylizerNativeFont {
            XCTAssertNotNil(font.familyName)
            XCTAssertFalse(font.fontDescriptor.symbolicTraits.contains(symbolicTraits))

            XCTAssertEqual(attributedFont.familyName, font.familyName, file: file, line: line)
            XCTAssertEqual(attributedFont.pointSize, font.pointSize, file: file, line: line)
            XCTAssertTrue(attributedFont.fontDescriptor.symbolicTraits.contains(symbolicTraits), file: file, line: line)
        } else {
            XCTFail("Expected to find `.font` attribute in stylized string range \(range)", file: file, line: line)
        }
    }

    private func AssertStrikethrough(in attributes: [NSAttributedString.Key: Any], equalTo strikethrough: NSUnderlineStyle, range: NSRange, file: StaticString = #file, line: UInt = #line) {
        if let attributedStrikethrough = (attributes[.strikethroughStyle] as? NSNumber).map({ NSUnderlineStyle(rawValue: $0.intValue) }) {
            XCTAssertEqual(attributedStrikethrough, strikethrough, file: file, line: line)
        } else {
            XCTFail("Expected to find `.strikethroughStyle` attribute in stylized string range \(range)", file: file, line: line)
        }
    }

    private func AssertUnderline(in attributes: [NSAttributedString.Key: Any], equalTo underline: NSUnderlineStyle, range: NSRange, file: StaticString = #file, line: UInt = #line) {
        if let attributedUnderline = (attributes[.underlineStyle] as? NSNumber).map({ NSUnderlineStyle(rawValue: $0.intValue) }) {
            XCTAssertEqual(attributedUnderline, underline, file: file, line: line)
        } else {
            XCTFail("Expected to find `.underlineStyle` attribute in stylized string range \(range)", file: file, line: line)
        }
    }

    private func AssertSuperscript(in attributes: [NSAttributedString.Key: Any], range: NSRange, file: StaticString = #file, line: UInt = #line) {
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        if let attributedSuperscript = (attributes[.superscript] as? NSNumber).map({ $0.intValue }) {
            XCTAssertEqual(attributedSuperscript, 1, file: file, line: line)
        } else {
            XCTFail("Expected to find `.superscript` attribute in stylized string range \(range)", file: file, line: line)
        }
        #endif // #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    }

    private func AssertTextColor(in attributes: [NSAttributedString.Key: Any], equalTo textColor: StylizerNativeColor, range: NSRange, file: StaticString = #file, line: UInt = #line) {
        if let attributedTextColor = attributes[.foregroundColor] as? StylizerNativeColor {
            XCTAssertEqual(attributedTextColor, textColor, file: file, line: line)
        } else {
            XCTFail("Expected to find `.foregroundColor` attribute in stylized string range \(range)", file: file, line: line)
        }
    }

    private func AssertBackgroundColor(in attributes: [NSAttributedString.Key: Any], equalTo backgroundColor: StylizerNativeColor, range: NSRange, file: StaticString = #file, line: UInt = #line) {
        if let attributedBackgroundColor = attributes[.backgroundColor] as? StylizerNativeColor {
            XCTAssertEqual(attributedBackgroundColor, backgroundColor, file: file, line: line)
        } else {
            XCTFail("Expected to find `.backgroundColor` attribute in stylized string range \(range)", file: file, line: line)
        }
    }

    private func AssertLink(in attributes: [NSAttributedString.Key: Any], equalTo linkStrings: [String], range: NSRange, file: StaticString = #file, line: UInt = #line) {
        if let link = attributes[.link] {
            if let link = link as? URL {
                XCTAssertEqual(link.absoluteString, linkStrings[0], file: file, line: line)
            } else if let link = link as? String {
                XCTAssertEqual(link, linkStrings[0], file: file, line: line)
            } else {
                XCTFail("Wrong type found for `.link` attribute in stylized string range \(range): \(String(describing: type(of: link)))", file: file, line: line)
            }
        } else {
            XCTFail("Expected to find `.link` attribute in stylized string range \(range)", file: file, line: line)
        }

        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        if linkStrings.count >= 2 {
            if let tooltip = attributes[.toolTip] as? String {
                XCTAssertEqual(tooltip, linkStrings[1], file: file, line: line)
            } else {
                XCTFail("Expected to find `.toolTip` attribute in stylized string range \(range)", file: file, line: line)
            }
        }
        #endif // #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    }
    //swiftlint:enable identifier_name
    #endif // #if canImport(UIKit) || canImport(AppKit)
}
#endif // #if !os(watchOS)
