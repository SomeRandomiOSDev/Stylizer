//
//  TypeDefinitions.swift
//  Stylizer
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

import Foundation

// MARK: UIKit/AppKit Dependant Types

#if canImport(UIKit)
import UIKit

public typealias StylizerNativeFont = UIFont
//
internal typealias StylizerNativeColor = UIColor
internal typealias StylizerNativeFontDescriptor = UIFontDescriptor
#elseif canImport(AppKit)
import AppKit

public typealias StylizerNativeFont = NSFont
//
internal typealias StylizerNativeColor = NSColor
internal typealias StylizerNativeFontDescriptor = NSFontDescriptor
#endif

// MARK: Internal Types

internal typealias StylizerPlaceholderAttributeOverrideProvider = (NSAttributedString.Key, Any?, NSRange, [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any]?

// MARK: Public Types

public typealias StylizerCustomAttributesProvider = (NSAttributedString.Key, Any?, NSRange) -> [NSAttributedString.Key: Any]?
