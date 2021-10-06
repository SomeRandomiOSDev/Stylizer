//
//  ColorParserTests.swift
//  StylizerTests
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

import CoreGraphics
@testable import Stylizer
import XCTest

//swiftlint:disable function_body_length

// MARK: - ColorParserTests Definition

class ColorParserTests: XCTestCase {

    // MARK: Test Methods

    func testHTMLColors() {
        for (colorName, color) in ColorParser.htmlColors {
            let red = (color & 0xFF0000) >> 16
            let green = (color & 0xFF00) >> 8
            let blue = (color & 0xFF) >> 0

            compare(rgbColor: ColorParser.parseColor(from: colorName), toComponents: [red, green, blue], parsedString: colorName)
        }
    }

    func testParseHexColors() {
        for _ in 0 ..< 128 {
            let red = UInt.random(in: 0 ... 255)
            let green = UInt.random(in: 0 ... 255)
            let blue = UInt.random(in: 0 ... 255)

            let lowercasedString = String(format: "#%02x%02x%02x", red, green, blue)
            let uppercasedString = String(format: "#%02X%02X%02X", red, green, blue)

            compare(rgbColor: ColorParser.parseColor(from: lowercasedString), toComponents: [red, green, blue], parsedString: lowercasedString)
            compare(rgbColor: ColorParser.parseColor(from: uppercasedString), toComponents: [red, green, blue], parsedString: uppercasedString)
        }
    }

    func testParseRGBColors() {
        for _ in 0 ..< 128 {
            let red = UInt.random(in: 0 ... 255)
            let green = UInt.random(in: 0 ... 255)
            let blue = UInt.random(in: 0 ... 255)
            let alpha = UInt.random(in: 0 ... 255)

            var lowercasedString = "rgb(\(randomSpacing())\(red)\(randomSpacing()),\(randomSpacing())\(green)\(randomSpacing()),\(randomSpacing())\(blue)\(randomSpacing()))"
            var uppercasedString = "RGB(\(randomSpacing())\(red)\(randomSpacing()),\(randomSpacing())\(green)\(randomSpacing()),\(randomSpacing())\(blue)\(randomSpacing()))"

            compare(rgbColor: ColorParser.parseColor(from: lowercasedString), toComponents: [red, green, blue], parsedString: lowercasedString)
            compare(rgbColor: ColorParser.parseColor(from: uppercasedString), toComponents: [red, green, blue], parsedString: uppercasedString)

            lowercasedString = "rgb(\(randomSpacing())\(red)\(randomSpacing()),\(randomSpacing())\(green)\(randomSpacing()),\(randomSpacing())\(blue)\(randomSpacing()),\(randomSpacing())\(CGFloat(alpha) / 255.0)\(randomSpacing()))"
            uppercasedString = "RGB(\(randomSpacing())\(red)\(randomSpacing()),\(randomSpacing())\(green)\(randomSpacing()),\(randomSpacing())\(blue)\(randomSpacing()),\(randomSpacing())\(CGFloat(alpha) / 255.0)\(randomSpacing()))"

            compare(rgbColor: ColorParser.parseColor(from: lowercasedString), toComponents: [red, green, blue, alpha], parsedString: lowercasedString)
            compare(rgbColor: ColorParser.parseColor(from: uppercasedString), toComponents: [red, green, blue, alpha], parsedString: uppercasedString)
        }
    }

