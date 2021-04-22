//
//  ColorParser.swift
//  Stylizer
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

import CoreGraphics
import Foundation

//swiftlint:disable function_body_length

// MARK: - ColorParser Definition

internal enum ColorParser { // using 'enum' for namespace semantics

    // MARK: Private Constants

    private static let hexRegex = NSRegularExpression(verifiedPattern: "#([0-9a-fA-F]{6})", options: .caseInsensitive)
    private static let bundleColorRegex = NSRegularExpression(verifiedPattern: "bundleColor\\(\\s*\"(.*?)\"\\s*(?:,\\s*\"(.*?)\"\\s*)?\\)", options: .caseInsensitive)

    private static let oneComponentRegex = NSRegularExpression(verifiedPattern: "(gray)\\(\\s*([0-9]{1,3})\\s*(?:,\\s*([0-9]+\\.[0-9]+)\\s*)?\\)", options: .caseInsensitive)
    private static let threeComponentRegex = NSRegularExpression(verifiedPattern: "(rgb|hsl|hsv|hsb|displayP3)\\(\\s*([0-9]{1,3})\\s*,\\s*([0-9]{1,3})%?\\s*,\\s*([0-9]{1,3})%?\\s*(?:,\\s*([0-9]+\\.[0-9]+)\\s*)?\\)", options: .caseInsensitive)
    private static let fourComponentRegex = NSRegularExpression(verifiedPattern: "(cmyk)\\(\\s*([0-9]{1,3})\\s*,\\s*([0-9]{1,3})\\s*,\\s*([0-9]{1,3})\\s*,\\s*([0-9]{1,3})\\s*(?:,\\s*([0-9]+\\.[0-9]+)\\s*)?\\)", options: .caseInsensitive)

    // MARK: Internal Methods

    internal static func parseColor(from string: String) -> StylizerNativeColor? {
        let range = NSRange(location: 0, length: string.count)
        var color: StylizerNativeColor?

        if let hexColor = htmlColors[string.lowercased()] {
            let r = CGFloat((hexColor & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((hexColor & 0x00FF00) >> 08) / 255.0
            let b = CGFloat((hexColor & 0x0000FF) >> 00) / 255.0

            color = StylizerNativeColor(red: r, green: g, blue: b, alpha: 1.0)
        } else if let match = hexRegex.firstMatch(in: string, options: [], range: range) {
            if let range = Range(match.range(at: 1), in: string), let value = UInt(string[range], radix: 16) {
                let r = CGFloat((value & 0xFF0000) >> 16) / 255.0
                let g = CGFloat((value & 0x00FF00) >> 08) / 255.0
                let b = CGFloat((value & 0x0000FF) >> 00) / 255.0

                color = StylizerNativeColor(red: r, green: g, blue: b, alpha: 1.0)
            }
        } else if let match = oneComponentRegex.firstMatch(in: string, options: [], range: range) {
            if let components = parseComponents(from: string, using: match, limits: [255, 1]) {
                color = StylizerNativeColor(white: components[0],
                                            alpha: components[1])
            }
        } else if let match = threeComponentRegex.firstMatch(in: string, options: [], range: range) {
            if let prefix = Range(match.range(at: 1), in: string).map({ string[$0].lowercased() }) {
                let limits: [Int] = prefix.starts(with: "hs") ? [360, 100, 100, 1] : [255, 255, 255, 1]

                if let components = parseComponents(from: string, using: match, limits: limits) {
                    let tags = string[Range(match.range, in: string) ?? string.startIndex ..< string.endIndex].filter { $0 == "%" }

                    if tags.count == 2 {
                        if prefix == "hsl" {
                            if let components = convertHSLToHSV(components) {
                                color = StylizerNativeColor(hue: components[0], saturation: components[1], brightness: components[2], alpha: components[3])
                            }
                        } else if prefix == "hsv" || prefix == "hsb" {
                            color = StylizerNativeColor(hue: components[0], saturation: components[1], brightness: components[2], alpha: components[3])
                        }
                    } else if tags.isEmpty {
                        if #available(iOS 9.3, macOS 10.11.2, tvOS 9.3, watchOS 2.3, *), prefix == "displayp3", let displayP3ColorSpace = CGColorSpace(name: CGColorSpace.displayP3) {
                            color = CGColor(colorSpace: displayP3ColorSpace, components: components).flatMap { StylizerNativeColor(cgColor: $0) }
                        } else if prefix == "rgb" {
                            color = StylizerNativeColor(red: components[0], green: components[1], blue: components[2], alpha: components[3])
                        }
                    }
                }
            }
        } else if let match = fourComponentRegex.firstMatch(in: string, options: [], range: range) {
            if let components = parseComponents(from: string, using: match, limits: [255, 255, 255, 255, 1]) {
                color = CGColor(colorSpace: CGColorSpaceCreateDeviceCMYK(), components: components).flatMap { StylizerNativeColor(cgColor: $0) }
            }
        } else if #available(iOS 11.0, macOS 10.13, tvOS 11.0, watchOS 4.0, *), let match = bundleColorRegex.firstMatch(in: string, options: [], range: range) {
            if let colorName = Range(match.range(at: 1), in: string).map({ String(string[$0]) }) {
                let bundle = match.range(at: 2).location != NSNotFound ? Range(match.range(at: 2), in: string).flatMap({ Bundle(identifier: String(string[$0])) }) : nil

                #if canImport(UIKit)
                #if os(watchOS)
                color = StylizerNativeColor(named: colorName)
                #else
                color = StylizerNativeColor(named: colorName, in: bundle ?? .main, compatibleWith: nil)
                #endif
                #else
                color = StylizerNativeColor(named: colorName, bundle: bundle ?? .main)
                #endif
            }
        }

        return color
    }

