//
// Copyright (c) 2017 Reimar Twelker
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import UIKit

private enum Constants {
    
    /// The string used to measure the height of an arbitrary string.
    static let textSizeMeasurementString = "X"
    
    /// The duration of the placeholder animation if no duration is set by the user.
    static let defaultPlaceholderAnimationDuration = CFTimeInterval(0.2)
    
    /// The space between the left and right overlay views and the text.
    static let overlaySpaceToText: CGFloat = 7.0
}

open class RAGTextField: UITextField {
    
    /// Represents a horizontal position. Either left or right.
    private enum HorizontalPosition {
        case left, right
    }
    
    private final class PlaceholderConstraints {
        
        var normalX: NSLayoutConstraint?
        var normalY: NSLayoutConstraint?
        var scaledX: NSLayoutConstraint?
        var scaledY: NSLayoutConstraint?
        
        func clearHorizontalConstraints() {
            
            normalX?.isActive = false
            normalX = nil
            
            scaledX?.isActive = false
            scaledX = nil
        }
        
        func clearVerticalConstraints() {
            
            normalY?.isActive = false
            normalY = nil
            
            scaledY?.isActive = false
            scaledY = nil
        }
    }
    
    /// The font of the text field.
    ///
    /// If the hint font is `nil`, the given font is used for the hint.
    ///
    /// If the placeholder font is `nil`, the given font is used for the
    /// placeholder.
    open override var font: UIFont? {
        didSet {
            if hintFont == nil {
                hintLabel.font = font
            }
            
            if placeholderFont == nil {
                placeholderLabel.font = font
            }
            
            invalidateIntrinsicContentSize()
            placeholderConstraints.clearVerticalConstraints()
            setNeedsUpdateConstraints()
        }
    }
    
    /// The text alignment of the text field.
    ///
    /// The given value is applied to the hint and the placeholder as well.
    open override var textAlignment: NSTextAlignment {
        didSet {
            hintLabel.textAlignment = textAlignment
            placeholderView.textAlignment = textAlignment
            
            placeholderConstraints.clearHorizontalConstraints()
            setNeedsUpdateConstraints()
        }
    }
    
    /// The text value of the text field. Updates the position of the placeholder.
    open override var text: String? {
        didSet {
            updatePlaceholderTransform(animated: true)
        }
    }
    
    // MARK: Hint
    
    private let hintLabel = UILabel()
    
    /// The text value of the hint.
    ///
    /// If `nil`, the hint label is removed from the layout.
    @IBInspectable open var hint: String? {
        set {
            if newValue == nil {
                hintLabel.text = ""
                hintLabel.isHidden = true
            } else {
                hintLabel.text = newValue
                hintLabel.isHidden = false
            }
            
            invalidateIntrinsicContentSize()
        }
        get {
            return hintLabel.text
        }
    }
    
    /// The font used for the hint.
    ///
    /// If `nil`, the font of the text field is used instead.
    open var hintFont: UIFont? {
        set {
            hintLabel.font = newValue ?? font
        }
        get {
            return hintLabel.font
        }
    }
    
    /// The text color of the hint.
    ///
    /// If `nil`, the text color of the text field is used instead.
    @IBInspectable open var hintColor: UIColor? {
        set {
            hintLabel.textColor = newValue ?? textColor
        }
        get {
            return hintLabel.textColor
        }
    }
    
    /// The computed height of the hint in points.
    private var hintHeight: CGFloat {
        
        guard !hintLabel.isHidden else {
            return 0
        }
        
        return measureTextHeight(using: hintLabel.font)
    }
    
    // MARK: Placeholder
    
    /// Contains the placeholder view.
    ///
    /// Required so that when the placeholder view constraints are animated, the cursor of the text field is not animated as well.
    private let placeholderContainerView = UIView()
    
    /// Contains the placeholder label.
    ///
    /// Required so that the placeholder label can be transformed using Core Animation as part of a layout that otherwise uses Auto Layout.
    private let placeholderView = PlaceholderView()
    
    /// Computed variable that returns the placeholder label embedded in the placeholder view.
    private var placeholderLabel: UILabel {
        return placeholderView.label
    }
    
    /// The current set of positional placeholder constraints.
    ///
    /// Contains a pair of constraints for the normal position and a pair for the scaled position, only one of which is active at all times.
    private let placeholderConstraints = PlaceholderConstraints()
    
