# Change Log
All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org/).

## 0.13.0

Updated to Swift 5.

## 0.12.1

### Fixed
- Minor bugfix

## 0.12.0

### Added
- Added support of multi-line hints.

## 0.11.0

### Added
- Added property `transformedPlaceholderColor` that sets the placeholder color when the text field is being edited and the placeholder is in its floating position.
- Added property `layoutAlwaysIncludesHint` that always keeps the hint label in the layout even if the `hint` is `nil`.

### Fixed
- Fixed the resizing of the placeholder when its text or font are changed.

## 0.10.0

After updating to this version, you may have to adjust the `placeholderMode` values of your text fields because the default placeholder mode has changed.

### Added
- Added the `textField` property to the `UnderlineView`. If not `nil`, the underline updates its appearance in accordance with the editing state of the text field.

### Changed
- The default placeholder mode has been changed from "when not empty" to "when editing".

## 0.9.1

### Fixed
- Fixed placeholder animation on iOS 9

## 0.9.0

### Changed
- Implemented a much more helpful example project for the pod. Please "try".

### Fixed
- The horizontal text position would not be updated if the left or right views of the text field were shown or hidden

## 0.8.1

### Fixed
- View performs a layout pass when the text padding mode is set
- View no longer animates the placeholder when the text propert is set

## 0.8.0

### Changed
- The height of the background line of the `UnderlineView` is always 1 pixel wide. The property `foregroundLineWidth` (formerly "lineWidth") affects the height of the foreground line only (API breaking change).

### Fixed
- Fixed default placeholder color
- Fixed initial placeholder text alignment

## 0.7.0

### Added
- Added property `textPaddingMode`. Used to apply the `textPadding` to just the text, or in addition to that to the placeholder, the hint or both.

## 0.6.1

### Fixed
- Fixed horizontal intrinsic content size

## 0.6.0

### Changed
- Replaced `horizontalTextPadding` and `verticalTextPadding` with `textPadding` of type `UIEdgeInsets` (API breaking change). Values can be set in IB.

## 0.5.0

### Added
- Added optional vertical `hintOffset` of the hint label to the bottom of the text
- Added Carthage support

## 0.4.0

Pretty much redid the whole thing. There should be no API-breaking changes.

### Added
- Added support for right-to-left languages
- Added support for the left and right views
- Added `UnderlineView` that can be used with the text view

### Changed
- Updated to Swift 4
- Improved handling of text alignments
- Improved documentation
- Bugfixes