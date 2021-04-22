//
//  StylizerTestCase.swift
//  Stylizer
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

#if !os(watchOS)
@testable import Stylizer
import XCTest

// MARK: - StylizerTestCase Definition

class StylizerTestCase: XCTestCase {

    // MARK: Methods

    class func allCombinations<C, T>(of elements: C) -> [[T]] where C: Collection, C.Element == T {
        func recursiveCombine(current: [[T]], remaining: [T]) -> [[T]] {
            guard !remaining.isEmpty else { return current }
            var remaining = remaining

            let element = remaining.removeFirst()
            let combinations = current + current.map { $0 + [element] }

            return recursiveCombine(current: combinations, remaining: remaining)
        }

        return recursiveCombine(current: [[]], remaining: toArray(elements)).filter { !$0.isEmpty }
    }

    class func iterateAllPermutations<C>(for styles: C, using block: (String, [String]) -> Void) where C: Collection, C.Element: PatternStringsConvertible, C.Element: Hashable, C.Element: CaseIterable {
        let inputStyles = Set(styles).sorted { $0.patternStrings.text < $1.patternStrings.text }
        let permutedStyles = allPermutations(of: inputStyles)

        DispatchQueue.concurrentPerform(iterations: permutedStyles.count) { i in
            let styles = permutedStyles[i]
            let key = styles.map { $0.patternStrings.text }.joined(separator: ", ")
            let values: [[String]] = styles.reduce(into: [[]]) { result, style in
                result = result.reduce(into: []) { next, current in
                    if inputStyles.contains(style) {
                        style.patternStrings.patterns.forEach { next.append(current + [$0]) }
                    } else {
                        next.append(current + [style.patternStrings.text])
                    }
                }
            }

            block(key, values.map { $0.joined(separator: ", ") })
        }
    }

    class func iterateAllNestedPermutations<C>(for styles: C, using block: (String, [String]) -> Void) where C: Collection, C.Element: NestableStringsConvertible, C.Element: Hashable, C.Element: CaseIterable {
        let inputStyles = Set(styles).sorted { $0.nestableStrings.text < $1.nestableStrings.text }
        let permutedStyles = allPermutations(of: toArray(inputStyles))

        DispatchQueue.concurrentPerform(iterations: permutedStyles.count) { i in
            let styles = permutedStyles[i]
            let key = styles.map { $0.nestableStrings.text }.joined(separator: ", ")
            let values: [[String]] = styles.reduce(into: [[]]) { result, style in
                result = result.reduce(into: []) { next, current in
                    if inputStyles.contains(style) {
                        if C.Element.checkForOverlap {
                            style.nestableStrings.patterns.forEach { pattern in
                                if current.first(where: { $0.first == pattern.first }) == nil {
                                    next.append(current + [pattern])
                                }
                            }
                        } else {
                            style.nestableStrings.patterns.forEach { next.append(current + [$0]) }
                        }
                    } else {
                        next.append(current + [style.nestableStrings.text])
                    }
                }
            }

            block(key, values.map { $0.reduce("") { $0.contains("%@") ? $0.replacingOccurrences(of: "%@", with: ", \($1)") : $1 }.replacingOccurrences(of: "%@", with: "") })
        }
    }

    //

    //swiftlint:disable identifier_name
    func AssertAttributedString(_ attributedString: NSAttributedString, containsAttribute attribute: NSAttributedString.Key, inRange range: NSRange, file: StaticString = #file, line: UInt = #line) {
        assertStylizerAttribute(attribute, file: file, line: line)

        var attributeRange = NSRange(location: 0, length: 0)
        let attribute = attributedString.attribute(attribute, at: range.location, longestEffectiveRange: &attributeRange, in: attributedString.stringRange)

        XCTAssertEqual(range, attributeRange, file: file, line: line)
        XCTAssertNotNil(attribute, file: file, line: line)
    }

    func AssertAttributedString<T>(_ attributedString: NSAttributedString, containsAttribute attribute: (key: NSAttributedString.Key, value: T), inRange range: NSRange, file: StaticString = #file, line: UInt = #line) where T: Equatable {
        AssertAttributedString(attributedString, containsAttribute: (attribute.key, attribute.value, nil), inRange: range, file: file, line: line)
    }

    //swiftlint:disable large_tuple
    func AssertAttributedString<T>(_ attributedString: NSAttributedString, containsAttribute attribute: (key: NSAttributedString.Key, value: T, alternateValue: T?), inRange range: NSRange, file: StaticString = #file, line: UInt = #line) where T: Equatable {
        assertStylizerAttribute(attribute.key, file: file, line: line)

        var attributeRange = NSRange(location: 0, length: 0)
        let value = attributedString.attribute(attribute.key, at: range.location, longestEffectiveRange: &attributeRange, in: attributedString.stringRange)

        XCTAssertEqual(range, attributeRange, file: file, line: line)

        if let value = value as? T {
            if value != attribute.value, let alternateValue = attribute.alternateValue {
                XCTAssertEqual(value, alternateValue)
            } else {
                XCTAssertEqual(value, attribute.value)
            }
        } else {
            XCTFail("No attribute value of type \(String(describing: T.self)) found for attribute key (\(attribute.key)) in range \(range)", file: file, line: line)
        }
    }
    //swiftlint:enable large_tuple