    // MARK: Private Methods

    //swiftlint:disable discouraged_optional_collection
    private static func parseComponents(from string: String, using match: NSTextCheckingResult, limits: [Int]) -> [CGFloat]? {
        let components: [CGFloat]?

        if match.numberOfRanges == 4 {
            guard let component1: Int = parseNumber(from: string, in: match.range(at: 2)) else { return nil }

            let component2: Double
            if match.range(at: 3).location != NSNotFound {
                component2 = parseNumber(from: string, in: match.range(at: 3)) ?? 1.0
            } else {
                component2 = 1.0
            }

            components = [
                CGFloat(clamp(component1, to: 0 ... limits[0])) / CGFloat(limits[0]),
                CGFloat(clamp(component2, to: 0.0 ... Double(limits[1]))) / CGFloat(limits[1])
            ]
        } else if match.numberOfRanges >= 6 {
            guard let component1: Int = parseNumber(from: string, in: match.range(at: 2)) else { return nil }
            guard let component2: Int = parseNumber(from: string, in: match.range(at: 3)) else { return nil }
            guard let component3: Int = parseNumber(from: string, in: match.range(at: 4)) else { return nil }

            let component4: Double
            if match.range(at: 5).location != NSNotFound {
                component4 = parseNumber(from: string, in: match.range(at: 5)) ?? 1.0
            } else {
                component4 = 1.0
            }

            let component5: Double
            if match.numberOfRanges > 6 && match.range(at: 6).location != NSNotFound {
                component5 = parseNumber(from: string, in: match.range(at: 6)) ?? 1.0
            } else {
                component5 = 1.0
            }

            components = [
                CGFloat(clamp(component1, to: 0 ... limits[0])) / CGFloat(limits[0]),
                CGFloat(clamp(component2, to: 0 ... limits[1])) / CGFloat(limits[1]),
                CGFloat(clamp(component3, to: 0 ... limits[2])) / CGFloat(limits[2]),
                CGFloat(clamp(component4, to: 0.0 ... Double(limits[3]))) / CGFloat(limits[3]),
                CGFloat(clamp(component5, to: 0.0 ... Double(limits.count > 4 ? limits[4] : 1))) / CGFloat(limits.count > 4 ? limits[4] : 1)
            ]
        } else {
            components = nil
        }

        return components
    }

