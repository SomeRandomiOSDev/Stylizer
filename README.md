Stylizer
========

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/d30d31c29f17449481b97a04610ff5b9)](https://app.codacy.com/app/SomeRandomiOSDev/Stylizer?utm_source=github.com&utm_medium=referral&utm_content=SomeRandomiOSDev/Stylizer&utm_campaign=Badge_Grade_Dashboard)
[![License MIT](https://img.shields.io/cocoapods/l/Stylizer.svg)](https://cocoapods.org/pods/Stylizer)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Stylizer.svg)](https://cocoapods.org/pods/Stylizer) 
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) 
[![Platform](https://img.shields.io/cocoapods/p/Stylizer.svg)](https://cocoapods.org/pods/Stylizer)
[![Code Coverage](https://codecov.io/gh/SomeRandomiOSDev/Stylizer/branch/master/graph/badge.svg)](https://codecov.io/gh/SomeRandomiOSDev/Stylizer)

![Swift Package](https://github.com/SomeRandomiOSDev/Stylizer/workflows/Swift%20Package/badge.svg)
![Xcode Project](https://github.com/SomeRandomiOSDev/Stylizer/workflows/Xcode%20Project/badge.svg)
![Cocoapods](https://github.com/SomeRandomiOSDev/Stylizer/workflows/Cocoapods/badge.svg)
![Carthage](https://github.com/SomeRandomiOSDev/Stylizer/workflows/Carthage/badge.svg)

Purpose
--------

The purpose of this library is to simplify the process of adding simple attributes to strings. Much in the same way that it's easy to add **bold** or *italic* text to this Markdown file this library's aim is to make it just easy to add similar attributes to `String` and `NSAttributedString` instances without the hassle of dealing with the intricacies of the process of adding attributes to `NSAttributedString`  objects. 

Installation
--------

**Stylizer** is available through [CocoaPods](https://cocoapods.org), [Carthage](https://github.com/Carthage/Carthage) and the [Swift Package Manager](https://swift.org/package-manager/). 

To install via CocoaPods, simply add the following line to your Podfile:

```ruby
pod 'Stylizer'

# or:
# pod 'Stylizer/Core'
# pod 'Stylizer/UI'
```

To install via Carthage, simply add the following line to your Cartfile:

```ruby
github "SomeRandomiOSDev/Stylizer"
```

To install via the Swift Package Manager add the following line to your `Package.swift` file's `dependencies`:

```swift
.package(url: "https://github.com/SomeRandomiOSDev/Stylizer.git", from: "1.0.0")
```

Usage
--------

Stylizing strings using this library couldn't be easier. After importing this library (Objective-C: `@import Stylizer;`, Swift: `import Stylizer`) simply call the `stylize(with:defaultFont:customAttributesProvider:)` extension method on your `String`, `NSString`, or `NSAttributedString` instance with one or more `Stylizer` objects. The result is a new `NSAttributedString` object whose underlying string has been modified to parse out the patterns defined by the stylizers with the corresponding attributes added in its place.

For convenience, this library provides two pre-configured stylizers, `HTMLStylizer` and `MarkdownStylizer`; each of them can be used to parse a attributes from a string containing (a subset of) properly formatted HTML or Markdown attributes, respectively. Each of these stylizers defines an enumeration that defines the kind of attributes that it can parse: `HTMLStylizer.Style` and `MarkdownStylizer.Style` respectively.

### HTML

`HTMLStylizer` defines eight styles which it is able to parse: 

* `bold`: Text contained between a pair of `<b>` tags or a pair of `<strong>` tags (e.g. \<b\>bold text\</b\>, \<strong\>also bold text\</strong\>)
* `italics`: Text contained between a pair of `<i>` tags or a pair of `<em>` tags (e.g. \<i\>italic text\</i\>, \<em\>also italic text\</em\>) 
* `strikethrough`: Text contained between a pair of `<del>` tags (e.g. \<del\>struckthrough text\</del\>) 
* `underline`: Text contained between a pair of `<ins>` tags (e.g. \<ins\>underlined text\</ins\>)
* `superscript` (macOS Only): Text contained between a pair of `<sup>` tags (e.g. \<sup\>superscript text\</sup\>)
* `textColor`: Text contained between a pair of `<p>` tags with an attribute of `style="color:<text color>;"` (e.g. \<p style="color:blue;"\>blue text\</p\>)
* `backgroundColor`: Text contained between a pair of `<p>` tags with an attribute of `style="background-color:<background color>;"` (e.g. \<p style="color:red;"\>text with red background\</p\>)
* `link`: Text contained between a pair `<a>` tags with an attribute of `href="<link text"` (e.g. \<a href="https://www.apple.com"\>link\</a\>). Optionally, including the `title` attribute will add a `.toolTip` attribute for macOS (e.g. \<a href="https://www.apple.com" title="tooltip title"\>link\</a\>)

For the `textColor` and `backgroundColor` styles the color can be defined using any one of the following string formats:

* HTML Hex Code: `"#RRGGBB"`
* One of the basic or extended [HTML color names](https://en.wikipedia.org/wiki/Web_colors#HTML_color_names)
* RGB Color: `"rgb(r, g, b, <optional> a)"` where `r`, `g`, and `b` are in the range 0 - 255 and `a` is a floating point number from 0.0 - 1.0
* RGB P3 Color: `"displayP3(r, g, b, <optional> a)"` where `r`, `g`, and `b` are in the range 0 - 255 and `a` is a floating point number from 0.0 - 1.0
* Grayscale Color: `"gray(w, <optional> a)"` where `w` is in the range 0 - 255 and `a` is a floating point number from 0.0 - 1.0
* HSL Color: `"hsl(h, s%, l%, <optional> a)"` where `h` is in the range 0 - 360, `s`, and `l` are in the range 0 - 100 and `a` is a floating point number from 0.0 - 1.0
* HSV/HSB Color: `"hsv(h, s%, v%, <optional> a)"` or `"hsb(h, s%, b%, <optional> a)"` where `h` is in the range 0 - 360, `s`, and `v/b` are in the range 0 - 100 and `a` is a floating point number from 0.0 - 1.0
* CMYK Color: `"cmyk(c, m, y, k, <optional> a)"` where `c`, `m`, `y`, and `k` are in the range 0 - 255 and `a` is a floating point number from 0.0 - 1.0
* Bundle Color: `"bundleColor("<color name>", <optional> "<bundle identifier>")"` where `<color name>` is the name of the color in the asset catalog and `<bundle identifier>` is the identifier of the `Bundle` in which the asset catalog containing the color can be found. If a bundle identifier isn't supplied, the main bundle is used.

### Markdown

`MarkdownStylizer` defines four styles which it is able to parse: 

* `bold`: Text contained between a pair of double asterisks or a pair of double underlines (e.g. \*\*bold text\*\*, \_\_also bold text\_\_)
* `italics`: Text contained between a pair of single asterisks or a pair of single underlines (e.g. \*italic text\*, \_also italic text\_) 
* `strikethrough`: Text contained between a pair of double tildes (e.g. \~\~struckthrough text\~\~) 
* `link`: Text contained between a pair of brackets, followed by a link contained within parentheses (e.g. \[link\]\(https://www.apple.com\))

### Placeholder Attributes

Both the `HTMLStylizer` and `MarkdownStylizer` objects are configured to insert _placeholder_ attributes for each of the attributes that parses from the `Stylizer.attributedStringByReplacingMatches(in:range:)` methods. More specifically, each of the defined stylizers' styles corresponds to one of the following respectively named attributes:

`.stylizerBold`, `.stylizerItalics`, `.stylizerStrikethrough`, `.stylizerUnderline`, `.stylizerSuperscript`, `.stylizerTextColor`, `.stylizerBackgroundColor`, `.stylizerLink`.

This is done, in particular, to make consistent the behavior of `bold` and `italics` styles. These two styles don't have corresponding UIKit/AppKit attributes, instead, one inserts the `.font` attribute with a font object that has bold or italic traits, or both. The issue with inserting a font at the time stylizing the string is that when that string is rendered, the UI element that renders that string (label, text view, etc.) might have a different font set to the object than what was used as the basis of the bold/italic font for the attribute. Additionally if there are pre-exisiting `.font` attributes in the attributed string that overlap with the `bold` or `italics` styles, those fonts should be used for the appropriate ranges as the "base" font for applying `bold` and `italics` styles. Furthermore, once the `.font` attribute is inserted into the string it becomes indistinguishable from any other `.font` attributes that might have existed in the attributed string that is being stylized. Therefore to ensure that the correct font is used when `bold` and `italic` styles are parsed from strings, these placeholder attributes are used at the time of stylizing and then converted to the appropriate fonts just prior to rendering.

It's worth noting that only the `Stylizer.attributedStringByReplacingMatches(in:range:)` methods for the `HTMLStylizer` and `MarkdownStylizer` stylizers insert these placeholder attributes. The `stylize(with:defaultFont:customAttributesProvider:)` extension methods on the `String`, `NSString`, and `NSAttributedString` instances perform the _final_ conversion of placeholder attributes to UIKit/AppKit compatible attributes for rendering.

### StylizedLabel

As a convenience, a `StylizedLabel` class is provided from this library (for Cocoapods, this is part of the `Stylizer/UI` subspec) for handling the intricacies of stylizing and placeholder attributes. When using UIKit (including Mac Catalyst) this class subclasses the `UILabel` class and when using AppKit, this class subclasses `NSTextField`. For AppKit, this class takes on the same properties as an `NSTextField` initialized using the `NSTextField(wrappingLabelWithString:)` initializer (wraps, non-editable & non-selectable).

Use of this label couldn't be simpler. After initialization simply set the stylizers that you want this label to use to its `stylizers` property and then set a string or attributed string to the label:

```swift
// UIKit

let label = StylizedLabel(frame: .zero)

label.stylizers = [MarkdownStylizer()]
label.text = "For more information, click [here](https://www.apple.com)"

...
```

This label uses the currently set font for resolving `bold` and `italic` placeholders. If the label's font is updated, the final `.font` attributes representing any `bold` or `italic` placeholders are updated as well.

As an added convenience, this label has a delegate (`StylizerLabelDelegate`) that defines a callback method for when the user taps/clicks on a link inside of the label when user interaction is enabled for the label.

### Custom Stylizers

Creating custom `Stylizer` objects to represent your own styles is incredibly simple. Under the hood, `Stylizer` utilizes the power of Foundation's `NSRegularExpression` engine for doing the heavy lifting for search and replacement of styles. To create your own `Stylizer` you need only to initialize a `Stylizer` object with one or more `StyleInfo` objects, which are created with the following information:

* `expression`: The regular expression that represents the pattern to search for. This should include the entirety of your style pattern as matches produced from this regular expression will be replaced in their entirety.
* `replacementTemplate`: The template for the replacement string that will be substituted into the final string in place of the matched pattern. This is passed unmodified to `NSRegularExpression.replacementString(for:in:offset:template:)` method as the `template` parameter.
* `matchingOptions`: The options to use when using `expression` for matching. These are passed unmodified to the `NSRegularExpression.matches(in:options:range:)` method as the `options` parameter.
* `attributesProvider`: A closure that is used to provide the attributes for a particular match in the `expression` object. The two parameters to this closure are the current match and the string as it _currently_ stands, meaning that it may have already have had some of its styles already replaced and would therefore be different than the string passed into the stylizer's `Stylizer.attributedStringByReplacingMatches(in:range:)` method. The attributes returned by this closure are applied to the full range of the replacement string. If no attributes or an empty attributes dictionary are returned by this closure, then no attributes are applied to the replacement string.

When stylizing strings, the `StyleInfo` objects are applied concurrently in an "inside-out" order, meaning the innermost style are substituted first, followed by the next innermost and so on until all of the styles have been applied. Although the styles are applied in an "inside-out" order, the attributes that are added to strings are added in an "outside-in" order. For example, when processing the following string with an `HTMLStylizer`:

`"<p style="color:red;">red red red <p style="color:blue;">blue blue blue</p> red red red</p>"`

After the first pass the attributed string will be as follows:

`"<p style="color:red;">red red red blue blue blue red red red</p>"`

At this point, the attributed string will have an attribute of `.stylizerTextColor` surrounding the `"blue blue blue"` part of the string. After the second pass the attributed string will be as follows:

`"red red red blue blue blue red red red"`

With attributes:

* `"red red red "`: `.stylizerTextColor` with a red color object
* `"blue blue blue"`: `.stylizerTextColor` with a blue color object
* `" red red red"`: `.stylizerTextColor` with a red color object

If your custom stylizer wants to adopt the same "placeholder" mechanism used by `HTMLStylizer` and `MarkdownStylizer`, that too is simple to do. First, register your custom placeholders using the `NSAttributedString.Key.registerCustomStylizerPlaceholderAttributes(_:)` method with your custom placeholder attributes. Then, for the appropriate `attributesProvider` of your `StyleInfo` objects return the custom placeholder attributes. Lastly, when calling the `stylize(with:defaultFont:customAttributesProvider:)` extension method on `String`, `NSString`, or `NSAttributedString`, pass a closure for the `customAttributesProvider` parameter that subsitutes your placeholder attributes for UIKit/AppKit compatible attributes. Alternatively if you are using a `StylizedLabel` then you can adopt the `label(_:overridePlaceholderAttribute:value:in:withProposedAttributes:)` delegate method and provide your placeholder attribute substitutions there.

TODO
--------

* Attempt to find a way to stylize `bold` and `italics` attributes without placeholder attributes
* Add support for additional HTML attributes

Contributing
--------

If you have need for a specific feature or you encounter a bug, please open an issue. If you extend the functionality of **Stylizer** yourself or you feel like fixing a bug yourself, please submit a pull request.

Author
--------

Joe Newton, somerandomiosdev@gmail.com

License
--------

**Stylizer** is available under the MIT license. See the `LICENSE` file for more info.
