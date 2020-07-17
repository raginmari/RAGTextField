# RAGTextField

[![CI Status](https://build.appcenter.ms/v0.1/apps/ca98a10c-2613-4600-a16a-5ddc9a9ff1c3/branches/master/badge)](https://appcenter.ms/users/raginmari/apps/RAGTextField-Demo-App/build/branches)
[![Version](https://img.shields.io/cocoapods/v/RAGTextField.svg?style=flat)](http://cocoapods.org/pods/RAGTextField)
[![License](https://img.shields.io/cocoapods/l/RAGTextField.svg?style=flat)](http://cocoapods.org/pods/RAGTextField)
[![Platform](https://img.shields.io/cocoapods/p/RAGTextField.svg?style=flat)](http://cocoapods.org/pods/RAGTextField)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Subclass of `UITextField` that adds an animated placeholder and an optional hint label below the text.

It supports an arbitrary view in the background of the text (outline and underline views are provided) as well as the left and right views, text alignments, flexible padding and offsets.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

<img src="https://user-images.githubusercontent.com/1574034/53834942-8fad9580-3f8c-11e9-944a-ff22aee1bc58.png" width="15%"></img>
<img src="https://user-images.githubusercontent.com/1574034/53834949-94724980-3f8c-11e9-9695-b2b4991da67e.png" width="15%"></img> 
<img src="https://user-images.githubusercontent.com/1574034/53834951-950ae000-3f8c-11e9-8abd-4558d3fb0a72.png" width="15%"></img>
<img src="https://user-images.githubusercontent.com/1574034/53834952-95a37680-3f8c-11e9-8694-58248b29c56b.png" width="15%"></img> 
<img src="https://user-images.githubusercontent.com/1574034/53834953-95a37680-3f8c-11e9-9dc3-f27474ba2e9b.png" width="15%"></img> 
<img src="https://user-images.githubusercontent.com/1574034/53834954-95a37680-3f8c-11e9-92fd-8833bd466bc0.png" width="15%"></img> 

## Requirements

Written in Swift 5. Requires iOS 9. 

Swift support:

| Swift version | Library version |
|---------------|-----------------|
| 3             | <= 0.2.1        |
| 4             | <= 0.12.1       |
| 5             | from 0.13.0     |

## Installation

`RAGTextField` is available through [CocoaPods](http://cocoapods.org) and [Carthage](https://github.com/Carthage/Carthage).

#### Cocoapods

Add the following line to your Podfile:

```ruby
pod "RAGTextField"
```

Please try the pod by calling `pod try RAGTextField` in the terminal.

#### Carthage

Add the following line to your Cartfile:

```ruby
github "raginmari/RAGTextField"
```

## How to use

After installing the lib and importing the module `RAGTextField`, the text field can be used like any other text field (both in the code and in your storyboards and nibs).

These are the key differences to `UITextField`:
- A **floating placeholder** inspired by the one described in Google's [Material Design](https://material.io/guidelines/components/text-fields.html#text-fields-labels) guidelines.
- A **hint label** below the actual text which can be used to provide additional hints or report errors.
- A view in the **background of the text** (excluding the placeholder and the hint label) which can be used to style the appearance of the text entry. The example project uses this capability.

Many properties of the text field are `IBInspectable`.

#### The placeholder

The placeholder replaces the superclass placeholder. Values assigned to the `placeholder` property are handled exclusively by `RAGTextField`. The text alignment of the placeholder matches the text alignment of the text field.

These are the different ways you can **customize the appearance** and behavior of the placeholder:

- Use the `placeholderFont` property to assign a **custom font or font size** to the placeholder. By default, the placeholder uses the font of the text field.
- Use the `placeholderColor` property to **change the color** of the placeholder. By default, the placeholder uses the text color of the text field.
- Use the `transformedPlaceholderColor` property to set a color that is applied to the placeholder when the text field is being edited and the placeholder is transformed to its floating position.
- Use the `placeholderScaleWhenEditing` property to specify the **scale applied to the placeholder** in its floating position above the text. The default value is 1.
- Use the `scaledPlaceholderOffset` property to offset the placeholder in its floating position from the text. The default value is 0. Positive values **move the placeholder up**, away from the text.
- The value of the `placeholderMode` property determines the **behavior of the placeholder**:
  - `scalesWhenEditing` (default): the placeholder is transformed as soon as the text field becomes the first responder. Moreover, the placeholder remains transformed as long as there is text in the text field.
  - `scalesWhenNotEmpty`: the placeholder is transformed as soon as and for as long as there is text in the text field.
  - `scalesAlways`: the placeholder is always displayed in the transformed position.
  - `simple`: the floating placeholder is disabled. The behavior of the placeholder resembles that of the superclass.
- Use the `placeholderAnimationDuration` property to adjust the **duration of the animation of the placeholder** when it moves to or from the floating position. If the value is `nil`, a default value is used. Set the value to 0 to **disable** the placeholder animation.

#### The hint label

The hint label is disabled by default and while the value of the `hint` property is `nil`. If a non-nil value is assigned to the `hint` property (including the empty string), the layout of the label is updated and space for the hint label is reserved. The text alignment of the hint matches the text alignment of the text field. The hint supports multiple lines of text.

These are the different ways you can **customize the appearance** of the hint:

- Use the `hintFont` property to assign a **custom font or font size** to the hint. By default, the hint uses the font of the text field.
- Use the `hintColor` property to **change the color** of the hint. By default, the hint uses the text color of the text field.
- Use the `hintOffset` property to offset the hint label from the text. The default value is 0. Positive values **move the hint down**, away from the text.
- Use the `layoutAlwaysIncludesHint` property to always keep the hint label in the layout even if the `hint`value is `nil`. The default value of this property is `false`.

#### The text background view

Add a view to the background of the text by assigning an arbitrary view to the `textBackgroundView` property. Its frame is updated by `RAGTextField` when required. The view is sized so that it matches the size of the text (and placeholder and/or hint) plus padding.

These are the different ways you can **customize the appearance** of the text background view.

- Use the `textPadding` property to apply padding to the text. The padding expands the text background view. By default, the padding is `.zero`.
- Use the `textPaddingMode` property to apply the text padding to just the text or in addition to that to the placeholder, the hint or both. Can be used to wrap the respective subviews into the text background view. The example project uses the text padding mode.

#### The underline view

Use the class `UnderlineView` to draw an **animated underline** below the text. Assign an instance of the class to the `textBackgroundView` property of the text field. The appearance of the underline can either be updated automatically by the view itself (see its `textField` property) or be manually controlled from a view controller or text field delegate. The example project uses the underline view.

#### The outline view
Use the class `OutlineView` to draw an outline around the text. The outline can have rounded corners and it can be filled and inset. Assign an instance of the class to the `textBackgroundView` property of the text field. Depending on the `textPaddingMode` value, the outline optionally includes the placeholder and/or hint label.

## Bond
If you want to use the text field with the fantastic [Bond](https://github.com/DeclarativeHub/Bond), you can add these extensions so that you can bind to the `hint` and `placeholder` properties:

```swift
extension ReactiveExtensions where Base: RAGTextField {
    
    var hint: Bond<String?> {
        return bond { textField, hint in
            textField.hint = hint
        }
    }
    
    var placeholder: Bond<String?> {
        return bond { textField, placeholder in
            textField.placeholder = placeholder
        }
    }
}
```

## Known issues

These are known or possible issues with `RAGTextField`:

- The `attributedText` property of UITextField *may* not be supported.
- The `attributedPlaceholder` of UITextField is not supported.
- The `borderStyle` property should be `.none`.

These issues will hopefully be addressed in future updates.

## Author

raginmari, reimar.twelker@web.de

## License

RAGTextField is available under the MIT license. See the LICENSE file for more info.
