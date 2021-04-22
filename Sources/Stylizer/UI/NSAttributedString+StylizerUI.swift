//
//  NSAttributedString+StylizerUI.swift
//  Stylizer
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

#if (canImport(UIKit) && !os(watchOS)) || (canImport(AppKit) && !targetEnvironment(macCatalyst))
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

// MARK: - NSAttributedString Extension

extension NSAttributedString {

    // MARK: Internal Methods

    @available(macOS 10.11, *)
    internal func attributes(at point: CGPoint, in label: StylizedLabel) -> (attributes: [NSAttributedString.Key: Any], range: NSRange)? {
        guard length > 0 else { return nil }

        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: .zero)

        let bounds = label.bounds
        let attributedText = self.insertingBaseFont(label.font ?? .defaultFont)
        let textStorage = NSTextStorage(attributedString: attributedText)

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.size = bounds.size

        #if canImport(UIKit)
        textContainer.maximumNumberOfLines = label.numberOfLines
        #else
        textContainer.maximumNumberOfLines = label.maximumNumberOfLines
        #endif

        var textContainerFrame = layoutManager.usedRect(for: textContainer)
        if textContainerFrame == .zero { textContainerFrame = bounds }

        let delta = CGPoint(x: (bounds.size.width - textContainerFrame.size.width) * 0.5 - textContainerFrame.origin.x,
                            y: (bounds.size.height - textContainerFrame.size.height) * 0.5 - textContainerFrame.origin.y)
        let point = CGPoint(x: point.x - delta.x, y: point.y - delta.y)

        var attributes: ([NSAttributedString.Key: Any], NSRange)?
        if textContainerFrame.insetBy(dx: -0.000001, dy: -0.000001).contains(point) {
            let characterIndex = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

            var range = NSRange(location: 0, length: 0)
            let attrs = self.attributes(at: characterIndex, effectiveRange: &range)

            attributes = attrs.isEmpty ? nil : (attrs, range)
        }

        return attributes
    }
}
#endif // #if (canImport(UIKit) && !os(watchOS)) || (canImport(AppKit) && !targetEnvironment(macCatalyst))
