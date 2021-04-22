//
//  AppKitStylizedLabelTests.swift
//  Stylizer
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
@testable import Stylizer
import XCTest

//swiftlint:disable function_body_length

// MARK: - AppKitStylizedLabelTests Definition

class AppKitStylizedLabelTests: XCTestCase, StylizedLabelDelegate {

    // MARK: Private Properties

    private static let customAttribute: NSAttributedString.Key = {
        let customAttribute = NSAttributedString.Key(rawValue: "com.stylizertests.\(UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: ""))")
        NSAttributedString.Key.registerCustomStylizerPlaceholderAttributes([customAttribute])
        return customAttribute
    }()

    private var clickedLink: (Any, NSRange)?

    // MARK: Test Methods

    func testDefaultValues() throws {
        let textField = NSTextField(wrappingLabelWithString: "some string")

        let label1 = StylizedLabel(frame: .zero)
        let label2 = StylizedLabel(attributedString: NSAttributedString(string: "some string", attributes: [.foregroundColor: NSColor.systemBlue]))
        let label3: StylizedLabel

        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: label1, requiringSecureCoding: false)

            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
            unarchiver.requiresSecureCoding = false

            label3 = try XCTUnwrap(unarchiver.decodeObject(of: StylizedLabel.self, forKey: NSKeyedArchiveRootObjectKey))
        }

        // Ensure that both designated initializers initialize these property values to the
        // correct default values.
        for label in [label1, label2, label3] {
            XCTAssertEqual(label.font, textField.font)
            XCTAssertEqual(label.drawsBackground, textField.drawsBackground)
            XCTAssertEqual(label.textColor, textField.textColor)
            XCTAssertEqual(label.isBezeled, textField.isBezeled)
            XCTAssertEqual(label.isEditable, textField.isEditable)
            XCTAssertEqual(label.lineBreakMode, textField.lineBreakMode)
            XCTAssertEqual(label.acceptsFirstResponder, textField.acceptsFirstResponder)
            XCTAssertFalse(label.isSelectable)

            if #available(macOS 10.15, *) {
                XCTAssertEqual(label.lineBreakStrategy, textField.lineBreakStrategy)
            }
        }
    }

    func testBasicLabelProperties() {
        let label = StylizedLabel()

        XCTAssertNil(label.unstylizedAttributedStringValue)
        XCTAssertTrue(label.stylizers.isEmpty)

        //

        label.stringValue = ""

        XCTAssertTrue(label.stringValue.isEmpty)
        XCTAssertEqual(label.attributedStringValue.length, 0)
        XCTAssertNil(label.unstylizedAttributedStringValue)

        //

        label.attributedStringValue = NSAttributedString(string: "")

        XCTAssertTrue(label.stringValue.isEmpty)
        XCTAssertEqual(label.attributedStringValue.length, 0)
        XCTAssertNil(label.unstylizedAttributedStringValue)

        //

        XCTAssertFalse(label.isEditable)
        label.isEditable = true
        XCTAssertFalse(label.isEditable)

        //

        XCTAssertFalse(label.allowsEditingTextAttributes)
        label.allowsEditingTextAttributes = true
        XCTAssertFalse(label.allowsEditingTextAttributes)
    }

    func testSetStringsWithoutStylizers() {
        let unstylizedStringValue = "<b>bold text</b>, _italic text_"
        let unstylizedAttributedStringValue = NSMutableAttributedString(string: unstylizedStringValue)
        unstylizedAttributedStringValue.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 5, length: 17))

        let label = StylizedLabel()

        // No Stylizers, the text shouldn't be changed at all

        label.stringValue = unstylizedStringValue

        XCTAssertEqual(label.stringValue, unstylizedStringValue)
        XCTAssertEqual(label.attributedStringValue, NSAttributedString(string: unstylizedStringValue))
        XCTAssertEqual(label.unstylizedAttributedStringValue, NSAttributedString(string: unstylizedStringValue))

        // No Stylizers, the text shouldn't be changed at all

        label.attributedStringValue = unstylizedAttributedStringValue

        XCTAssertEqual(label.stringValue, unstylizedStringValue)
        XCTAssertEqual(label.attributedStringValue, unstylizedAttributedStringValue)
        XCTAssertEqual(label.unstylizedAttributedStringValue, unstylizedAttributedStringValue)
    }

    func testSetStringsWithHTMLStylizer() {
        let unstylizedStringValue = "<b>bold text</b>, _italic text_"
        let unstylizedAttributedStringValue = NSMutableAttributedString(string: unstylizedStringValue)
        unstylizedAttributedStringValue.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 8, length: 17))

        let label = StylizedLabel()
        label.stylizers = [HTMLStylizer()]

        let stylizedText = "bold text, _italic text_"
        let stylizedAttributedText = NSMutableAttributedString(string: stylizedText)
        label.font?.byAddingSymbolicTraits(.bold).map { stylizedAttributedText.addAttributes([.font: $0], range: NSRange(location: 0, length: 9)) }

        //

        label.stringValue = unstylizedStringValue

        XCTAssertEqual(label.stringValue, stylizedText)
        XCTAssertEqual(label.attributedStringValue, stylizedAttributedText)
        XCTAssertEqual(label.unstylizedAttributedStringValue, NSAttributedString(string: unstylizedStringValue))

        //

        stylizedAttributedText.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 5, length: 13))

        label.attributedStringValue = unstylizedAttributedStringValue

        XCTAssertEqual(label.stringValue, stylizedText)
        XCTAssertEqual(label.attributedStringValue, stylizedAttributedText)
        XCTAssertEqual(label.unstylizedAttributedStringValue, unstylizedAttributedStringValue)
    }

    func testSetStringsWithMarkdownStylizer() {
        let unstylizedStringValue = "<b>bold text</b>, _italic text_"
        let unstylizedAttributedStringValue = NSMutableAttributedString(string: unstylizedStringValue)
        unstylizedAttributedStringValue.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 8, length: 17))

        let label = StylizedLabel()
        label.stylizers = [MarkdownStylizer()]

        let stylizedText = "<b>bold text</b>, italic text"
        let stylizedAttributedText = NSMutableAttributedString(string: stylizedText)
        label.font?.byAddingSymbolicTraits(.italic).map { stylizedAttributedText.addAttributes([.font: $0], range: NSRange(location: 18, length: 11)) }

        //

        label.stringValue = unstylizedStringValue

        XCTAssertEqual(label.stringValue, stylizedText)
        XCTAssertEqual(label.attributedStringValue, stylizedAttributedText)
        XCTAssertEqual(label.unstylizedAttributedStringValue, NSAttributedString(string: unstylizedStringValue))

        //

        stylizedAttributedText.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 8, length: 16))

        label.attributedStringValue = unstylizedAttributedStringValue

        XCTAssertEqual(label.stringValue, stylizedText)
        XCTAssertEqual(label.attributedStringValue, stylizedAttributedText)
        XCTAssertEqual(label.unstylizedAttributedStringValue, unstylizedAttributedStringValue)
    }

    func testSetStringsWithStylizers() {
        let unstylizedStringValue = "<b>bold text</b>, _italic text_"
        let unstylizedAttributedStringValue = NSMutableAttributedString(string: unstylizedStringValue)
        unstylizedAttributedStringValue.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 8, length: 17))

        let label = StylizedLabel()
        label.stylizers = [MarkdownStylizer(), HTMLStylizer()]

        let stylizedText = "bold text, italic text"
        let stylizedAttributedText = NSMutableAttributedString(string: stylizedText)

        label.font?.byAddingSymbolicTraits(.bold).map { stylizedAttributedText.addAttributes([.font: $0], range: NSRange(location: 0, length: 9)) }
        label.font?.byAddingSymbolicTraits(.italic).map { stylizedAttributedText.addAttributes([.font: $0], range: NSRange(location: 11, length: 11)) }

        //

        label.stringValue = unstylizedStringValue

        XCTAssertEqual(label.stringValue, stylizedText)
        XCTAssertEqual(label.attributedStringValue, stylizedAttributedText)
        XCTAssertEqual(label.unstylizedAttributedStringValue, NSAttributedString(string: unstylizedStringValue))

        //

        stylizedAttributedText.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 5, length: 12))

        label.attributedStringValue = unstylizedAttributedStringValue

        XCTAssertEqual(label.stringValue, stylizedText)
        XCTAssertEqual(label.attributedStringValue, stylizedAttributedText)
        XCTAssertEqual(label.unstylizedAttributedStringValue, unstylizedAttributedStringValue)
    }

    func testSetStylizersAfterStrings() {
        let unstylizedStringValue = "<b>bold text</b>, _italic text_"
        let unstylizedAttributedStringValue = NSMutableAttributedString(string: unstylizedStringValue)
        unstylizedAttributedStringValue.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 8, length: 17))

        let label = StylizedLabel()

        let stylizedText = "bold text, italic text"
        let stylizedAttributedText = NSMutableAttributedString(string: stylizedText)

        label.font?.byAddingSymbolicTraits(.bold).map { stylizedAttributedText.addAttributes([.font: $0], range: NSRange(location: 0, length: 9)) }
        label.font?.byAddingSymbolicTraits(.italic).map { stylizedAttributedText.addAttributes([.font: $0], range: NSRange(location: 11, length: 11)) }

        //

        label.stylizers = []
        label.stringValue = unstylizedStringValue
        XCTAssertEqual(label.stringValue, unstylizedStringValue)

        label.stylizers = [HTMLStylizer(), MarkdownStylizer()]

        XCTAssertEqual(label.stringValue, stylizedText)
        XCTAssertEqual(label.attributedStringValue, stylizedAttributedText)
        XCTAssertEqual(label.unstylizedAttributedStringValue, NSAttributedString(string: unstylizedStringValue))

        //

        stylizedAttributedText.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 5, length: 12))

        label.stylizers = []
        label.attributedStringValue = unstylizedAttributedStringValue
        XCTAssertEqual(label.attributedStringValue, unstylizedAttributedStringValue)

        label.stylizers = [HTMLStylizer(), MarkdownStylizer()]

        XCTAssertEqual(label.stringValue, stylizedText)
        XCTAssertEqual(label.attributedStringValue, stylizedAttributedText)
        XCTAssertEqual(label.unstylizedAttributedStringValue, unstylizedAttributedStringValue)
    }

    func testSetFontAfterStrings() {
        let unstylizedStringValue = "<b>bold text</b>, _italic text_"
        let unstylizedAttributedStringValue = NSMutableAttributedString(string: unstylizedStringValue)
        unstylizedAttributedStringValue.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 8, length: 17))

        let label = StylizedLabel()
        label.stylizers = [HTMLStylizer(), MarkdownStylizer()]

        let stylizedText = "bold text, italic text"
        let stylizedAttributedText = NSMutableAttributedString(string: stylizedText)
        let newFont = NSFont.systemFont(ofSize: 35.0)

        newFont.byAddingSymbolicTraits(.bold).map { stylizedAttributedText.addAttributes([.font: $0], range: NSRange(location: 0, length: 9)) }
        newFont.byAddingSymbolicTraits(.italic).map { stylizedAttributedText.addAttributes([.font: $0], range: NSRange(location: 11, length: 11)) }

        //

        label.stringValue = unstylizedStringValue
        label.font = newFont

        XCTAssertEqual(label.stringValue, stylizedText)
        XCTAssertEqual(label.attributedStringValue, stylizedAttributedText)
        XCTAssertEqual(label.unstylizedAttributedStringValue, NSAttributedString(string: unstylizedStringValue))

        //

        stylizedAttributedText.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 5, length: 12))

        label.font = nil
        label.attributedStringValue = unstylizedAttributedStringValue
        label.font = newFont

        XCTAssertEqual(label.stringValue, stylizedText)
        XCTAssertEqual(label.attributedStringValue, stylizedAttributedText)
        XCTAssertEqual(label.unstylizedAttributedStringValue, unstylizedAttributedStringValue)
    }

    func testGestureRecognizersForLinks() {
        let label = StylizedLabel()
        label.stylizers = [MarkdownStylizer()]

        let defaultGestureRecognizers = label.gestureRecognizers

        //

        label.stringValue = "not a link"

        XCTAssertEqual(label.gestureRecognizers, defaultGestureRecognizers)

        //

        label.stringValue = "[link](https://www.apple.com)"

        var gestureRecognizers = Set(label.gestureRecognizers).subtracting(defaultGestureRecognizers)

        XCTAssertEqual(gestureRecognizers.count, 1)
        XCTAssertTrue(gestureRecognizers[gestureRecognizers.startIndex] is NSClickGestureRecognizer)

        //

        label.stringValue = "[new link](https://www.apple.com)"

        gestureRecognizers = Set(label.gestureRecognizers).subtracting(defaultGestureRecognizers)

        XCTAssertEqual(gestureRecognizers.count, 1)
        XCTAssertTrue(gestureRecognizers[gestureRecognizers.startIndex] is NSClickGestureRecognizer)

        //

        label.stringValue = "also not a link"

        XCTAssertEqual(label.gestureRecognizers, defaultGestureRecognizers)
    }

    func testClickOnLink() throws {
        guard #available(macOS 10.11, *) else { throw XCTSkip("StylizedLabel only supports clicking links on macOS 10.11 or later") }
        self.clickedLink = nil

        let label = StylizedLabel()
        label.stylizers = [MarkdownStylizer()]
        label.stringValue = "[link](https://www.apple.com)"

        XCTAssertTrue(label.gestureRecognizers.contains { $0 is NSClickGestureRecognizer })

        if let gestureRecognizer = label.gestureRecognizers.compactMap({ $0 as? NSClickGestureRecognizer }).first {
            let selector = "stylizedLabelClick:".withCString { sel_getUid($0) }
            guard label.responds(to: selector) else {
                XCTFail("Expected StylizedLabel to respond to selector: \(selector)")
                return
            }

            // Simulate StylizedLabel's gesture recognizer successfully recognizing a click
            label.perform(selector, with: gestureRecognizer)

            XCTAssertNil(clickedLink) // No delegate has been set, therefore our delegate method shouldn't have been called
        } else {
            XCTFail("Expected StylizedLabel's gesture recognizers to contain at least one NSClickGestureRecognizer")
        }

        //

        label.stylizerDelegate = self

        if let gestureRecognizer = label.gestureRecognizers.compactMap({ $0 as? NSClickGestureRecognizer }).first {
            let selector = "stylizedLabelClick:".withCString { sel_getUid($0) }
            guard label.responds(to: selector) else {
                XCTFail("Expected StylizedLabel to respond to selector: \(selector)")
                return
            }

            // Simulate StylizedLabel's gesture recognizer successfully recognizing a click
            label.perform(selector, with: gestureRecognizer)

            if let (link, range) = clickedLink {
                if let link = link as? URL {
                    XCTAssertEqual(link.absoluteString, "https://www.apple.com")
                } else if let link = link as? String {
                    XCTAssertEqual(link, "https://www.apple.com")
                } else {
                    XCTFail("Expected the link provided by StylizedLabel to be a String or URL, not \(String(describing: type(of: link)))")
                }

                XCTAssertEqual(range, NSRange(location: 0, length: 4))
            } else {
                XCTFail("Expected StylizedLabel's delegate to get called with a simulated click")
            }
        } else {
            XCTFail("Expected StylizedLabel's gesture recognizers to contain at least one NSClickGestureRecognizer")
        }
    }

    func testOverridingPlaceholderAttributes() {
        //swiftlint:disable nesting
        class DoubleUnderlineStylizer: Stylizer {

            init() {
                super.init(styleInfo: [.init(expression: .init(verifiedPattern: "<double-underline>(.*?)<\\/double-underline>"), replacementTemplate: "$1") { match, string in
                    [AppKitStylizedLabelTests.customAttribute: NSUnderlineStyle.double.rawValue]
                }])
            }
        }
        //swiftlint:enable nesting

        var enumeratedRanges: [NSRange] = []
        let expectedRanges: [NSRange] = [
            NSRange(location: 0, length: 9), NSRange(location: 11, length: 14),
            NSRange(location: 27, length: 11), NSRange(location: 40, length: 16),
            NSRange(location: 58, length: 13), NSRange(location: 73, length: 9),
            NSRange(location: 84, length: 16), NSRange(location: 102, length: 11),
            NSRange(location: 115, length: 9), NSRange(location: 126, length: 14),
            NSRange(location: 142, length: 4)
        ]

        let label = StylizedLabel()
        label.stylizers = [HTMLStylizer(), DoubleUnderlineStylizer()]
        label.stringValue = "<b>bold text</b>, <strong>also bold text</strong>, <i>italic text</i>, <em>also italic text</em>, <del>strikethrough</del>, <ins>underline</ins>, <double-underline>double underline</double-underline>, <sup>superscript</sup>, <p style=\"color:blue;\">blue text</p>, <p style=\"background-color:red;\">red background</p>, <a href=\"https://www.apple.com\" title=\"title\">link</a>"

        label.attributedStringValue.enumerateAttributes(in: label.attributedStringValue.stringRange, options: []) { attributes, range, _ in
            switch range {
            case expectedRanges[0], expectedRanges[1]: // bold
                XCTAssertEqual(attributes.count, 1)
                XCTAssertEqual(attributes[.font] as? NSFont, label.font?.byAddingSymbolicTraits(.bold))
                enumeratedRanges.append(range)

            case expectedRanges[2], expectedRanges[3]: // italic
                XCTAssertEqual(attributes.count, 1)
                XCTAssertEqual(attributes[.font] as? NSFont, label.font?.byAddingSymbolicTraits(.italic))
                enumeratedRanges.append(range)

            case expectedRanges[4]: // strikethrough
                XCTAssertEqual(attributes.count, 1)
                XCTAssertEqual(attributes[.strikethroughStyle] as? Int, NSUnderlineStyle.single.rawValue)
                enumeratedRanges.append(range)

            case expectedRanges[5]: // underline
                XCTAssertEqual(attributes.count, 1)
                XCTAssertEqual(attributes[.underlineStyle] as? Int, NSUnderlineStyle.single.rawValue)
                enumeratedRanges.append(range)

            case expectedRanges[6]: // double-underline
                XCTAssertEqual(attributes.count, 1)
                XCTAssertEqual(attributes[AppKitStylizedLabelTests.customAttribute] as? Int, NSUnderlineStyle.double.rawValue)
                enumeratedRanges.append(range)

            case expectedRanges[7]: // superscript
                XCTAssertEqual(attributes.count, 1)
                XCTAssertEqual(attributes[.superscript] as? Int, 1)
                enumeratedRanges.append(range)

            case expectedRanges[8]: // text color
                XCTAssertEqual(attributes.count, 1)
                XCTAssertEqual(attributes[.foregroundColor] as? NSColor, ColorParser.parseColor(from: "blue"))
                enumeratedRanges.append(range)

            case expectedRanges[9]: // background color
                XCTAssertEqual(attributes.count, 1)
                XCTAssertEqual(attributes[.backgroundColor] as? NSColor, ColorParser.parseColor(from: "red"))
                enumeratedRanges.append(range)

            case expectedRanges[10]: // link
                XCTAssertEqual(attributes.count, 2)
                XCTAssertTrue((attributes[.link] as? URL)?.absoluteString == "https://www.apple.com" || (attributes[.link] as? String) == "https://www.apple.com")
                XCTAssertEqual(attributes[.toolTip] as? String, "title")
                enumeratedRanges.append(range)

            default: break
            }
        }

        XCTAssertEqual(expectedRanges, enumeratedRanges)

        //

        label.stylizerDelegate = self
        label.stringValue = "<b>bold text</b>, <strong>also bold text</strong>, <i>italic text</i>, <em>also italic text</em>, <del>strikethrough</del>, <ins>underline</ins>, <double-underline>double underline</double-underline>, <sup>superscript</sup>, <p style=\"color:blue;\">blue text</p>, <p style=\"background-color:red;\">red background</p>, <a href=\"https://www.apple.com\" title=\"title\">link</a>"

        enumeratedRanges = []
        label.attributedStringValue.enumerateAttributes(in: label.attributedStringValue.stringRange, options: []) { attributes, range, _ in
            switch range {
            case expectedRanges[0], expectedRanges[1]: // bold
                XCTAssertEqual(attributes.count, 1)
                XCTAssertEqual(attributes[.strokeWidth] as? Double, 3.0)
                enumeratedRanges.append(range)

            case expectedRanges[2], expectedRanges[3]: // italic
                XCTAssertEqual(attributes.count, 1)
                XCTAssertEqual(attributes[.baselineOffset] as? Double, -10.0)
                enumeratedRanges.append(range)

            case expectedRanges[4]: // strikethrough
                XCTAssertEqual(attributes.count, 1)
                XCTAssertEqual(attributes[.foregroundColor] as? NSColor, .black)
                enumeratedRanges.append(range)

            case expectedRanges[5]: // underline
                XCTAssertEqual(attributes.count, 1)
                XCTAssertEqual(attributes[.backgroundColor] as? NSColor, .green)
                enumeratedRanges.append(range)

            case expectedRanges[6]: // double-underline
                XCTAssertEqual(attributes.count, 1)
                XCTAssertEqual(attributes[.kern] as? Double, 2.5)
                enumeratedRanges.append(range)

            case expectedRanges[7]: // superscript
                XCTAssertEqual(attributes.count, 1)
                XCTAssertEqual(attributes[.toolTip] as? String, "superscript")
                enumeratedRanges.append(range)

            case expectedRanges[8]: // text color
                XCTAssertEqual(attributes.count, 1)
                XCTAssertEqual(attributes[.superscript] as? Int, 1)
                enumeratedRanges.append(range)

            case expectedRanges[9]: // background color
                XCTAssertEqual(attributes.count, 1)
                XCTAssertEqual(attributes[.verticalGlyphForm] as? Int, 1)
                enumeratedRanges.append(range)

            case expectedRanges[10]: // link
                XCTAssertEqual(attributes.count, 1)
                XCTAssertEqual(attributes[.expansion] as? Double, 0.75)
                enumeratedRanges.append(range)

            default: break
            }
        }

        XCTAssertEqual(expectedRanges, enumeratedRanges)
    }

    // MARK: StylizedLabelDelegate Protocol Requirements

    func label(_ label: StylizedLabel, didClickOnLink link: Any, in range: NSRange) {
        clickedLink = (link, range)
    }

    func label(_ label: StylizedLabel, overridePlaceholderAttribute attribute: NSAttributedString.Key, value: Any?, in range: NSRange, withProposedAttributes proposedAttributes: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any]? {
        switch attribute {
        case .stylizerBold:
            XCTAssertEqual(value as? Int, 0)
            XCTAssertTrue(range == NSRange(location: 0, length: 9) || range == NSRange(location: 11, length: 14))
            XCTAssertEqual(proposedAttributes.count, 1)
            XCTAssertEqual(proposedAttributes[.font] as? NSFont, label.font?.byAddingSymbolicTraits(.bold))

            return [.strokeWidth: 3.0]

        case .stylizerItalics:
            XCTAssertEqual(value as? Int, 0)
            XCTAssertTrue(range == NSRange(location: 27, length: 11) || range == NSRange(location: 40, length: 16))
            XCTAssertEqual(proposedAttributes.count, 1)
            XCTAssertEqual(proposedAttributes[.font] as? NSFont, label.font?.byAddingSymbolicTraits(.italic))

            return [.baselineOffset: -10.0]

        case .stylizerStrikethrough:
            XCTAssertEqual(value as? Int, 0)
            XCTAssertEqual(range, NSRange(location: 58, length: 13))
            XCTAssertEqual(proposedAttributes.count, 1)
            XCTAssertEqual(proposedAttributes[.strikethroughStyle] as? Int, NSUnderlineStyle.single.rawValue)

            return [.foregroundColor: NSColor.black]

        case .stylizerUnderline:
            XCTAssertEqual(value as? Int, 0)
            XCTAssertEqual(range, NSRange(location: 73, length: 9))
            XCTAssertEqual(proposedAttributes.count, 1)
            XCTAssertEqual(proposedAttributes[.underlineStyle] as? Int, NSUnderlineStyle.single.rawValue)

            return [.backgroundColor: NSColor.green]

        case AppKitStylizedLabelTests.customAttribute:
            XCTAssertEqual(value as? Int, NSUnderlineStyle.double.rawValue)
            XCTAssertEqual(range, NSRange(location: 84, length: 16))
            XCTAssertTrue(proposedAttributes.isEmpty)

            return [.kern: 2.5]

        case .stylizerSuperscript:
            XCTAssertEqual(value as? Int, 0)
            XCTAssertEqual(range, NSRange(location: 102, length: 11))
            XCTAssertEqual(proposedAttributes.count, 1)
            XCTAssertEqual(proposedAttributes[.superscript] as? Int, 1)

            return [.toolTip: "superscript"]

        case .stylizerTextColor:
            let color = ColorParser.parseColor(from: "blue")

            XCTAssertTrue(value is NSColor)
            XCTAssertEqual(value as? NSColor, color)
            XCTAssertEqual(range, NSRange(location: 115, length: 9))
            XCTAssertEqual(proposedAttributes.count, 1)
            XCTAssertEqual(proposedAttributes[.foregroundColor] as? NSColor, color)

            return [.superscript: 1]

        case .stylizerBackgroundColor:
            let color = ColorParser.parseColor(from: "red")

            XCTAssertTrue(value is NSColor)
            XCTAssertEqual(value as? NSColor, color)
            XCTAssertEqual(range, NSRange(location: 126, length: 14))
            XCTAssertEqual(proposedAttributes.count, 1)
            XCTAssertEqual(proposedAttributes[.backgroundColor] as? NSColor, color)

            return [.verticalGlyphForm: 1]

        case .stylizerLink:
            XCTAssertEqual(value as? [String], ["https://www.apple.com", "title"])
            XCTAssertEqual(range, NSRange(location: 142, length: 4))
            XCTAssertEqual(proposedAttributes.count, 2)
            XCTAssertTrue((proposedAttributes[.link] as? URL)?.absoluteString == "https://www.apple.com" || (proposedAttributes[.link] as? String) == "https://www.apple.com")
            XCTAssertTrue((proposedAttributes[.toolTip] as? String) == "title")

            return [.expansion: 0.75]

        default:
            XCTFail("Encountered an unexpected attribute: \(attribute)")
            return [:]
        }
    }
}
#endif // #if canImport(AppKit) && !targetEnvironment(macCatalyst)