    func testParseHSLColors() {
        for _ in 0 ..< 128 {
            let hue = UInt.random(in: 0 ... 360)
            let saturation = UInt.random(in: 0 ... 100)
            let lightness = UInt.random(in: 0 ... 100)
            let alpha = UInt.random(in: 0 ... 255)

            var lowercasedString = "hsl(\(randomSpacing())\(hue)\(randomSpacing()),\(randomSpacing())\(saturation)%\(randomSpacing()),\(randomSpacing())\(lightness)%\(randomSpacing()))"
            var uppercasedString = "HSL(\(randomSpacing())\(hue)\(randomSpacing()),\(randomSpacing())\(saturation)%\(randomSpacing()),\(randomSpacing())\(lightness)%\(randomSpacing()))"

            compare(hslColor: ColorParser.parseColor(from: lowercasedString), toComponents: [hue, saturation, lightness], parsedString: lowercasedString)
            compare(hslColor: ColorParser.parseColor(from: uppercasedString), toComponents: [hue, saturation, lightness], parsedString: uppercasedString)

            lowercasedString = "hsl(\(randomSpacing())\(hue)\(randomSpacing()),\(randomSpacing())\(saturation)%\(randomSpacing()),\(randomSpacing())\(lightness)%\(randomSpacing()),\(randomSpacing())\(CGFloat(alpha) / 255.0)\(randomSpacing()))"
            uppercasedString = "HSL(\(randomSpacing())\(hue)\(randomSpacing()),\(randomSpacing())\(saturation)%\(randomSpacing()),\(randomSpacing())\(lightness)%\(randomSpacing()),\(randomSpacing())\(CGFloat(alpha) / 255.0)\(randomSpacing()))"

            compare(hslColor: ColorParser.parseColor(from: lowercasedString), toComponents: [hue, saturation, lightness, alpha], parsedString: lowercasedString)
            compare(hslColor: ColorParser.parseColor(from: uppercasedString), toComponents: [hue, saturation, lightness, alpha], parsedString: uppercasedString)

            // Edge Case

            lowercasedString = "hsl(\(randomSpacing())\(hue)\(randomSpacing()),\(randomSpacing())0%\(randomSpacing()),\(randomSpacing())0%\(randomSpacing()))"
            uppercasedString = "HSL(\(randomSpacing())\(hue)\(randomSpacing()),\(randomSpacing())0%\(randomSpacing()),\(randomSpacing())0%\(randomSpacing()))"

            compare(hslColor: ColorParser.parseColor(from: lowercasedString), toComponents: [hue, 0, 0], parsedString: lowercasedString)
            compare(hslColor: ColorParser.parseColor(from: uppercasedString), toComponents: [hue, 0, 0], parsedString: uppercasedString)

            lowercasedString = "hsl(\(randomSpacing())\(hue)\(randomSpacing()),\(randomSpacing())0%\(randomSpacing()),\(randomSpacing())0%\(randomSpacing()),\(randomSpacing())\(CGFloat(alpha) / 255.0)\(randomSpacing()))"
            uppercasedString = "HSL(\(randomSpacing())\(hue)\(randomSpacing()),\(randomSpacing())0%\(randomSpacing()),\(randomSpacing())0%\(randomSpacing()),\(randomSpacing())\(CGFloat(alpha) / 255.0)\(randomSpacing()))"

            compare(hslColor: ColorParser.parseColor(from: lowercasedString), toComponents: [hue, 0, 0, alpha], parsedString: lowercasedString)
            compare(hslColor: ColorParser.parseColor(from: uppercasedString), toComponents: [hue, 0, 0, alpha], parsedString: uppercasedString)
        }
    }

