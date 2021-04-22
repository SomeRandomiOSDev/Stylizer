//
//  UIKitStylizedLabel.swift
//  Stylizer
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

#if canImport(UIKit) && !os(watchOS)
import UIKit

// MARK: - StylizedLabelDelegate Definition

/// Methods for selectively overriding attributes and tapping on links
@objc public protocol StylizedLabelDelegate: NSObjectProtocol {

    /**
     Called when a user taps on a link within the attributed string of the label

     - parameters:
       - label: The label that contains the link that was tapped
       - link: The link that was tapped on. This value obtained directly from the attributed
               string and not validated in any way. Unless directly modified in some way,
               this should be either a `URL` or a `String`
       - range: The range of the substring of the link that was tapped
     */
    @objc optional func label(_ label: StylizedLabel, didTapOnLink link: Any, in range: NSRange)

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

/// An `UILabel` subclass setup for automatically stylizing any values set to its
/// `text` or `attributedText` properties
@objc open class StylizedLabel: UILabel {

    // MARK: Private Properties

    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(stylizedLabelTap(_:)))
    private var _font: UIFont?

    // MARK: Public Properties

    /// A property used for storing the value passed into `text` or `attributedText`
    /// immediately prior to stylizing it
    @objc open private(set) var unstylizedAttributedText: NSAttributedString? {
        didSet {
            if unstylizedAttributedText == nil {
                removeGestureRecognizer(tapGestureRecognizer)
            }
        }
    }

    /// The object that's used for handling stylizer delegate methods
    @objc open weak var stylizerDelegate: StylizedLabelDelegate?

    /// The stylizer objects to use for stylizing input values
    @objc open var stylizers: [Stylizer] = [] {
        didSet {
            if let unstylizedAttributedText = unstylizedAttributedText, stylizers != oldValue {
                super.attributedText = stylize(unstylizedAttributedText)
            }
        }
    }

    // MARK: Property Overrides

    override open var text: String? {
        get { return super.attributedText?.string }
        set {
            if let newValue = newValue.map({ NSAttributedString(string: $0) }) {
                self.unstylizedAttributedText = newValue
                super.attributedText = stylize(newValue)
            } else {
                self.unstylizedAttributedText = nil
                super.attributedText = nil
            }
        }
    }

    override open var attributedText: NSAttributedString? {
        get { return super.attributedText }
        set {
            if let newValue = newValue {
                self.unstylizedAttributedText = newValue
                super.attributedText = stylize(newValue)
            } else {
                self.unstylizedAttributedText = nil
                super.attributedText = nil
            }
        }
    }

    //swiftlint:disable implicitly_unwrapped_optional
    override open var font: UIFont! {
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

            if let unstylizedAttributedText = unstylizedAttributedText, oldValue != _font {
                super.attributedText = stylize(unstylizedAttributedText)
            }
        }
    }
    //swiftlint:enable implicitly_unwrapped_optional

    // MARK: Initialization

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self._font = super.font
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self._font = super.font
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

        if stylizedString.containsAttribute(.link) {
            addGestureRecognizer(tapGestureRecognizer)
        } else {
            removeGestureRecognizer(tapGestureRecognizer)
        }

        return stylizedString
    }

    @objc private func stylizedLabelTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let attributedText = attributedText, attributedText.length > 0,
              let delegate = stylizerDelegate, delegate.responds(to: #selector(StylizedLabelDelegate.label(_:didTapOnLink:in:))) else { return }

        if let (attributes, range) = attributedText.attributes(at: gestureRecognizer.location(in: self), in: self), let link = attributes[.link] {
            delegate.label?(self, didTapOnLink: link, in: range)
        }
    }
}
#endif // #if canImport(UIKit) && !os(watchOS)
