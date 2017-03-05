# RAGTextField

[![CI Status](http://img.shields.io/travis/raginmari/RAGTextField.svg?style=flat)](https://travis-ci.org/raginmari/RAGTextField)
[![Version](https://img.shields.io/cocoapods/v/RAGTextField.svg?style=flat)](http://cocoapods.org/pods/RAGTextField)
[![License](https://img.shields.io/cocoapods/l/RAGTextField.svg?style=flat)](http://cocoapods.org/pods/RAGTextField)
[![Platform](https://img.shields.io/cocoapods/p/RAGTextField.svg?style=flat)](http://cocoapods.org/pods/RAGTextField)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Written in Swift 3. Requires iOS 9 (deployment target).

## Installation

`RAGTextField` is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "RAGTextField"
```

## How to use

After installing the lib and importing the module `RAGTextField`, the text field can be used like any other text field (both in the code and in your storyboards and nibs).

These are the key differences to `UITextField`:
- A **floating placeholder** similar to the one featured by the text field in Google's [Material Design](https://material.io/guidelines/components/text-fields.html#text-fields-labels).
- A **hint label** below the actual text which can be used to provide additional hints or report errors.
- A view in the **background of the text** (excluding the placeholder and the hint label) which can be used to style the appearance of the text entry. The example projects uses this capability.

Many properties of the text field are `IBInspectable`. Unfortunately, fonts and enums cannot (Xcode 8) be inspected in IB, so a bit of setup has to be done in code in some cases.

#### The placeholder

The placeholder replaces the superclass placeholder. Values assigned to the `placeholder` property are handled exclusively by `RAGTextField`. The text alignment of the placeholder matches the text alignment of the text field.

These are the different ways you can **customize the appearance** and behavior of the placeholder:

- Use the `placeholderFont` property to assign a **custom font or font size** to the placeholder. By default, the placeholder uses the font of the text field.
- Use the `placeholderColor` property to **change the color** of the placeholder. By default, the placeholder uses the text color of the text field.
- Use the `placeholderScaleWhenEditing` property to specify the **scale applied to the placeholder** in its floating position above the text. The default value is 1. It is not (yet) possible to assign values greater than 1.
- Use the `scaledPlaceholderOffset` property to offset the placeholder in its floating position from the text. The default value is 0. Positive values **move the placeholder up**, away from the text.
- The value of the `placeholderMode` property determines the **behavior of the placeholder**:
-- `scalesWhenEditing`: the placeholder is moved to the floating position as soon as the text field becomes the first responder. Moreover, the placeholder remains in the floating position as long as there is text in the text field.
-- `scalesWhenNotEmpty` (default): the placeholder is moved to the floating position as soon as and for as long as there is text in the text field.
-- `simple`: the floating placeholder is disabled. The behavior of the placeholder resembles that of the superclass.
- Use the `placeholderAnimationDuration` property to adjust the **duration of the animation of the placeholder** when it moves to or from the floating position. If the value is `nil`, a default value is used. Set the value to 0 to **disable** the placeholder animation.

#### The hint label

The hint label is disabled by default and while the value of the `hint` property is `nil`. If a non-nil value is assigned to the `hint` property (including the empty string), the layout of the label is updated and space for the hint label is reserved. The text alignment of the hint matches the text alignment of the text field.

These are the different ways you can **customize the appearance** of the hint:

- Use the `hintFont` property to assign a **custom font or font size** to the hint. By default, the hint uses the font of the text field.
- Use the `hintColor` property to **change the color** of the hint. By default, the hint uses the text color of the text field.

#### The text background view

Add a view to the background of the text by assigning an arbitrary view to the `textBackgroundView` property. Its frame is updated by `RAGTextField` when required. Just add and forget (it's never that simple...). The view is sized so that it matches the size of the text plus padding (see below).

These are the different ways you can **customize the appearance** of the text background view.

- Use the `horizontalTextPadding` property to apply padding to the left and right of the text. The padding expands the text background view horizontally.
- Use the `verticalTextPadding` property to apply padding to the top (between the text and the placeholder) and bottom (between the text and the hint) of the text. The padding expands the text background view vertically.

## Known issues

These are known or possible issues with `RAGTextField`:

- The clear button is displayed to the right (i.e. outside) of the text background view which may not be what you want. Moreover (and probably more annoyingly), the text background view resizes every time the clear button is shown or hidden.
- The `attributedText` property of UITextField *may* not be supported.
- The `attributedPlaceholder` of UITextField is not supported.
- The `borderStyle` property should be `.none`. Others *may* not be supported.
- The `leftView` and `rightView` properties *may* not be supported (at least they will most certainly appear at the wrong position).

These issues will hopefully be addressed in future updates.

## Author

raginmari, reimar.twelker@web.de

## License

RAGTextField is available under the MIT license. See the LICENSE file for more info.