    func testParseHSVAndHSBColors() {
        for _ in 0 ..< 128 {
            let hue = UInt.random(in: 0 ... 360)
            let saturation = UInt.random(in: 0 ... 100)
            let brightness = UInt.random(in: 0 ... 100)
            let alpha = UInt.random(in: 0 ... 255)

            var lowercasedString = "hsv(\(randomSpacing())\(hue)\(randomSpacing()),\(randomSpacing())\(saturation)%\(randomSpacing()),\(randomSpacing())\(brightness)%\(randomSpacing()))"
            var uppercasedString = "HSV(\(randomSpacing())\(hue)\(randomSpacing()),\(randomSpacing())\(saturation)%\(randomSpacing()),\(randomSpacing())\(brightness)%\(randomSpacing()))"

            compare(hsvColor: ColorParser.parseColor(from: lowercasedString), toComponents: [hue, saturation, brightness], parsedString: lowercasedString)
            compare(hsvColor: ColorParser.parseColor(from: uppercasedString), toComponents: [hue, saturation, brightness], parsedString: uppercasedString)

            lowercasedString = "hsv(\(randomSpacing())\(hue)\(randomSpacing()),\(randomSpacing())\(saturation)%\(randomSpacing()),\(randomSpacing())\(brightness)%\(randomSpacing()),\(randomSpacing())\(CGFloat(alpha) / 255.0)\(randomSpacing()))"
            uppercasedString = "HSV(\(randomSpacing())\(hue)\(randomSpacing()),\(randomSpacing())\(saturation)%\(randomSpacing()),\(randomSpacing())\(brightness)%\(randomSpacing()),\(randomSpacing())\(CGFloat(alpha) / 255.0)\(randomSpacing()))"

            compare(hsvColor: ColorParser.parseColor(from: lowercasedString), toComponents: [hue, saturation, brightness, alpha], parsedString: lowercasedString)
            compare(hsvColor: ColorParser.parseColor(from: uppercasedString), toComponents: [hue, saturation, brightness, alpha], parsedString: uppercasedString)

            //

            lowercasedString = "hsb(\(randomSpacing())\(hue)\(randomSpacing()),\(randomSpacing())\(saturation)%\(randomSpacing()),\(randomSpacing())\(brightness)%\(randomSpacing()))"
            uppercasedString = "HSB(\(randomSpacing())\(hue)\(randomSpacing()),\(randomSpacing())\(saturation)%\(randomSpacing()),\(randomSpacing())\(brightness)%\(randomSpacing()))"

            compare(hsvColor: ColorParser.parseColor(from: lowercasedString), toComponents: [hue, saturation, brightness], parsedString: lowercasedString)
            compare(hsvColor: ColorParser.parseColor(from: uppercasedString), toComponents: [hue, saturation, brightness], parsedString: uppercasedString)

            lowercasedString = "hsb(\(randomSpacing())\(hue)\(randomSpacing()),\(randomSpacing())\(saturation)%\(randomSpacing()),\(randomSpacing())\(brightness)%\(randomSpacing()),\(randomSpacing())\(CGFloat(alpha) / 255.0)\(randomSpacing()))"
            uppercasedString = "HSB(\(randomSpacing())\(hue)\(randomSpacing()),\(randomSpacing())\(saturation)%\(randomSpacing()),\(randomSpacing())\(brightness)%\(randomSpacing()),\(randomSpacing())\(CGFloat(alpha) / 255.0)\(randomSpacing()))"

            compare(hsvColor: ColorParser.parseColor(from: lowercasedString), toComponents: [hue, saturation, brightness, alpha], parsedString: lowercasedString)
            compare(hsvColor: ColorParser.parseColor(from: uppercasedString), toComponents: [hue, saturation, brightness, alpha], parsedString: uppercasedString)
        }
    }

    func testParseDisplayP3Colors() {
        for _ in 0 ..< 128 {
            let red = UInt.random(in: 0 ... 255)
            let green = UInt.random(in: 0 ... 255)
            let blue = UInt.random(in: 0 ... 255)
            let alpha = UInt.random(in: 0 ... 255)

            var lowercasedString = "displayp3(\(randomSpacing())\(red)\(randomSpacing()),\(randomSpacing())\(green)\(randomSpacing()),\(randomSpacing())\(blue)\(randomSpacing()))"
            var uppercasedString = "DISPLAYP3(\(randomSpacing())\(red)\(randomSpacing()),\(randomSpacing())\(green)\(randomSpacing()),\(randomSpacing())\(blue)\(randomSpacing()))"
            var mixedcasedString = "displayP3(\(randomSpacing())\(red)\(randomSpacing()),\(randomSpacing())\(green)\(randomSpacing()),\(randomSpacing())\(blue)\(randomSpacing()))"

            compare(rgbColor: ColorParser.parseColor(from: lowercasedString), toComponents: [red, green, blue], parsedString: lowercasedString)
            compare(rgbColor: ColorParser.parseColor(from: uppercasedString), toComponents: [red, green, blue], parsedString: uppercasedString)
            compare(rgbColor: ColorParser.parseColor(from: mixedcasedString), toComponents: [red, green, blue], parsedString: mixedcasedString)

            lowercasedString = "displayp3(\(randomSpacing())\(red)\(randomSpacing()),\(randomSpacing())\(green)\(randomSpacing()),\(randomSpacing())\(blue)\(randomSpacing()),\(randomSpacing())\(CGFloat(alpha) / 255.0)\(randomSpacing()))"
            uppercasedString = "DISPLAYP3(\(randomSpacing())\(red)\(randomSpacing()),\(randomSpacing())\(green)\(randomSpacing()),\(randomSpacing())\(blue)\(randomSpacing()),\(randomSpacing())\(CGFloat(alpha) / 255.0)\(randomSpacing()))"
            mixedcasedString = "displayP3(\(randomSpacing())\(red)\(randomSpacing()),\(randomSpacing())\(green)\(randomSpacing()),\(randomSpacing())\(blue)\(randomSpacing()),\(randomSpacing())\(CGFloat(alpha) / 255.0)\(randomSpacing()))"

            compare(rgbColor: ColorParser.parseColor(from: lowercasedString), toComponents: [red, green, blue, alpha], parsedString: lowercasedString)
            compare(rgbColor: ColorParser.parseColor(from: uppercasedString), toComponents: [red, green, blue, alpha], parsedString: uppercasedString)
            compare(rgbColor: ColorParser.parseColor(from: mixedcasedString), toComponents: [red, green, blue, alpha], parsedString: mixedcasedString)
        }
    }