    /// The text value of the placeholder.
    override open var placeholder: String? {
        set {
            placeholderLabel.text = newValue ?? ""
        }
        get {
            return placeholderLabel.text
        }
    }
    
    /// The font used for the placeholder.
    ///
    /// If `nil`, the font of the text field is used instead.
    open var placeholderFont: UIFont? {
        set {
            placeholderLabel.font = newValue ?? font
        }
        get {
            return placeholderLabel.font
        }
    }
    
    /// The text color of the placeholder.
    ///
    /// If `nil`, the text color of the text field is used instead.
    @IBInspectable open var placeholderColor: UIColor? {
        set {
            placeholderLabel.textColor = newValue ?? textColor
        }
        get {
            return placeholderLabel.textColor
        }
    }
    
    /// The scale applied to the placeholder when it is moved to the scaled
    /// position.
    ///
    /// Negative values are clamped to `0`. The default value is `1`.
    @IBInspectable open var placeholderScaleWhenEditing: CGFloat = 1.0 {
        didSet {
            placeholderScaleWhenEditing = max(0.0, placeholderScaleWhenEditing)
            
            invalidateIntrinsicContentSize()
            placeholderConstraints.clearVerticalConstraints()
            setNeedsUpdateConstraints()
        }
    }
    
    /// The vertical offset of the scaled placeholder from the top of the text.
    ///
    /// Can be used to put a little distance between the placeholder and the text.
    @IBInspectable open var scaledPlaceholderOffset: CGFloat = 0.0 {
        didSet {
            invalidateIntrinsicContentSize()
            placeholderConstraints.clearVerticalConstraints()
            setNeedsUpdateConstraints()
        }
    }
    
    /// Controls how the placeholder is being displayed, whether it is scaled
    /// and whether the scaled placeholder is taken into consideration when the
    /// view is layed out.
    ///
    /// The default value is `.scalesWhenNotEmpty`.
    open var placeholderMode: RAGTextFieldPlaceholderMode = .scalesWhenNotEmpty {
        didSet {
            invalidateIntrinsicContentSize()
            placeholderConstraints.clearVerticalConstraints()
            setNeedsUpdateConstraints()
        }
    }
    
    /// The computed height of the untransformed placeholder in points.
    private var placeholderHeight: CGFloat {
        
        return measureTextHeight(using: placeholderLabel.font)
    }
    
    /// The duration of the animation transforming the placeholder to and from
    /// the scaled position. If `nil`, a default duration is used. Set to 0 to
    /// disable the animation.
    open var placeholderAnimationDuration: CFTimeInterval? = nil
    
    /// Whether the view is configured to animate the placeholder.
    ///
    /// The value is `false` only if the `placeholderAnimationDuration` is explicitly set to `0`.
    private var animatesPlaceholder: Bool {
        let duration = placeholderAnimationDuration ?? Constants.defaultPlaceholderAnimationDuration
        let result = duration > CFTimeInterval(0)
        
        return result
    }
    
    /// Keeps track of whether the placeholder is currently in the scaled
    /// position.
    ///
    /// Used to prevent unnecessary animations or updates of the
    /// transform.
    private var isPlaceholderTransformedToScaledPosition = false
    
    // MARK: Text background view
    
    /// An optional view added to the text field. Its frame is set so that it is
    /// the size of the text and its horizontal and vertical padding.
    open weak var textBackgroundView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            
            guard let view = textBackgroundView else {
                return
            }
            
            view.isUserInteractionEnabled = false
            view.translatesAutoresizingMaskIntoConstraints = true
            
            addSubview(view)
            sendSubviewToBack(view)
            
