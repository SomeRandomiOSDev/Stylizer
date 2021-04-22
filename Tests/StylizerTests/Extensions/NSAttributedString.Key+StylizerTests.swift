//
//  NSAttributedString.Key+StylizerTests.swift
//  Stylizer
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

#if !os(watchOS)
@testable import Stylizer
import XCTest

// MARK: - NSAttributedStringKeyStylizerTests Definition

class NSAttributedStringKeyStylizerTests: XCTestCase {

    // MARK: Test Methods

    func testRegisterCustomStylizerPlaceholderAttributes() {
        let startingAttributes = NSAttributedString.Key.customStylizerPlaceholderAttributes

        NSAttributedString.Key.registerCustomStylizerPlaceholderAttributes([])
        XCTAssertEqual(NSAttributedString.Key.customStylizerPlaceholderAttributes.count, startingAttributes.count)

        let customAttribute1 = NSAttributedString.Key(rawValue: UUID().uuidString)
        let customAttribute2 = NSAttributedString.Key(rawValue: UUID().uuidString)
        NSAttributedString.Key.registerCustomStylizerPlaceholderAttributes([customAttribute1, customAttribute2, customAttribute1])

        XCTAssertTrue(NSAttributedString.Key.customStylizerPlaceholderAttributes.contains(customAttribute1))
        XCTAssertTrue(NSAttributedString.Key.customStylizerPlaceholderAttributes.contains(customAttribute2))
        XCTAssertEqual(NSAttributedString.Key.customStylizerPlaceholderAttributes.subtracting([customAttribute1, customAttribute2]), startingAttributes)
    }
}
#endif // #if !os(watchOS)
