//
//  NSRegularExpression+Stylizer.swift
//  Stylizer
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

import Foundation

// MARK: - NSRegularExpression Extension

extension NSRegularExpression {

    // MARK: Initialization

    // Non-throwing initializer that crashes on invalid regex patterns
    internal convenience init(verifiedPattern pattern: String, options: NSRegularExpression.Options = []) {
        do {
            try self.init(pattern: pattern, options: options)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