    func testParseCMYKColors() {
        for _ in 0 ..< 128 {
            let cyan = UInt.random(in: 0 ... 255)
            let magenta = UInt.random(in: 0 ... 255)
            let yellow = UInt.random(in: 0 ... 255)
            let black = UInt.random(in: 0 ... 255)
            let alpha = UInt.random(in: 0 ... 255)

            var lowercasedString = "cmyk(\(randomSpacing())\(cyan)\(randomSpacing()),\(randomSpacing())\(magenta)\(randomSpacing()),\(randomSpacing())\(yellow)\(randomSpacing()),\(randomSpacing())\(black)\(randomSpacing()))"
            var uppercasedString = "CMYK(\(randomSpacing())\(cyan)\(randomSpacing()),\(randomSpacing())\(magenta)\(randomSpacing()),\(randomSpacing())\(yellow)\(randomSpacing()),\(randomSpacing())\(black)\(randomSpacing()))"

            compare(cmykColor: ColorParser.parseColor(from: lowercasedString), toComponents: [cyan, magenta, yellow, black], parsedString: lowercasedString)
            compare(cmykColor: ColorParser.parseColor(from: uppercasedString), toComponents: [cyan, magenta, yellow, black], parsedString: uppercasedString)

            lowercasedString = "cmyk(\(randomSpacing())\(cyan)\(randomSpacing()),\(randomSpacing())\(magenta)\(randomSpacing()),\(randomSpacing())\(yellow)\(randomSpacing()),\(randomSpacing())\(black)\(randomSpacing()),\(randomSpacing())\(CGFloat(alpha) / 255.0)\(randomSpacing()))"
            uppercasedString = "CMYK(\(randomSpacing())\(cyan)\(randomSpacing()),\(randomSpacing())\(magenta)\(randomSpacing()),\(randomSpacing())\(yellow)\(randomSpacing()),\(randomSpacing())\(black)\(randomSpacing()),\(randomSpacing())\(CGFloat(alpha) / 255.0)\(randomSpacing()))"

            compare(cmykColor: ColorParser.parseColor(from: lowercasedString), toComponents: [cyan, magenta, yellow, black, alpha], parsedString: lowercasedString)
            compare(cmykColor: ColorParser.parseColor(from: uppercasedString), toComponents: [cyan, magenta, yellow, black, alpha], parsedString: uppercasedString)
        }
    }

    func testParseGrayColors() {
        for _ in 0 ..< 128 {
            let white = UInt.random(in: 0 ... 255)
            let alpha = UInt.random(in: 0 ... 255)

            var lowercasedString = "gray(\(randomSpacing())\(white)\(randomSpacing()))"
            var uppercasedString = "GRAY(\(randomSpacing())\(white)\(randomSpacing()))"

            compare(grayColor: ColorParser.parseColor(from: lowercasedString), toComponents: [white], parsedString: lowercasedString)
            compare(grayColor: ColorParser.parseColor(from: uppercasedString), toComponents: [white], parsedString: uppercasedString)

            lowercasedString = "gray(\(randomSpacing())\(white)\(randomSpacing()),\(randomSpacing())\(CGFloat(alpha) / 255.0)\(randomSpacing()))"
            uppercasedString = "GRAY(\(randomSpacing())\(white)\(randomSpacing()),\(randomSpacing())\(CGFloat(alpha) / 255.0)\(randomSpacing()))"

            compare(grayColor: ColorParser.parseColor(from: lowercasedString), toComponents: [white, alpha], parsedString: lowercasedString)
            compare(grayColor: ColorParser.parseColor(from: uppercasedString), toComponents: [white, alpha], parsedString: uppercasedString)
        }
    }

