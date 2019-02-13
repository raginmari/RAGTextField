# Change Log
All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org/).

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