//
//  UIKitStylizedLabelTests.swift
//  Stylizer
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

#if canImport(UIKit) && !os(watchOS)
@testable import Stylizer
import UIKit
import XCTest

//swiftlint:disable function_body_length

// MARK: - UIKitStlyizedLabelTests Definition

class UIKitStylizedLabelTests: XCTestCase, StylizedLabelDelegate {

    // MARK: Private Properties

    private static let customAttribute: NSAttributedString.Key = {
        let customAttribute = NSAttributedString.Key(rawValue: "com.stylizertests.\(UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: ""))")
        NSAttributedString.Key.registerCustomStylizerPlaceholderAttributes([customAttribute])
        return customAttribute
    }()

    private var tappedLink: (Any, NSRange)?

    // MARK: Test Methods

    func testDefaultValues() throws {
        let uiLabel = UILabel(frame: .zero)

        let label1 = StylizedLabel(frame: .zero)
        let label2: StylizedLabel

        do {
            let data: Data
            let unarchiver: NSKeyedUnarchiver

            if #available(iOS 11.0, tvOS 11.0, *) {
                data = try NSKeyedArchiver.archivedData(withRootObject: label1, requiringSecureCoding: false)
                unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
            } else {
                data = NSKeyedArchiver.archivedData(withRootObject: label1)
                unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            }

            unarchiver.requiresSecureCoding = false
            label2 = try XCTUnwrap(unarchiver.decodeObject(of: StylizedLabel.self, forKey: NSKeyedArchiveRootObjectKey))
        }