    #if !SWIFT_PACKAGE && !os(watchOS)
    func testParseBundleColors() {
        let rgbColors: [(name: String, components: [UInt])] = [
            ("color1", [255, 0, 0, 255]),   // .red
            ("color2", [0, 255, 0, 255]),   // .green
            ("color3", [0, 0, 255, 255]),   // .blue
            ("color4", [0, 255, 255, 255]), // .cyan
            ("color5", [255, 0, 255, 255]), // .magenta
            ("color6", [255, 255, 0, 255])  // .yellow
        ]
        let grayColors: [(name: String, components: [UInt])] = [
            ("color7", [255, 255]), // .white
            ("color8", [128, 255]), // .gray
            ("color9", [0, 255])    // .black
        ]

        for (name, components) in rgbColors {
            let lowercasedString = "bundlecolor(\"\(name)\",\(randomSpacing())\"com.somerandomiosdev.stylizertests\")"
            let uppercasedString = "BUNDLECOLOR(\"\(name)\",\(randomSpacing())\"com.somerandomiosdev.stylizertests\")"
            let mixedcasedString = "bundleColor(\"\(name)\",\(randomSpacing())\"com.somerandomiosdev.stylizertests\")"

            for string in [lowercasedString, mixedcasedString, uppercasedString] {
                compare(rgbColor: ColorParser.parseColor(from: string), toComponents: components, parsedString: string)
            }
        }

        for (name, components) in grayColors {
            let lowercasedString = "bundlecolor(\"\(name)\",\(randomSpacing())\"com.somerandomiosdev.stylizertests\")"
            let uppercasedString = "BUNDLECOLOR(\"\(name)\",\(randomSpacing())\"com.somerandomiosdev.stylizertests\")"
            let mixedcasedString = "bundleColor(\"\(name)\",\(randomSpacing())\"com.somerandomiosdev.stylizertests\")"

            for string in [lowercasedString, mixedcasedString, uppercasedString] {
                compare(grayColor: ColorParser.parseColor(from: string), toComponents: components, parsedString: string)
            }
        }
    }
    #endif // #if !SWIFT_PACKAGE && !os(watchOS)