    func AssertAttributedString(_ attributedString: NSAttributedString, doesNotContainAttribute attribute: NSAttributedString.Key, inRange range: NSRange, file: StaticString = #file, line: UInt = #line) {
        assertStylizerAttribute(attribute, file: file, line: line)

        var i = range.lowerBound
        while i < range.upperBound {
            var effectiveRange = NSRange(location: 0, length: 0)
            XCTAssertNil(attributedString.attribute(attribute, at: i, longestEffectiveRange: &effectiveRange, in: attributedString.stringRange))

            if effectiveRange.upperBound > i {
                i = effectiveRange.upperBound
            } else {
                i += 1
            }
        }
    }
    //swiftlint:enable identifier_name

    // MARK: Private Methods

    @inline(__always)
    private class func toArray<C, T>(_ collection: C) -> [T] where C: Collection, C.Element == T {
        return (collection as? [T]) ?? Array(collection)
    }

    private class func allPermutations<C>(of elements: C) -> [[C.Element]] where C: Collection {
        func recursivePermute(current: [C.Element], remaining: [C.Element]) -> [[C.Element]] {
            guard !remaining.isEmpty else { return [current] }
            var permutations: [[C.Element]] = []

            for i in 0 ..< remaining.count {
                var remaining = remaining
                let element = remaining.remove(at: i)

                permutations.append(contentsOf: recursivePermute(current: (current + [element]), remaining: remaining))
            }

            return permutations
        }

        return recursivePermute(current: [], remaining: toArray(elements))
    }

    private func assertStylizerAttribute(_ attribute: NSAttributedString.Key, file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(NSAttributedString.Key.predefinedStylizerPlaceholderAttributes.contains(attribute), "Only able to assert using stylizer predefined attributes", file: file, line: line)
    }
}

// MARK: - PatternStringsConvertible Definition

protocol PatternStringsConvertible {

    var patternStrings: (text: String, patterns: [String]) { get }
}

// MARK: - PatternStringsConvertible Protocol Conformances

extension MarkdownStylizer.Style: PatternStringsConvertible {

    var patternStrings: (text: String, patterns: [String]) {
        let strings: (String, [String])
        switch self {
        case .bold: strings = ("bold", ["**bold**", "__bold__"])
        case .italics: strings = ("italics", ["*italics*", "_italics_"])
        case .strikethrough: strings = ("strikethrough", ["~~strikethrough~~"])
        case .link: strings = ("link", ["[link](https://link.com)", "[link](https://link.com \"optional\")"])
        }

        return strings
    }
}

extension HTMLStylizer.Style: PatternStringsConvertible {

    var patternStrings: (text: String, patterns: [String]) {
        let strings: (String, [String])
        switch self {
        case .bold: strings = ("bold", ["<b>bold</b>", "<strong>bold</strong>"])
        case .italics: strings = ("italics", ["<i>italics</i>", "<em>italics</em>"])
        case .strikethrough: strings = ("strikethrough", ["<del>strikethrough</del>"])
        case .underline: strings = ("underline", ["<ins>underline</ins>"])
        case .superscript: strings = ("superscript", ["<sup>superscript</sup>"])
        case .textColor: strings = ("textcolor", ["<p style=\"color:crimson;\">textcolor</p>"])
        case .backgroundColor: strings = ("backgroundcolor", ["<p style=\"background-color:crimson;\">backgroundcolor</p>"])
        case .link: strings = ("link", ["<a href=\"https://link.com\">link</a>", "<a href=\"https://link.com\" title=\"optional\">link</a>"])
        }

        return strings
    }
}

// MARK: - PatternStringsConvertible Definition

protocol NestableStringsConvertible {

    static var checkForOverlap: Bool { get }

    var nestableStrings: (text: String, patterns: [String]) { get }
}

// MARK: - NestableStringsConvertible Protocol Conformances

extension MarkdownStylizer.Style: NestableStringsConvertible {

    static var checkForOverlap: Bool { true }

    var nestableStrings: (text: String, patterns: [String]) {
        let strings: (String, [String])
        switch self {
        case .bold: strings = ("bold", ["**bold%@**", "__bold%@__"])
        case .italics: strings = ("italics", ["*italics%@*", "_italics%@_"])
        case .strikethrough: strings = ("strikethrough", ["~~strikethrough%@~~"])
        case .link: strings = ("link", ["[link%@](https://link.com)", "[link%@](https://link.com \"optional\")"])
        }

        return strings
    }
}

extension HTMLStylizer.Style: NestableStringsConvertible {

    static var checkForOverlap: Bool { false }

    var nestableStrings: (text: String, patterns: [String]) {
        let strings: (String, [String])
        switch self {
        case .bold: strings = ("bold", ["<b>bold%@</b>", "<strong>bold%@</strong>"])
        case .italics: strings = ("italics", ["<i>italics%@</i>", "<em>italics%@</em>"])
        case .strikethrough: strings = ("strikethrough", ["<del>strikethrough%@</del>"])
        case .underline: strings = ("underline", ["<ins>underline%@</ins>"])
        case .superscript: strings = ("superscript", ["<sup>superscript%@</sup>"])
        case .textColor: strings = ("textcolor", ["<p style=\"color:crimson;\">textcolor%@</p>"])
        case .backgroundColor: strings = ("backgroundcolor", ["<p style=\"background-color:crimson;\">backgroundcolor%@</p>"])
        case .link: strings = ("link", ["<a href=\"https://link.com\">link%@</a>", "<a href=\"https://link.com\" title=\"optional\">link%@</a>"])
        }

        return strings
    }
}
#endif // #if !os(watchOS)