            setNeedsLayout()
        }
    }
    
    /// Computes the frame of the text background view.
    ///
    /// - Returns: The frame
    private func computeTextBackgroundViewFrame() -> CGRect {
        
        let y = computeTopInsetToText() - verticalTextPadding
        let h = verticalTextPadding + measureTextHeight() + verticalTextPadding
        let frame = CGRect(x: 0, y: y, width: bounds.width, height: h)
        
        return frame
    }
    
    /// The padding applied to the left and right of the text rectangle. Can be
    /// used to reserve more space for the `textBackgroundView`.
    @IBInspectable open var horizontalTextPadding: CGFloat = 0.0 {
        didSet {
            invalidateIntrinsicContentSize()
            placeholderConstraints.clearVerticalConstraints()
            setNeedsUpdateConstraints()
        }
    }
    
    /// The padding applied to the top and bottom of the text rectangle. Can be
    /// used to reserve more space for the `textBackgroundView`.
    @IBInspectable open var verticalTextPadding: CGFloat = 0.0 {
        didSet {
            invalidateIntrinsicContentSize()
            placeholderConstraints.clearVerticalConstraints()
            setNeedsUpdateConstraints()
        }
    }
    
    // MARK: Overlay views
    
    /// Whether the left view is displayed to the left or to the right of the text.
    private var leftViewPosition: HorizontalPosition {
        
        if textAlignment == .natural && UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            return .right
        } else {
            return .left
        }
    }
    
    private var isLeftViewVisible: Bool {
        
        guard leftView != nil else { return false }
        return isOverlayVisible(with: leftViewMode)
    }
    
    /// Whether the left view is displayed to the left or to the right of the text.
    private var rightViewPosition: HorizontalPosition {
        
        if textAlignment == .natural && UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            return .left
        } else {
            return .right
        }
    }
    
    private var isRightViewVisible: Bool {
        
        guard rightView != nil else { return false }
        return isOverlayVisible(with: rightViewMode)
    }
    
    private func isOverlayVisible(with viewMode: UITextField.ViewMode) -> Bool {
        
        switch viewMode {
        case .always:
            return true
        case .whileEditing:
            return isEditing
        case .unlessEditing:
            return !isEditing
        case .never:
            return false
        }
    }
    
    // MARK: Clear button
    
    /// Whether the clear button is displayed to the left or to the right of the text.
    private var clearButtonPosition: HorizontalPosition {
        
        if textAlignment == .natural && UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            return .left
        } else {
            return .right
        }
    }
    
    private func isClearButtonVisible() -> Bool {
        
        switch clearButtonMode {
        case .always:
            return true
        case .whileEditing:
            return isEditing && hasText
        case .unlessEditing:
            return !isEditing && hasText
        case .never:
            return false
        }
    }
    
    // MARK: - Init
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(hintLabel)
        setupHintLabel()
        
        addSubview(placeholderContainerView)
        setupPlaceholderContainerView()
        
        placeholderContainerView.addSubview(placeholderView)
        setupPlaceholderView()
        
        // Listen for text changes on self
        let action = #selector(didChangeText)
        NotificationCenter.default.addObserver(self, selector: action, name: UITextField.textDidChangeNotification, object: self)
    }
    
    @objc private func didChangeText() {
        
        updatePlaceholderTransform(animated: true)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        // Copy the placeholder from the super class and set it nil
        if super.placeholder != nil {
            placeholder = super.placeholder
            super.placeholder = nil
        }
    }
    
    /// Measures the height of the given text using the given font.
    ///
    /// - Parameters:
    ///   - font: The font to use
    ///   - text: The text whose height is measured
    /// - Returns: The height of the given string
    private func measureTextHeight(text: String = Constants.textSizeMeasurementString, using font: UIFont? = nil) -> CGFloat {
        
        let font = font ?? self.font!
        let boundingSize = text.size(using: font)
        let result = ceil(boundingSize.height)
        
        return result
    }
    
    // MARK: - Hint
    
    /// Sets initial properties and constraints of the hint label.
    private func setupHintLabel() {
        
        hint = nil
        hintLabel.font = font
        hintLabel.textAlignment = textAlignment
    }
    
    private func hintFrame(forBounds bounds: CGRect) -> CGRect {
        
        let w = bounds.width - 2 * horizontalTextPadding
        let h = measureTextHeight(using: hintLabel.font)
        let x = horizontalTextPadding
        let y = bounds.height - h
        let frame = CGRect(x: x, y: y, width: w, height: h)
        
        return frame
    }
    
    // MARK: - Placeholder
    
    private func setupPlaceholderView() {
        
        placeholderLabel.text = ""
        placeholderLabel.font = font
        
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.textAlignment = .natural
    }
    
    private func setupPlaceholderContainerView() {
        
        placeholderContainerView.backgroundColor = .clear
        placeholderContainerView.isUserInteractionEnabled = false
        placeholderContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["v": placeholderContainerView]
        let x = NSLayoutConstraint.constraints(withVisualFormat: "H:|[v]|", options: [], metrics: nil, views: views)
        let y = NSLayoutConstraint.constraints(withVisualFormat: "V:|[v]|", options: [], metrics: nil, views: views)
        addConstraints(x + y)
    }
    
    /// Returns whether the placeholder should be displayed in the scaled
    /// position or in the default position.
    ///
    /// - Returns: `true` if the placeholder should be displayed in the scaled position
    private func shouldDisplayScaledPlaceholder() -> Bool {
        let result: Bool
        
        switch placeholderMode {
        case .scalesWhenEditing:
            result = (text != nil) && !text!.isEmpty || isFirstResponder
        case .scalesWhenNotEmpty:
            result = (text != nil) && !text!.isEmpty
        default:
            result = false
        }
        
        return result
    }
    
    private func shouldDisplayPlaceholder() -> Bool {
        let result: Bool
        
        switch placeholderMode {
        case .scalesWhenEditing:
            result = true
        case .scalesWhenNotEmpty:
            result = true
        case .simple:
            result = (text == nil) || text!.isEmpty
        }
        
        return result
    }
    
    private func scaledPlaceholderHeight() -> CGFloat {
        guard placeholderMode.scalesPlaceholder else {
            return 0
        }
        
        return ceil(placeholderScaleWhenEditing * placeholderHeight)
    }
    
    // MARK: - Overlay views
    
    open override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        
        let superValue = super.leftViewRect(forBounds: bounds)
        let size = superValue.size
        let x = horizontalTextPadding
        let y = computeTopInsetToText() + 0.5 * (measureTextHeight() - size.height)
        let rect = CGRect(origin: CGPoint(x: x, y: y), size: size)
        
        return rect
    }
    
    open override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        
        let superValue = super.rightViewRect(forBounds: bounds)
        let size = superValue.size
        let x = bounds.width - horizontalTextPadding - size.width
        let y = computeTopInsetToText() + 0.5 * (measureTextHeight() - size.height)
        let rect = CGRect(origin: CGPoint(x: x, y: y), size: size)
        
        return rect
    }
    
    // MARK: - UITextField
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        
        return textAndEditingRect(forBounds: bounds)
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        
        return textAndEditingRect(forBounds: bounds)
    }
    
    private func textAndEditingRect(forBounds bounds: CGRect) -> CGRect {
        
        let topInset = computeTopInsetToText()
        let leftInset = computeLeftInsetToText()
        let bottomInset = computeBottomInsetToText()
        let rightInset = computeRightInsetToText()
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        let rect = bounds.inset(by: insets)
        
        return rect
    }
    
    private func computeTopInsetToText() -> CGFloat {
        
        let placeholderOffset = placeholderMode.scalesPlaceholder ? scaledPlaceholderOffset : 0.0
        let inset = ceil(scaledPlaceholderHeight() + placeholderOffset + verticalTextPadding)
        
        return inset
    }
    
    private func computeLeftInsetToText() -> CGFloat {
        
        let inset: CGFloat
        if isLeftViewVisible && leftViewPosition == .left {
            inset = leftViewRect(forBounds: bounds).maxX + Constants.overlaySpaceToText
        } else if isRightViewVisible && rightViewPosition == .left {
            inset = leftViewRect(forBounds: bounds).maxX + Constants.overlaySpaceToText
        } else if isClearButtonVisible() && clearButtonPosition == .left {
            inset = clearButtonRect(forBounds: bounds).maxX + Constants.overlaySpaceToText
        } else {
            inset = horizontalTextPadding
        }
        
        return inset
    }
    
    private func computeBottomInsetToText() -> CGFloat {
        
        let inset = ceil(hintHeight + verticalTextPadding)
        
        return inset
    }
    
    private func computeRightInsetToText() -> CGFloat {
        
        let inset: CGFloat
        if isRightViewVisible && rightViewPosition == .right {
            inset = bounds.width - rightViewRect(forBounds: bounds).minX + Constants.overlaySpaceToText
        } else if isLeftViewVisible && leftViewPosition == .right {
            inset = bounds.width - rightViewRect(forBounds: bounds).minX + Constants.overlaySpaceToText
        } else if isClearButtonVisible() && clearButtonPosition == .right {
            inset = bounds.width - clearButtonRect(forBounds: bounds).minX + Constants.overlaySpaceToText
        } else {
            inset = horizontalTextPadding
        }
        
        return inset
    }
    
    private func computeLeadingInsetToText() -> CGFloat {
        
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            return computeRightInsetToText()
        } else {
            return computeLeftInsetToText()
        }
    }
    
    private func computeTrailingInsetToText() -> CGFloat {
        
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            return computeLeftInsetToText()
        } else {
            return computeRightInsetToText()
        }
    }
    
    open override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        
        let superValue = super.clearButtonRect(forBounds: bounds)
        let size = superValue.size
        let y = computeTopInsetToText() + 0.5 * (measureTextHeight() - size.height)
        
        let x: CGFloat
        if clearButtonPosition == .left {
            x = horizontalTextPadding
        } else {
            x = bounds.width - size.width - horizontalTextPadding
        }
        
        let clearButtonRect = CGRect(x: x, y: y, width: size.width, height: size.height)
        
        return clearButtonRect
    }
    
    // MARK: - UIResponder
    
    open override func becomeFirstResponder() -> Bool {
        defer {
            updatePlaceholderTransform(animated: true)
        }
        
        return super.becomeFirstResponder()
    }
    
    open override func resignFirstResponder() -> Bool {
        defer {
            updatePlaceholderTransform(animated: true)
        }
        
        return super.resignFirstResponder()
    }
    
    // MARK: - Animations
    
    private func updatePlaceholderTransform(animated: Bool = false) {
        
        var needsAnimating = false
        let duration = placeholderAnimationDuration ?? Constants.defaultPlaceholderAnimationDuration
        
        switch (animated, shouldDisplayScaledPlaceholder(), isPlaceholderTransformedToScaledPosition) {
        case (_, true, false):
            updatePlaceholderConstraints(scaled: true)
            placeholderView.scaleLabel(to: placeholderScaleWhenEditing, animated: animated, duration: duration)
            isPlaceholderTransformedToScaledPosition = true
            needsAnimating = animated
        case (_, false, true):
            updatePlaceholderConstraints(scaled: false)
            placeholderView.scaleLabel(to: 1.0, animated: animated, duration: duration)
            isPlaceholderTransformedToScaledPosition = false
            needsAnimating = animated
        default:
            break
        }
        
        if animated && needsAnimating {
            UIView.animate(withDuration: duration) { [unowned self] in
                self.placeholderContainerView.layoutIfNeeded()
            }
        }
        
        // Update the general visibility of the placeholder
        if shouldDisplayPlaceholder() != !placeholderView.isHidden {
            placeholderView.isHidden.toggle()
        }
    }
    
    private func updatePlaceholderConstraints(scaled: Bool) {
        
        // Note: Deactivate first, then activate. Otherwise, Auto Layout complains about unsatisfiable constraints.
        if scaled {
            placeholderConstraints.normalX?.isActive = false
            placeholderConstraints.normalY?.isActive = false
            placeholderConstraints.scaledX?.isActive = true
            placeholderConstraints.scaledY?.isActive = true
        } else {
            placeholderConstraints.scaledX?.isActive = false
            placeholderConstraints.scaledY?.isActive = false
            placeholderConstraints.normalX?.isActive = true
            placeholderConstraints.normalY?.isActive = true
        }
    }
    
    // MARK: - UIView
    
    open override func updateConstraints() {
        
        if placeholderConstraints.normalX == nil {
            placeholderConstraints.normalX = makeNormalHorizontalPlaceholderConstraint(textAlignment: textAlignment)
            placeholderConstraints.normalX?.isActive = !isPlaceholderTransformedToScaledPosition
        }
        
        if placeholderConstraints.normalY == nil {
            placeholderConstraints.normalY = makeNormalVerticalPlaceholderConstraint()
            placeholderConstraints.normalY?.isActive = !isPlaceholderTransformedToScaledPosition
        }
        
        if placeholderConstraints.scaledX == nil {
            placeholderConstraints.scaledX = makeScaledHorizontalPlaceholderConstraint(textAlignment: textAlignment)
            placeholderConstraints.scaledX?.isActive = isPlaceholderTransformedToScaledPosition
        }
        
        if placeholderConstraints.scaledY == nil {
            placeholderConstraints.scaledY = makeScaledVerticalPlaceholderConstraint()
            placeholderConstraints.scaledY?.isActive = isPlaceholderTransformedToScaledPosition
        }
        
        super.updateConstraints()
    }
    
    open override func layoutSubviews() {
        
        super.layoutSubviews()
        
        // Update the frame of the optional text background view
        textBackgroundView?.frame = computeTextBackgroundViewFrame()
        
        // Update the frame of the hint
        if !hintLabel.isHidden {
            hintLabel.frame = hintFrame(forBounds: bounds)
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        
        let intrinsicHeight = computeTopInsetToText() + measureTextHeight() + computeBottomInsetToText()
        let size = CGSize(width: UIView.noIntrinsicMetric, height: ceil(intrinsicHeight))
        
        return size
    }
    
    // MARK: - Constraints
    
    private func makeNormalHorizontalPlaceholderConstraint(textAlignment: NSTextAlignment) -> NSLayoutConstraint {
        
        let constraint: NSLayoutConstraint
        
        switch (textAlignment, UIApplication.shared.userInterfaceLayoutDirection) {
        case (.natural, .leftToRight), (.justified, .leftToRight), (.left, _):
            constraint = placeholderView.leadingAnchor.constraint(equalTo: placeholderContainerView.leadingAnchor)
        case (.natural, .rightToLeft), (.justified, .rightToLeft), (.right, _):
            constraint = placeholderContainerView.trailingAnchor.constraint(equalTo: placeholderView.trailingAnchor)
        case (.center, _):
            constraint = placeholderView.centerXAnchor.constraint(equalTo: placeholderContainerView.centerXAnchor)
        }
        
        constraint.constant = normalHorizontalPlaceholderConstraintConstant(for: textAlignment)
        
        return constraint
    }
    
    private func makeNormalVerticalPlaceholderConstraint() -> NSLayoutConstraint {
        
        let constraint = placeholderView.centerYAnchor.constraint(equalTo: placeholderContainerView.topAnchor)
        constraint.constant = normalVerticalPlaceholderConstraintConstant()
        
        return constraint
    }
    
    private func normalHorizontalPlaceholderConstraintConstant(for textAlignment: NSTextAlignment) -> CGFloat {
        
        switch (textAlignment, UIApplication.shared.userInterfaceLayoutDirection) {
        case (.natural, .leftToRight), (.justified, .leftToRight), (.left, _):
            return computeLeftInsetToText()
        case (.natural, .rightToLeft), (.justified, .rightToLeft), (.right, _):
            return computeRightInsetToText()
        case (.center, _):
            return 0.0
        }
    }
    
    private func normalVerticalPlaceholderConstraintConstant() -> CGFloat {
        
        return computeTopInsetToText() + 0.5 * measureTextHeight()
    }
    
    private func makeScaledHorizontalPlaceholderConstraint(textAlignment: NSTextAlignment) -> NSLayoutConstraint {
        
        let constraint: NSLayoutConstraint
        
        switch (textAlignment, UIApplication.shared.userInterfaceLayoutDirection) {
        case (.natural, .leftToRight), (.justified, .leftToRight), (.left, _):
            constraint = placeholderView.leadingAnchor.constraint(equalTo: placeholderContainerView.leadingAnchor)
        case (.natural, .rightToLeft), (.justified, .rightToLeft), (.right, _):
            constraint = placeholderContainerView.trailingAnchor.constraint(equalTo: placeholderView.trailingAnchor)
        case (.center, _):
            constraint = placeholderView.centerXAnchor.constraint(equalTo: placeholderContainerView.centerXAnchor)
        }
        
        constraint.constant = scaledHorizontalPlaceholderConstraintConstant(for: textAlignment)
        
        return constraint
    }
    
    private func makeScaledVerticalPlaceholderConstraint() -> NSLayoutConstraint {
        
        let constraint = placeholderView.centerYAnchor.constraint(equalTo: placeholderContainerView.topAnchor)
        constraint.constant = scaledVerticalPlaceholderConstraintConstant()
        
        return constraint
    }
    
    private func scaledHorizontalPlaceholderConstraintConstant(for textAlignment: NSTextAlignment) -> CGFloat {
        
        if textAlignment == .center {
            return 0.0
        }
        
        return horizontalTextPadding
    }
    
    private func scaledVerticalPlaceholderConstraintConstant() -> CGFloat {
        
        let scaledHeight = placeholderScaleWhenEditing * measureTextHeight(using: placeholderLabel.font)
        return computeTopInsetToText() - verticalTextPadding - scaledPlaceholderOffset - 0.5 * scaledHeight
    }
}