    func testInvalidFormats() {
        XCTAssertNil(ColorParser.parseColor(from: "r(1)"))
        XCTAssertNil(ColorParser.parseColor(from: "g(1)"))
        XCTAssertNil(ColorParser.parseColor(from: "b(1)"))
        XCTAssertNil(ColorParser.parseColor(from: "a(1)"))
        XCTAssertNil(ColorParser.parseColor(from: "rg(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "rb(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "gb(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "rgb(1)"))
        XCTAssertNil(ColorParser.parseColor(from: "rgb(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "rgba(1)"))
        XCTAssertNil(ColorParser.parseColor(from: "rgba(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "rgba(1,1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "rgba(1,1,1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "h(1)"))
        XCTAssertNil(ColorParser.parseColor(from: "s(1)"))
        XCTAssertNil(ColorParser.parseColor(from: "l(1)"))
        XCTAssertNil(ColorParser.parseColor(from: "hs(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "hl(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "sl(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "hsl(1)"))
        XCTAssertNil(ColorParser.parseColor(from: "hsl(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "hsla(1)"))
        XCTAssertNil(ColorParser.parseColor(from: "hsla(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "hsla(1,1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "hsla(1,1,1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "v(1)"))
        XCTAssertNil(ColorParser.parseColor(from: "hv(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "sv(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "hsv(1)"))
        XCTAssertNil(ColorParser.parseColor(from: "hsv(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "hsva(1)"))
        XCTAssertNil(ColorParser.parseColor(from: "hsva(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "hsva(1,1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "hsva(1,1,1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "b(1)"))
        XCTAssertNil(ColorParser.parseColor(from: "hb(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "sb(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "hsb(1)"))
        XCTAssertNil(ColorParser.parseColor(from: "hsb(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "hsba(1)"))
        XCTAssertNil(ColorParser.parseColor(from: "hsba(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "hsba(1,1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "hsba(1,1,1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "c(1)"))
        XCTAssertNil(ColorParser.parseColor(from: "m(1)"))
        XCTAssertNil(ColorParser.parseColor(from: "y(1)"))
        XCTAssertNil(ColorParser.parseColor(from: "k(1)"))
        XCTAssertNil(ColorParser.parseColor(from: "cm(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "cy(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "ck(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "my(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "mk(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "yk(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "myk(1,1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "cyk(1,1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "cmk(1,1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "cmy(1,1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "cmyk(1)"))
        XCTAssertNil(ColorParser.parseColor(from: "cmyk(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "cmyk(1,1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "cmyka(1)"))
        XCTAssertNil(ColorParser.parseColor(from: "cmyka(1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "cmyka(1,1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "cmyka(1,1,1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "cmyka(1,1,1,1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "gray(1,1,0.5)"))
        XCTAssertNil(ColorParser.parseColor(from: "gray(1,1,1,0.5)"))
        XCTAssertNil(ColorParser.parseColor(from: "hsi(1,1,1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "yuv(1,1,1)"))
        XCTAssertNil(ColorParser.parseColor(from: "non-html color"))
        XCTAssertNil(ColorParser.parseColor(from: "bundleColor(\"non-existent color\")"))
        XCTAssertNil(ColorParser.parseColor(from: "bundleColor(\"non-existent color\",\"com.somerandomiosdev.stylizertests\")"))
    }

    // MARK: Private Methods

    private func randomSpacing(in range: Range<Int> = (0 ..< 2)) -> String {
        return String(repeating: " ", count: Int.random(in: range))
    }

    private func compare(rgbColor color: StylizerNativeColor?, toComponents components: [UInt], parsedString: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(color, parsedString, file: file, line: line)

        let cgColor = color?.cgColor
        XCTAssertNotNil(cgColor, parsedString, file: file, line: line)

        let colorSpace = cgColor?.colorSpace
        XCTAssertNotNil(colorSpace, parsedString, file: file, line: line)
        XCTAssertEqual(colorSpace?.model, .rgb, parsedString, file: file, line: line)

        let red = CGFloat(components[0]) / 255.0
        let green = CGFloat(components[1]) / 255.0
        let blue = CGFloat(components[2]) / 255.0
        let alpha = components.count >= 4 ? (CGFloat(components[3]) / 255.0) : 1.0

        XCTAssertEqual(cgColor?.components, [red, green, blue, alpha], parsedString, file: file, line: line)
    }

    private func compare(cmykColor color: StylizerNativeColor?, toComponents components: [UInt], parsedString: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(color, parsedString, file: file, line: line)

        let cgColor = color?.cgColor
        XCTAssertNotNil(cgColor, parsedString, file: file, line: line)

        let colorSpace = cgColor?.colorSpace
        XCTAssertNotNil(colorSpace, parsedString, file: file, line: line)
        XCTAssertEqual(colorSpace?.model, .cmyk, parsedString, file: file, line: line)

        let cyan = CGFloat(components[0]) / 255.0
        let magenta = CGFloat(components[1]) / 255.0
        let yellow = CGFloat(components[2]) / 255.0
        let black = CGFloat(components[3]) / 255.0
        let alpha = components.count >= 5 ? (CGFloat(components[4]) / 255.0) : 1.0

        XCTAssertEqual(cgColor?.components, [cyan, magenta, yellow, black, alpha], parsedString, file: file, line: line)
    }

    private func compare(grayColor color: StylizerNativeColor?, toComponents components: [UInt], parsedString: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(color, parsedString, file: file, line: line)

        let cgColor = color?.cgColor
        XCTAssertNotNil(cgColor, parsedString, file: file, line: line)

        let colorSpace = cgColor?.colorSpace
        XCTAssertNotNil(colorSpace, parsedString, file: file, line: line)
        XCTAssertEqual(colorSpace?.model, .monochrome, parsedString, file: file, line: line)

        let white = CGFloat(components[0]) / 255.0
        let alpha = components.count >= 2 ? (CGFloat(components[1]) / 255.0) : 1.0

        XCTAssertEqual(cgColor?.components, [white, alpha], parsedString, file: file, line: line)
    }

    //swiftlint:disable identifier_name
    private func compare(hslColor color: StylizerNativeColor?, toComponents components: [UInt], parsedString: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(color, parsedString, file: file, line: line)

        let cgColor = color?.cgColor
        XCTAssertNotNil(cgColor, parsedString, file: file, line: line)

        let colorSpace = cgColor?.colorSpace
        XCTAssertNotNil(colorSpace, parsedString, file: file, line: line)
        XCTAssertEqual(colorSpace?.model, .rgb, parsedString, file: file, line: line)

        // HSL -> RGB
        let hue = CGFloat(components[0]) / 60.0
        let saturation = CGFloat(components[1]) / 100.0
        let lightness = CGFloat(components[2]) / 100.0
        let alpha = components.count >= 4 ? (CGFloat(components[3]) / 255.0) : 1.0

        let c = (1.0 - abs((2.0 * lightness) - 1.0)) * saturation
        let x = c * (1.0 - abs((hue.truncatingRemainder(dividingBy: 2.0)) - 1.0))
        let m = lightness - (c * 0.5)

        var red = m, green = m, blue = m
        switch hue {
        case 0 ..< 1: red += c; green += x
        case 1 ..< 2: red += x; green += c
        case 2 ..< 3: green += c; blue += x
        case 3 ..< 4: green += x; blue += c
        case 4 ..< 5: red += x; blue += c
        case 5 ... 6: red += c; blue += x
        default: break
        }

        if let components = cgColor?.components, components.count == 4 {
            XCTAssertLessThanOrEqual(abs(components[0] - red), 0.001, parsedString, file: file, line: line)
            XCTAssertLessThanOrEqual(abs(components[1] - green), 0.001, parsedString, file: file, line: line)
            XCTAssertLessThanOrEqual(abs(components[2] - blue), 0.001, parsedString, file: file, line: line)
            XCTAssertLessThanOrEqual(abs(components[3] - alpha), 0.001, parsedString, file: file, line: line)
        } else {
            XCTFail(parsedString, file: file, line: line)
        }
    }

    private func compare(hsvColor color: StylizerNativeColor?, toComponents components: [UInt], parsedString: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(color, parsedString, file: file, line: line)

        let cgColor = color?.cgColor
        XCTAssertNotNil(cgColor, parsedString, file: file, line: line)

        let colorSpace = cgColor?.colorSpace
        XCTAssertNotNil(colorSpace, parsedString, file: file, line: line)
        XCTAssertEqual(colorSpace?.model, .rgb, parsedString, file: file, line: line)

        // HSV -> RGB
        let hue = CGFloat(components[0]) / 60.0
        let saturation = CGFloat(components[1]) / 100.0
        let brightness = CGFloat(components[2]) / 100.0
        let alpha = components.count >= 4 ? (CGFloat(components[3]) / 255.0) : 1.0

        let c = brightness * saturation
        let x = c * (1.0 - abs((hue.truncatingRemainder(dividingBy: 2.0)) - 1.0))
        let m = brightness - c

        var red = m, green = m, blue = m
        switch hue {
        case 0 ... 1: red += c; green += x
        case 1 ... 2: red += x; green += c
        case 2 ... 3: green += c; blue += x
        case 3 ... 4: green += x; blue += c
        case 4 ... 5: red += x; blue += c
        case 5 ... 6: red += c; blue += x
        default: break
        }

        if let components = cgColor?.components, components.count == 4 {
            XCTAssertLessThanOrEqual(abs(components[0] - red), 0.001, parsedString, file: file, line: line)
            XCTAssertLessThanOrEqual(abs(components[1] - green), 0.001, parsedString, file: file, line: line)
            XCTAssertLessThanOrEqual(abs(components[2] - blue), 0.001, parsedString, file: file, line: line)
            XCTAssertLessThanOrEqual(abs(components[3] - alpha), 0.001, parsedString, file: file, line: line)
        } else {
            XCTFail(parsedString, file: file, line: line)
        }
    }
    //swiftlint:enable identifier_name
}