        for label in [label1, label2] {
            XCTAssertEqual(label.font, uiLabel.font)
        }
    }

    func testBasicLabelProperties() {
        let label = StylizedLabel()

        XCTAssertNil(label.unstylizedAttributedText)
        XCTAssertTrue(label.stylizers.isEmpty)

        //

        label.text = nil

        XCTAssertNil(label.text)
        XCTAssertNil(label.attributedText)
        XCTAssertNil(label.unstylizedAttributedText)

        //

        label.attributedText = nil

        XCTAssertNil(label.text)
        XCTAssertNil(label.attributedText)
        XCTAssertNil(label.unstylizedAttributedText)
    }

    func testSetStringsWithoutStylizers() {
        let unstylizedText = "<b>bold text</b>, _italic text_"
        let unstylizedAttributedText = NSMutableAttributedString(string: unstylizedText)
        unstylizedAttributedText.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 5, length: 17))

        let label = StylizedLabel()

        // No Stylizers, the text shouldn't be changed at all

        label.text = unstylizedText

        XCTAssertEqual(label.text, unstylizedText)
        XCTAssertEqual(label.attributedText, NSAttributedString(string: unstylizedText))
        XCTAssertEqual(label.unstylizedAttributedText, NSAttributedString(string: unstylizedText))

        // No Stylizers, the text shouldn't be changed at all

        label.attributedText = unstylizedAttributedText

        XCTAssertEqual(label.text, unstylizedText)
        XCTAssertEqual(label.attributedText, unstylizedAttributedText)
        XCTAssertEqual(label.unstylizedAttributedText, unstylizedAttributedText)
    }

    func testSetStringsWithHTMLStylizer() {
        let unstylizedText = "<b>bold text</b>, _italic text_"
        let unstylizedAttributedText = NSMutableAttributedString(string: unstylizedText)
        unstylizedAttributedText.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 8, length: 17))

        let label = StylizedLabel()
        label.stylizers = [HTMLStylizer()]

        let stylizedText = "bold text, _italic text_"
        let stylizedAttributedText = NSMutableAttributedString(string: stylizedText)
        label.font.byAddingSymbolicTraits(.traitBold).map { stylizedAttributedText.addAttributes([.font: $0], range: NSRange(location: 0, length: 9)) }

        //

        label.text = unstylizedText

        XCTAssertEqual(label.text, stylizedText)
        XCTAssertEqual(label.attributedText, stylizedAttributedText)
        XCTAssertEqual(label.unstylizedAttributedText, NSAttributedString(string: unstylizedText))

        //

        stylizedAttributedText.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 5, length: 13))

        label.attributedText = unstylizedAttributedText

        XCTAssertEqual(label.text, stylizedText)
        XCTAssertEqual(label.attributedText, stylizedAttributedText)
        XCTAssertEqual(label.unstylizedAttributedText, unstylizedAttributedText)
    }

    func testSetStringsWithMarkdownStylizer() {
        let unstylizedText = "<b>bold text</b>, _italic text_"
        let unstylizedAttributedText = NSMutableAttributedString(string: unstylizedText)
        unstylizedAttributedText.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 8, length: 17))

        let label = StylizedLabel()
        label.stylizers = [MarkdownStylizer()]

        let stylizedText = "<b>bold text</b>, italic text"
        let stylizedAttributedText = NSMutableAttributedString(string: stylizedText)
        label.font.byAddingSymbolicTraits(.traitItalic).map { stylizedAttributedText.addAttributes([.font: $0], range: NSRange(location: 18, length: 11)) }

        //

        label.text = unstylizedText

        XCTAssertEqual(label.text, stylizedText)
        XCTAssertEqual(label.attributedText, stylizedAttributedText)
        XCTAssertEqual(label.unstylizedAttributedText, NSAttributedString(string: unstylizedText))

        //

        stylizedAttributedText.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 8, length: 16))

        label.attributedText = unstylizedAttributedText

        XCTAssertEqual(label.text, stylizedText)
        XCTAssertEqual(label.attributedText, stylizedAttributedText)
        XCTAssertEqual(label.unstylizedAttributedText, unstylizedAttributedText)
    }

    func testSetStringsWithStylizers() {
        let unstylizedText = "<b>bold text</b>, _italic text_"
        let unstylizedAttributedText = NSMutableAttributedString(string: unstylizedText)
        unstylizedAttributedText.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 8, length: 17))

        let label = StylizedLabel()
        label.stylizers = [MarkdownStylizer(), HTMLStylizer()]

        let stylizedText = "bold text, italic text"
        let stylizedAttributedText = NSMutableAttributedString(string: stylizedText)

        label.font?.byAddingSymbolicTraits(.traitBold).map { stylizedAttributedText.addAttributes([.font: $0], range: NSRange(location: 0, length: 9)) }
        label.font?.byAddingSymbolicTraits(.traitItalic).map { stylizedAttributedText.addAttributes([.font: $0], range: NSRange(location: 11, length: 11)) }

        //

        label.text = unstylizedText

        XCTAssertEqual(label.text, stylizedText)
        XCTAssertEqual(label.attributedText, stylizedAttributedText)
        XCTAssertEqual(label.unstylizedAttributedText, NSAttributedString(string: unstylizedText))

        //

        stylizedAttributedText.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 5, length: 12))

        label.attributedText = unstylizedAttributedText

        XCTAssertEqual(label.text, stylizedText)
        XCTAssertEqual(label.attributedText, stylizedAttributedText)
        XCTAssertEqual(label.unstylizedAttributedText, unstylizedAttributedText)
    }

    func testSetStylizersAfterStrings() {
        let unstylizedText = "<b>bold text</b>, _italic text_"
        let unstylizedAttributedText = NSMutableAttributedString(string: unstylizedText)
        unstylizedAttributedText.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 8, length: 17))

        let label = StylizedLabel()

        let stylizedText = "bold text, italic text"
        let stylizedAttributedText = NSMutableAttributedString(string: stylizedText)

        label.font?.byAddingSymbolicTraits(.traitBold).map { stylizedAttributedText.addAttributes([.font: $0], range: NSRange(location: 0, length: 9)) }
        label.font?.byAddingSymbolicTraits(.traitItalic).map { stylizedAttributedText.addAttributes([.font: $0], range: NSRange(location: 11, length: 11)) }

        //

        label.stylizers = []
        label.text = unstylizedText
        XCTAssertEqual(label.text, unstylizedText)

        label.stylizers = [HTMLStylizer(), MarkdownStylizer()]

        XCTAssertEqual(label.text, stylizedText)
        XCTAssertEqual(label.attributedText, stylizedAttributedText)
        XCTAssertEqual(label.unstylizedAttributedText, NSAttributedString(string: unstylizedText))

        //

        stylizedAttributedText.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 5, length: 12))

        label.stylizers = []
        label.attributedText = unstylizedAttributedText
        XCTAssertEqual(label.attributedText, unstylizedAttributedText)

        label.stylizers = [HTMLStylizer(), MarkdownStylizer()]

        XCTAssertEqual(label.text, stylizedText)
        XCTAssertEqual(label.attributedText, stylizedAttributedText)
        XCTAssertEqual(label.unstylizedAttributedText, unstylizedAttributedText)
    }

    func testSetFontAfterStrings() {
        let unstylizedText = "<b>bold text</b>, _italic text_"
        let unstylizedAttributedText = NSMutableAttributedString(string: unstylizedText)
        unstylizedAttributedText.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 8, length: 17))

        let label = StylizedLabel()
        label.stylizers = [HTMLStylizer(), MarkdownStylizer()]

        let stylizedText = "bold text, italic text"
        let stylizedAttributedText = NSMutableAttributedString(string: stylizedText)
        let newFont = UIFont.systemFont(ofSize: 35.0)

        newFont.byAddingSymbolicTraits(.traitBold).map { stylizedAttributedText.addAttributes([.font: $0], range: NSRange(location: 0, length: 9)) }
        newFont.byAddingSymbolicTraits(.traitItalic).map { stylizedAttributedText.addAttributes([.font: $0], range: NSRange(location: 11, length: 11)) }

        //

        label.text = unstylizedText
        label.font = newFont

        XCTAssertEqual(label.text, stylizedText)
        XCTAssertEqual(label.attributedText, stylizedAttributedText)
        XCTAssertEqual(label.unstylizedAttributedText, NSAttributedString(string: unstylizedText))

        //

        stylizedAttributedText.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 5, length: 12))

        label.font = nil
        label.attributedText = unstylizedAttributedText
        label.font = newFont

        XCTAssertEqual(label.text, stylizedText)
        XCTAssertEqual(label.attributedText, stylizedAttributedText)
        XCTAssertEqual(label.unstylizedAttributedText, unstylizedAttributedText)
    }

    func testGestureRecognizersForLinks() {
        let label = StylizedLabel()
        label.stylizers = [MarkdownStylizer()]

        let defaultGestureRecognizers = label.gestureRecognizers ?? []

        //

        label.text = "not a link"

        XCTAssertEqual(label.gestureRecognizers ?? [], defaultGestureRecognizers)

        //

        label.text = "[link](https://www.apple.com)"

        var gestureRecognizers = Set(label.gestureRecognizers ?? []).subtracting(defaultGestureRecognizers)

        XCTAssertEqual(gestureRecognizers.count, 1)
        XCTAssertTrue(gestureRecognizers[gestureRecognizers.startIndex] is UITapGestureRecognizer)

        //

        label.text = "[new link](https://www.apple.com)"

        gestureRecognizers = Set(label.gestureRecognizers ?? []).subtracting(defaultGestureRecognizers)

        XCTAssertEqual(gestureRecognizers.count, 1)
        XCTAssertTrue(gestureRecognizers[gestureRecognizers.startIndex] is UITapGestureRecognizer)

        //

        label.text = "also not a link"

        XCTAssertEqual(label.gestureRecognizers, defaultGestureRecognizers)
    }

    func testTapOnLink() throws {
        self.tappedLink = nil

        let label = StylizedLabel()
        label.stylizers = [MarkdownStylizer()]
        label.text = "[link](https://www.apple.com)"

        XCTAssertEqual(label.gestureRecognizers?.contains { $0 is UITapGestureRecognizer }, true)

        if let gestureRecognizer = label.gestureRecognizers?.compactMap({ $0 as? UITapGestureRecognizer }).first {
            let selector = "stylizedLabelTap:".withCString { sel_getUid($0) }
            guard label.responds(to: selector) else {
                XCTFail("Expected StylizedLabel to respond to selector: \(selector)")
                return
            }

            // Simulate StylizedLabel's gesture recognizer successfully recognizing a tap
            label.perform(selector, with: gestureRecognizer)

            XCTAssertNil(tappedLink) // No delegate has been set, therefore our delegate method shouldn't have been called
        } else {
            XCTFail("Expected StylizedLabel's gesture recognizers to contain at least one UITapGestureRecognizer")
        }

        //

        label.stylizerDelegate = self

        if let gestureRecognizer = label.gestureRecognizers?.compactMap({ $0 as? UITapGestureRecognizer }).first {
            let selector = "stylizedLabelTap:".withCString { sel_getUid($0) }
            guard label.responds(to: selector) else {
                XCTFail("Expected StylizedLabel to respond to selector: \(selector)")
                return
            }

            // Simulate StylizedLabel's gesture recognizer successfully recognizing a click
            label.perform(selector, with: gestureRecognizer)

            if let (link, range) = tappedLink {
                if let link = link as? URL {
                    XCTAssertEqual(link.absoluteString, "https://www.apple.com")
                } else if let link = link as? String {
                    XCTAssertEqual(link, "https://www.apple.com")
                } else {
                    XCTFail("Expected the link provided by StylizedLabel to be a String or URL, not \(String(describing: type(of: link)))")
                }

                XCTAssertEqual(range, NSRange(location: 0, length: 4))
            } else {
                XCTFail("Expected StylizedLabel's delegate to get called with a simulated tap")
            }
        } else {
            XCTFail("Expected StylizedLabel's gesture recognizers to contain at least one UITapGestureRecognizer")
        }
    }

    func testOverridingPlaceholderAttributes() {
        //swiftlint:disable nesting
        class DoubleUnderlineStylizer: Stylizer {

            init() {
                super.init(styleInfo: [.init(expression: .init(verifiedPattern: "<double-underline>(.*?)<\\/double-underline>"), replacementTemplate: "$1") { match, string in
                    [UIKitStylizedLabelTests.customAttribute: NSUnderlineStyle.double.rawValue]
                }])
            }
        }
        //swiftlint:enable nesting

        var enumeratedRanges: [NSRange] = []
        var expectedRanges: [NSRange] = [
            NSRange(location: 0, length: 9), NSRange(location: 11, length: 14),
            NSRange(location: 27, length: 11), NSRange(location: 40, length: 16),
            NSRange(location: 58, length: 13), NSRange(location: 73, length: 9),
            NSRange(location: 84, length: 16), NSRange(location: 100, length: 15),
            NSRange(location: 115, length: 9), NSRange(location: 126, length: 14),
            NSRange(location: 142, length: 4)
        ]

        let label = StylizedLabel()
        label.stylizers = [HTMLStylizer(), DoubleUnderlineStylizer()]
        label.text = "<b>bold text</b>, <strong>also bold text</strong>, <i>italic text</i>, <em>also italic text</em>, <del>strikethrough</del>, <ins>underline</ins>, <double-underline>double underline</double-underline>, <sup>superscript</sup>, <p style=\"color:blue;\">blue text</p>, <p style=\"background-color:red;\">red background</p>, <a href=\"https://www.apple.com\" title=\"title\">link</a>"

        label.attributedText?.enumerateAttributes(in: label.attributedText?.stringRange ?? NSRange(location: 0, length: 0), options: []) { attributes, range, _ in
            if let index = expectedRanges.firstIndex(of: range) {
                switch index {
                case 0, 1: // bold
                    XCTAssertEqual(attributes.count, 1)
                    XCTAssertEqual(attributes[.font] as? UIFont, label.font?.byAddingSymbolicTraits(.bold))
                    enumeratedRanges.append(range)

                case 2, 3: // italic
                    XCTAssertEqual(attributes.count, 1)
                    XCTAssertEqual(attributes[.font] as? UIFont, label.font?.byAddingSymbolicTraits(.italic))
                    enumeratedRanges.append(range)

                case 4: // strikethrough
                    XCTAssertEqual(attributes.count, 1)
                    XCTAssertEqual(attributes[.strikethroughStyle] as? Int, NSUnderlineStyle.single.rawValue)
                    enumeratedRanges.append(range)

                case 5: // underline
                    XCTAssertEqual(attributes.count, 1)
                    XCTAssertEqual(attributes[.underlineStyle] as? Int, NSUnderlineStyle.single.rawValue)
                    enumeratedRanges.append(range)

                case 6: // double-underline
                    XCTAssertEqual(attributes.count, 1)
                    XCTAssertEqual(attributes[UIKitStylizedLabelTests.customAttribute] as? Int, NSUnderlineStyle.double.rawValue)
                    enumeratedRanges.append(range)

                case 7: // superscript
                    XCTAssertEqual(attributes.count, 0)
                    enumeratedRanges.append(range)

                case 8: // text color
                    XCTAssertEqual(attributes.count, 1)
                    XCTAssertEqual(attributes[.foregroundColor] as? UIColor, ColorParser.parseColor(from: "blue"))
                    enumeratedRanges.append(range)

                case 9: // background color
                    XCTAssertEqual(attributes.count, 1)
                    XCTAssertEqual(attributes[.backgroundColor] as? UIColor, ColorParser.parseColor(from: "red"))
                    enumeratedRanges.append(range)

                case 10: // link
                    XCTAssertEqual(attributes.count, 1)
                    XCTAssertTrue((attributes[.link] as? URL)?.absoluteString == "https://www.apple.com" || (attributes[.link] as? String) == "https://www.apple.com")
                    enumeratedRanges.append(range)

                default: break
                }
            }
        }

        XCTAssertEqual(expectedRanges, enumeratedRanges)

        //

        label.stylizerDelegate = self
        label.text = "<b>bold text</b>, <strong>also bold text</strong>, <i>italic text</i>, <em>also italic text</em>, <del>strikethrough</del>, <ins>underline</ins>, <double-underline>double underline</double-underline>, <sup>superscript</sup>, <p style=\"color:blue;\">blue text</p>, <p style=\"background-color:red;\">red background</p>, <a href=\"https://www.apple.com\" title=\"title\">link</a>"

        enumeratedRanges = []
        expectedRanges[7] = NSRange(location: 102, length: 11)

        label.attributedText?.enumerateAttributes(in: label.attributedText?.stringRange ?? NSRange(location: 0, length: 0), options: []) { attributes, range, _ in
            if let index = expectedRanges.firstIndex(of: range) {
                switch index {
                case 0, 1: // bold
                    XCTAssertEqual(attributes.count, 1)
                    XCTAssertEqual(attributes[.strokeWidth] as? Double, 3.0)
                    enumeratedRanges.append(range)

                case 2, 3: // italic
                    XCTAssertEqual(attributes.count, 1)
                    XCTAssertEqual(attributes[.baselineOffset] as? Double, -10.0)
                    enumeratedRanges.append(range)

                case 4: // strikethrough
                    XCTAssertEqual(attributes.count, 1)
                    XCTAssertEqual(attributes[.foregroundColor] as? UIColor, .black)
                    enumeratedRanges.append(range)

                case 5: // underline
                    XCTAssertEqual(attributes.count, 1)
                    XCTAssertEqual(attributes[.backgroundColor] as? UIColor, .green)
                    enumeratedRanges.append(range)

                case 6: // double-underline
                    XCTAssertEqual(attributes.count, 1)
                    XCTAssertEqual(attributes[.kern] as? Double, 2.5)
                    enumeratedRanges.append(range)

                case 7: // superscript
                    XCTAssertEqual(attributes.count, 1)
                    XCTAssertEqual(attributes[.obliqueness] as? Double, 3.14159)
                    enumeratedRanges.append(range)

                case 8: // text color
                    XCTAssertEqual(attributes.count, 1)
                    XCTAssertEqual(attributes[.ligature] as? Int, 1)
                    enumeratedRanges.append(range)

                case 9: // background color
                    XCTAssertEqual(attributes.count, 1)
                    XCTAssertEqual(attributes[.verticalGlyphForm] as? Int, 1)
                    enumeratedRanges.append(range)

                case 10: // link
                    XCTAssertEqual(attributes.count, 1)
                    XCTAssertEqual(attributes[.expansion] as? Double, 0.75)
                    enumeratedRanges.append(range)

                default: break
                }
            }
        }

        XCTAssertEqual(expectedRanges, enumeratedRanges)
    }

    // MARK: StylizedLabelDelegate Protocol Requirements

    func label(_ label: StylizedLabel, didTapOnLink link: Any, in range: NSRange) {
        tappedLink = (link, range)
    }

    func label(_ label: StylizedLabel, overridePlaceholderAttribute attribute: NSAttributedString.Key, value: Any?, in range: NSRange, withProposedAttributes proposedAttributes: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any]? {
        switch attribute {
        case .stylizerBold:
            XCTAssertEqual(value as? Int, 0)
            XCTAssertTrue(range == NSRange(location: 0, length: 9) || range == NSRange(location: 11, length: 14))
            XCTAssertEqual(proposedAttributes.count, 1)
            XCTAssertEqual(proposedAttributes[.font] as? UIFont, label.font?.byAddingSymbolicTraits(.bold))

            return [.strokeWidth: 3.0]

        case .stylizerItalics:
            XCTAssertEqual(value as? Int, 0)
            XCTAssertTrue(range == NSRange(location: 27, length: 11) || range == NSRange(location: 40, length: 16))
            XCTAssertEqual(proposedAttributes.count, 1)
            XCTAssertEqual(proposedAttributes[.font] as? UIFont, label.font?.byAddingSymbolicTraits(.italic))

            return [.baselineOffset: -10.0]

        case .stylizerStrikethrough:
            XCTAssertEqual(value as? Int, 0)
            XCTAssertEqual(range, NSRange(location: 58, length: 13))
            XCTAssertEqual(proposedAttributes.count, 1)
            XCTAssertEqual(proposedAttributes[.strikethroughStyle] as? Int, NSUnderlineStyle.single.rawValue)

            return [.foregroundColor: UIColor.black]

        case .stylizerUnderline:
            XCTAssertEqual(value as? Int, 0)
            XCTAssertEqual(range, NSRange(location: 73, length: 9))
            XCTAssertEqual(proposedAttributes.count, 1)
            XCTAssertEqual(proposedAttributes[.underlineStyle] as? Int, NSUnderlineStyle.single.rawValue)

            return [.backgroundColor: UIColor.green]

        case UIKitStylizedLabelTests.customAttribute:
            XCTAssertEqual(value as? Int, NSUnderlineStyle.double.rawValue)
            XCTAssertEqual(range, NSRange(location: 84, length: 16))
            XCTAssertTrue(proposedAttributes.isEmpty)

            return [.kern: 2.5]

        case .stylizerSuperscript:
            XCTAssertEqual(value as? Int, 0)
            XCTAssertEqual(range, NSRange(location: 102, length: 11))
            XCTAssertTrue(proposedAttributes.isEmpty)

            return [.obliqueness: 3.14159]

        case .stylizerTextColor:
            let color = ColorParser.parseColor(from: "blue")

            XCTAssertTrue(value is UIColor)
            XCTAssertEqual(value as? UIColor, color)
            XCTAssertEqual(range, NSRange(location: 115, length: 9))
            XCTAssertEqual(proposedAttributes.count, 1)
            XCTAssertEqual(proposedAttributes[.foregroundColor] as? UIColor, color)

            return [.ligature: 1]

        case .stylizerBackgroundColor:
            let color = ColorParser.parseColor(from: "red")

            XCTAssertTrue(value is UIColor)
            XCTAssertEqual(value as? UIColor, color)
            XCTAssertEqual(range, NSRange(location: 126, length: 14))
            XCTAssertEqual(proposedAttributes.count, 1)
            XCTAssertEqual(proposedAttributes[.backgroundColor] as? UIColor, color)

            return [.verticalGlyphForm: 1]

        case .stylizerLink:
            XCTAssertEqual(value as? [String], ["https://www.apple.com", "title"])
            XCTAssertEqual(range, NSRange(location: 142, length: 4))
            XCTAssertEqual(proposedAttributes.count, 1)
            XCTAssertTrue((proposedAttributes[.link] as? URL)?.absoluteString == "https://www.apple.com" || (proposedAttributes[.link] as? String) == "https://www.apple.com")

            return [.expansion: 0.75]

        default:
            XCTFail("Encountered an unexpected attribute: \(attribute)")
            return [:]
        }
    }
}
#endif // #if canImport(UIKit) && !os(watchOS)
