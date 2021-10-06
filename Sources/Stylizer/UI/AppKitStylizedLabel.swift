//
//  AppKitStylizedLabel.swift
//  Stylizer
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

// MARK: - StylizedLabelDelegate Definition

/// Methods for selectively overriding attributes and clicking on links
@objc public protocol StylizedLabelDelegate: NSObjectProtocol {

    /**
     Called when a user clicks on a link within the attributed string of the label

     - parameters:
       - label: The label that contains the link that was clicked
       - link: The link that was clicked on. This value obtained directly from the attributed
               string and not validated in any way. Unless directly modified in some way,
               this should be either a `URL` or a `String`
       - range: The range of the substring of the link that was clicked
     */
    @available(macOS 10.11, *)
    @objc optional func label(_ label: StylizedLabel, didClickOnLink link: Any, in range: NSRange)

    /**
     Called whenever the label stylizes its string. Implementing this method allows
     selective overwriting of the placeholder attributes inserted by the label's
     stylizers

     - parameters:
       - label: The label that is performing stylizing
       - attribute: The placeholder attribute that is being processed
       - value: The value, if any, of the placeholder attribute
       - range: The range of this placeholder attribute
       - proposedAttributes: The attributes that are to be overwritten

     - returns: The attributes to use in place of the `proposedAttributes` when
                replacing the placeholder attribute. If `nil` is returned then
                `proposedAttributes` will be substituted in place of the
                placeholder attribute
     */
    @objc optional func label(_ label: StylizedLabel, overridePlaceholderAttribute attribute: NSAttributedString.Key, value: Any?, in range: NSRange, withProposedAttributes proposedAttributes: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any]?
}

// MARK: - StylizedLabel Definition

/// A `NSTextField` subclass setup for automatically stylizing any values set to
/// its `stringValue` or `attributedStringValue` properties
@objc open class StylizedLabel: NSTextField {

    // MARK: Private Properties

    @available(macOS 10.11, *)
    private lazy var clickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(stylizedLabelClick(_:)))

    private var _font: NSFont? = NSFont.systemFont(ofSize: 0.0)

    // MARK: Public Properties

    /// A property used for storing the value passed into `stringValue` or
    /// `attributedStringValue` immediately prior to stylizing it
    @objc open private(set) var unstylizedAttributedStringValue: NSAttributedString? {
        didSet {
            if unstylizedAttributedStringValue == nil, #available(macOS 10.11, *) {
                removeGestureRecognizer(clickGestureRecognizer)
            }
        }
    }

    /// The object that's used for handling stylizer delegate methods
    @objc open weak var stylizerDelegate: StylizedLabelDelegate?

    /// The stylizer objects to use for stylizing input values
    @objc open var stylizers: [Stylizer] = [] {
        didSet {
            if let unstylizedAttributedStringValue = unstylizedAttributedStringValue, stylizers != oldValue {
                super.attributedStringValue = stylize(unstylizedAttributedStringValue)
            }
        }
    }

    // MARK: Property Overrides

    //swiftlint:disable unused_setter_value
    override open var isEditable: Bool {
        get { return false } // static text
        set { super.isEditable = false }
    }

    override open var allowsEditingTextAttributes: Bool {
        get { return false } // static text
        set { super.allowsEditingTextAttributes = false }
    }

    override open var acceptsFirstResponder: Bool { return false }
    //swiftlint:enable unused_setter_value

    override open var stringValue: String {
        get { return super.attributedStringValue.string }
        set {
            if !newValue.isEmpty {
                let newValue = NSAttributedString(string: newValue)

                self.unstylizedAttributedStringValue = newValue
                super.attributedStringValue = stylize(newValue)
            } else {
                self.unstylizedAttributedStringValue = nil
                super.stringValue = newValue
            }
        }
    }

    override open var attributedStringValue: NSAttributedString {
        get { return super.attributedStringValue }
        set {
            if newValue.length > 0 {
                self.unstylizedAttributedStringValue = newValue
                super.attributedStringValue = stylize(newValue)
            } else {
                self.unstylizedAttributedStringValue = nil
                super.attributedStringValue = newValue
            }
        }
    }

    override open var font: NSFont? {
        get { return _font }
        set {
            let oldValue = _font
            if let newValue = newValue {
                super.font = newValue
                self._font = newValue
            } else {
                super.font = nil
                self._font = super.font ?? .defaultFont
            }

            if let unstylizedAttributedStringValue = unstylizedAttributedStringValue, font !== oldValue {
                super.attributedStringValue = stylize(unstylizedAttributedStringValue)
            }
        }
    }

    // MARK: Initialization

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.setDefaultValues()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setDefaultValues()
    }

    /**
     Initializes a new `StylizedLabel` with the given attributed string

     - parameters:
       - attributedString: The attributed string to use as the contents of this label

     - returns: The initialized stylized label instance
     */
    public convenience init(attributedString: NSAttributedString) {
        self.init(frame: .zero)
        self.attributedStringValue = attributedString
    }

    private func setDefaultValues() {
        self.drawsBackground = false
        self.textColor = .labelColor
        self.isBezeled = false
        self.isEditable = false
        self.isSelectable = false
        self.lineBreakMode = .byWordWrapping

        if #available(macOS 11.0, *) {
            self.lineBreakStrategy = .standard
        } else if #available(macOS 10.15, *) {
            self.lineBreakStrategy = .pushOut
        }
    }

    // MARK: Private Methods

    private func stylize(_ newValue: NSAttributedString) -> NSAttributedString {
        let placeholderAttributeOverrideProvider: StylizerPlaceholderAttributeOverrideProvider?
        if let delegate = stylizerDelegate, delegate.responds(to: #selector(StylizedLabelDelegate.label(_:overridePlaceholderAttribute:value:in:withProposedAttributes:))) {
            placeholderAttributeOverrideProvider = { [unowned self] attribute, value, range, proposedAttributes in
                delegate.label?(self, overridePlaceholderAttribute: attribute, value: value, in: range, withProposedAttributes: proposedAttributes)
            }
        } else {
            placeholderAttributeOverrideProvider = nil
        }

        let stylizedString = newValue.stylize(with: stylizers, defaultFont: font ?? .defaultFont, placeholderAttributeOverrideProvider: placeholderAttributeOverrideProvider)

        if #available(macOS 10.11, *) {
            if stylizedString.containsAttribute(.link) {
                addGestureRecognizer(clickGestureRecognizer)
            } else {
                removeGestureRecognizer(clickGestureRecognizer)
            }
        }

        return stylizedString
    }

    @available(macOS 10.11, *)
    @objc private func stylizedLabelClick(_ gestureRecognizer: NSClickGestureRecognizer) {
        guard attributedStringValue.length > 0,
              let delegate = stylizerDelegate, delegate.responds(to: #selector(StylizedLabelDelegate.label(_:didClickOnLink:in:))) else { return }

        if let (attributes, range) = attributedStringValue.attributes(at: gestureRecognizer.location(in: self), in: self), let link = attributes[.link] {
            delegate.label?(self, didClickOnLink: link, in: range)
        }
    }
}
#endif // #if canImport(AppKit) && !targetEnvironment(macCatalyst)