    private static func convertHSLToHSV(_ components: [CGFloat]) -> [CGFloat]? {
        guard components.count >= 3 else { return nil }

        let hue = components[0]
        var saturation = components[1]
        let lightness = components[2]

        let brightness = lightness + (saturation * min(lightness, 1.0 - lightness))
        if brightness == 0.0 {
            saturation = 0.0
        } else {
            saturation = 2 * (1.0 - lightness / brightness)
        }

        return [hue, saturation, brightness, components.count >= 4 ? components[3] : 1.0]
    }
    //swiftlint:enable discouraged_optional_collection

    private static func parseNumber<T>(from string: String, in nsrange: NSRange) -> T? where T: LosslessStringConvertible {
        guard let range = Range(nsrange, in: string) else { return nil }
        return T(String(string[range]))
    }

    private static func clamp<T>(_ value: T, to range: ClosedRange<T>) -> T where T: Comparable {
        return max(range.lowerBound, min(value, range.upperBound))
    }
}

// MARK: - ColorParser Extension

extension ColorParser {

    // MARK: Internal Constants

    //swiftlint:disable colon
    internal static let htmlColors: [String: UInt] = [
        "aliceblue"         : 0xF0F8FF, "antiquewhite"         : 0xFAEBD7, "aqua"            : 0x00FFFF,
        "aquamarine"        : 0x7FFFD4, "azure"                : 0xF0FFFF, "beige"           : 0xF5F5DC,
        "bisque"            : 0xFFE4C4, "black"                : 0x000000, "blanchedalmond"  : 0xFFEBCD,
        "blue"              : 0x0000FF, "blueviolet"           : 0x8A2BE2, "brown"           : 0xA52A2A,
        "burlywood"         : 0xDEB887, "cadetblue"            : 0x5F9EA0, "chartreuse"      : 0x7FFF00,
        "chocolate"         : 0xD2691E, "coral"                : 0xFF7F50, "cornflowerblue"  : 0x6495ED,
        "cornsilk"          : 0xFFF8DC, "crimson"              : 0xDC143C, "cyan"            : 0x00FFFF,
        "darkblue"          : 0x00008B, "darkcyan"             : 0x008B8B, "darkgoldenrod"   : 0xB8860B,
        "darkgray"          : 0xA9A9A9, "darkgrey"             : 0xA9A9A9, "darkgreen"       : 0x006400,
        "darkkhaki"         : 0xBDB76B, "darkmagenta"          : 0x8B008B, "darkolivegreen"  : 0x556B2F,
        "darkorange"        : 0xFF8C00, "darkorchid"           : 0x9932CC, "darkred"         : 0x8B0000,
        "darksalmon"        : 0xE9967A, "darkseagreen"         : 0x8FBC8F, "darkslateblue"   : 0x483D8B,
        "darkslategray"     : 0x2F4F4F, "darkslategrey"        : 0x2F4F4F, "darkturquoise"   : 0x00CED1,
        "darkviolet"        : 0x9400D3, "deeppink"             : 0xFF1493, "deepskyblue"     : 0x00BFFF,
        "dimgray"           : 0x696969, "dimgrey"              : 0x696969, "dodgerblue"      : 0x1E90FF,
        "firebrick"         : 0xB22222, "floralwhite"          : 0xFFFAF0, "forestgreen"     : 0x228B22,
        "fuchsia"           : 0xFF00FF, "gainsboro"            : 0xDCDCDC, "ghostwhite"      : 0xF8F8FF,
        "gold"              : 0xFFD700, "goldenrod"            : 0xDAA520, "gray"            : 0x808080,
        "grey"              : 0x808080, "green"                : 0x008000, "greenyellow"     : 0xADFF2F,
        "honeydew"          : 0xF0FFF0, "hotpink"              : 0xFF69B4, "indianred"       : 0xCD5C5C,
        "indigo"            : 0x4B0082, "ivory"                : 0xFFFFF0, "khaki"           : 0xF0E68C,
        "lavender"          : 0xE6E6FA, "lavenderblush"        : 0xFFF0F5, "lawngreen"       : 0x7CFC00,
        "lemonchiffon"      : 0xFFFACD, "lightblue"            : 0xADD8E6, "lightcoral"      : 0xF08080,
        "lightcyan"         : 0xE0FFFF, "lightgoldenrodyellow" : 0xFAFAD2, "lightgray"       : 0xD3D3D3,
        "lightgrey"         : 0xD3D3D3, "lightgreen"           : 0x90EE90, "lightpink"       : 0xFFB6C1,
        "lightsalmon"       : 0xFFA07A, "lightseagreen"        : 0x20B2AA, "lightskyblue"    : 0x87CEFA,
        "lightslategray"    : 0x778899, "lightslategrey"       : 0x778899, "lightsteelblue"  : 0xB0C4DE,
        "lightyellow"       : 0xFFFFE0, "lime"                 : 0x00FF00, "limegreen"       : 0x32CD32,
        "linen"             : 0xFAF0E6, "magenta"              : 0xFF00FF, "maroon"          : 0x800000,
        "mediumaquamarine"  : 0x66CDAA, "mediumblue"           : 0x0000CD, "mediumorchid"    : 0xBA55D3,
        "mediumpurple"      : 0x9370DB, "mediumseagreen"       : 0x3CB371, "mediumslateblue" : 0x7B68EE,
        "mediumspringgreen" : 0x00FA9A, "mediumturquoise"      : 0x48D1CC, "mediumvioletred" : 0xC71585,
        "midnightblue"      : 0x191970, "mintcream"            : 0xF5FFFA, "mistyrose"       : 0xFFE4E1,
        "moccasin"          : 0xFFE4B5, "navajowhite"          : 0xFFDEAD, "navy"            : 0x000080,
        "oldlace"           : 0xFDF5E6, "olive"                : 0x808000, "olivedrab"       : 0x6B8E23,
        "orange"            : 0xFFA500, "orangered"            : 0xFF4500, "orchid"          : 0xDA70D6,
        "palegoldenrod"     : 0xEEE8AA, "palegreen"            : 0x98FB98, "paleturquoise"   : 0xAFEEEE,
        "palevioletred"     : 0xDB7093, "papayawhip"           : 0xFFEFD5, "peachpuff"       : 0xFFDAB9,
        "peru"              : 0xCD853F, "pink"                 : 0xFFC0CB, "plum"            : 0xDDA0DD,
        "powderblue"        : 0xB0E0E6, "purple"               : 0x800080, "rebeccapurple"   : 0x663399,
        "red"               : 0xFF0000, "rosybrown"            : 0xBC8F8F, "royalblue"       : 0x4169E1,
        "saddlebrown"       : 0x8B4513, "salmon"               : 0xFA8072, "sandybrown"      : 0xF4A460,
        "seagreen"          : 0x2E8B57, "seashell"             : 0xFFF5EE, "sienna"          : 0xA0522D,
        "silver"            : 0xC0C0C0, "skyblue"              : 0x87CEEB, "slateblue"       : 0x6A5ACD,
        "slategray"         : 0x708090, "slategrey"            : 0x708090, "snow"            : 0xFFFAFA,
        "springgreen"       : 0x00FF7F, "steelblue"            : 0x4682B4, "tan"             : 0xD2B48C,
        "teal"              : 0x008080, "thistle"              : 0xD8BFD8, "tomato"          : 0xFF6347,
        "turquoise"         : 0x40E0D0, "violet"               : 0xEE82EE, "wheat"           : 0xF5DEB3,
        "white"             : 0xFFFFFF, "whitesmoke"           : 0xF5F5F5, "yellow"          : 0xFFFF00
    ]
    //swiftlint:enable colon
}
