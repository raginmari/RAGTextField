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
    }
    
    /// If `true`, the next invocation of `updateConstraints` updates the existing horizontal placeholder constraints.
    private var needsUpdateOfHorizontalPlaceholderConstraints = false
    
    private func setNeedsUpdateHorizontalPlaceholderConstraints() {
        
        needsUpdateOfHorizontalPlaceholderConstraints = true
        setNeedsUpdateConstraints()
    }
    
    /// If `true`, the next invocation of `updateConstraints` updates the existing vertical placeholder constraints.
    private var needsUpdateOfVerticalPlaceholderConstraints = false
    
    private func setNeedsUpdateVerticalPlaceholderConstraints() {
        
        needsUpdateOfVerticalPlaceholderConstraints = true
        setNeedsUpdateConstraints()
    }
    
    private func setNeedsUpdatePlaceholderConstraints() {
        
        needsUpdateOfHorizontalPlaceholderConstraints = true
        needsUpdateOfVerticalPlaceholderConstraints = true
        setNeedsUpdateConstraints()
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
                placeholderView.invalidateIntrinsicContentSize()
            }
            
            invalidateIntrinsicContentSize()
            setNeedsUpdateVerticalPlaceholderConstraints()
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
            setNeedsUpdateHorizontalPlaceholderConstraints()
            updatePlaceholderTransform()
            updatePlaceholderColor()
        }
    }
    
    // MARK: Hint
    
    private let hintLabel = UILabel()
    
    /// The text value of the hint.
    ///
    /// If `nil`, the hint label is removed from the layout.
    @IBInspectable open var hint: String? {
        set {
            hintLabel.text = newValue
            
            updateHintVisibility()
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
        didSet {
            hintLabel.font = hintFont ?? font
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
    
    /// The vertical offset of the hint from the bottom of the text.
    ///
    /// Can be used to put a little distance between the hint and the text. The default value is 0.
    @IBInspectable open var hintOffset: CGFloat = 0.0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    /// If `true`, the layout always includes the hint. Otherwise, if the `hint` is `nil`, it is removed from the layout.
    /// The default value is `false`.
    @IBInspectable open var layoutAlwaysIncludesHint: Bool = false {
        didSet {
            updateHintVisibility()
            invalidateIntrinsicContentSize()
        }
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
            placeholderLabel.text = newValue
            placeholderView.invalidateIntrinsicContentSize()
        }
        get {
            return placeholderLabel.text
        }
    }
    
    /// The font used for the placeholder.
    ///
    /// If `nil`, the font of the text field is used instead.
    open var placeholderFont: UIFont? {
        didSet {
            placeholderLabel.font = placeholderFont ?? font
            placeholderView.invalidateIntrinsicContentSize()
        }
    }
    
    /// The text color of the placeholder.
    ///
    /// If `nil`, the text color of the text field is used instead.
    @IBInspectable open var placeholderColor: UIColor? {
        didSet {
            updatePlaceholderColor()
        }
    }
    
    /// The text color of the placeholder while it is transformed and being edited.
    ///
    /// If `nil` (default), the `placeholderColor` is applied to the transformed placeholder.
    @IBInspectable open var transformedPlaceholderColor: UIColor? {
        didSet {
            updatePlaceholderColor()
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
            setNeedsUpdateVerticalPlaceholderConstraints()
        }
    }
    
    /// The vertical offset of the scaled placeholder from the top of the text.
    ///
    /// Can be used to put a little distance between the placeholder and the text. The default value is 0.
    @IBInspectable open var scaledPlaceholderOffset: CGFloat = 0.0 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsUpdateVerticalPlaceholderConstraints()
        }
    }
    
    /// Controls how the placeholder is being displayed, whether it is scaled
    /// and whether the scaled placeholder is taken into consideration when the
    /// view is layed out.
    ///
    /// The default value is `.scalesWhenEditing`.
    open var placeholderMode: RAGTextFieldPlaceholderMode = .scalesWhenEditing {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsUpdateVerticalPlaceholderConstraints()
            updatePlaceholderTransform()
            updatePlaceholderColor()
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
        
        let y, h: CGFloat
        switch textPaddingMode {
        case .text:
            y = computeTopInsetToText() - textPadding.top
            h = textPadding.top + measureTextHeight() + textPadding.bottom
        case .textAndPlaceholder:
            y = 0
            h = computeTopInsetToText() + measureTextHeight() + textPadding.bottom
        case .textAndPlaceholderAndHint:
            y = 0
            h = bounds.height
        case .textAndHint:
            y = computeTopInsetToText() - textPadding.top
            h = textPadding.top + measureTextHeight() + computeBottomInsetToText()
        }
        
        let frame = CGRect(x: 0, y: y, width: bounds.width, height: h)
        
        return frame
    }
    
    /// The padding applied to the text rectangle.
    ///
    /// The `textBackgroundView` is inflated by this value. The default value is zero.
    open var textPadding: UIEdgeInsets = .zero {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsUpdatePlaceholderConstraints()
        }
    }
    
    open var textPaddingMode: RAGTextPaddingMode = .text {
        didSet {
            setNeedsLayout()
            setNeedsUpdatePlaceholderConstraints()
        }
    }
    
    /// Swaps the left and right text padding values if the current user interface direction is right-to-left.
    private var userInterfaceDirectionAwareTextPadding: UIEdgeInsets {
        
        if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
            return textPadding
        }
        
        var padding = textPadding
        swap(&padding.left, &padding.right)
        
        return padding
    }
    
    /// The `top` property of the `textPadding`.
    @IBInspectable var topTextPadding: CGFloat {
        set { textPadding.top = newValue }
        get { return textPadding.top }
    }
    
    /// The `bottom` property of the `textPadding`.
    @IBInspectable var bottomTextPadding: CGFloat {
        set { textPadding.bottom = newValue }
        get { return textPadding.bottom }
    }
    
    /// The `left` property of the `textPadding`.
    @IBInspectable var leadingTextPadding: CGFloat {
        set { textPadding.left = newValue }
        get { return textPadding.left }
    }
    
    /// The `right` property of the `textPadding`.
    @IBInspectable var trailingTextPadding: CGFloat {
        set { textPadding.right = newValue }
        get { return textPadding.right }
    }
    
    // MARK: Overlay views
    
    open override var leftView: UIView? {
        didSet {
            setNeedsUpdateHorizontalPlaceholderConstraints()
        }
    }
    
    open override var leftViewMode: UITextField.ViewMode {
        didSet {
            setNeedsUpdateHorizontalPlaceholderConstraints()
        }
    }
    
    /// Whether the left view is displayed to the left or to the right of the text.
    private var leftViewPosition: HorizontalPosition {
        
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            return .right
        } else {
            return .left
        }
    }
    
    private var isLeftViewVisible: Bool {
        
        guard leftView != nil else { return false }
        return isOverlayVisible(with: leftViewMode)
    }
    
    open override var rightView: UIView? {
        didSet {
            setNeedsUpdateHorizontalPlaceholderConstraints()
        }
    }
    
    open override var rightViewMode: UITextField.ViewMode {
        didSet {
            setNeedsUpdateHorizontalPlaceholderConstraints()
        }
    }
    
    /// Whether the left view is displayed to the left or to the right of the text.
    private var rightViewPosition: HorizontalPosition {
        
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
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
            return !isEditing || !hasText
        case .never:
            return false
        @unknown default:
            return false
        }
    }
    
    // MARK: Clear button
    
    /// Whether the clear button is displayed to the left or to the right of the text.
    private var clearButtonPosition: HorizontalPosition {
        
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
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
        @unknown default:
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
        
        borderStyle = .none
        
        addSubview(hintLabel)
        setupHintLabel()
        
        addSubview(placeholderContainerView)
        setupPlaceholderContainerView()
        
        placeholderContainerView.addSubview(placeholderView)
        setupPlaceholderView()
        
        // Listen for text changes on self
        let action = #selector(textDidChange)
        NotificationCenter.default.addObserver(self, selector: action, name: UITextField.textDidChangeNotification, object: self)
    }
    
    @objc private func textDidChange() {
        updatePlaceholderTransform(animated: true)
        updatePlaceholderColor()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        // Copy the placeholder from the super class and set it nil
        if let superPlaceholder = super.placeholder {
            // Use the super placeholder only if the placeholder label has no text yet
            if placeholderLabel.text == nil {
                placeholder = superPlaceholder
            }
            
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
        
        guard let font = font ?? self.font else { return 0.0 }
        let boundingSize = text.size(using: font)
        
        return boundingSize.height
    }
    
    // MARK: - Hint
    
    /// Sets initial properties and constraints of the hint label.
    private func setupHintLabel() {
        
        hint = nil
        hintLabel.font = font
        hintLabel.textAlignment = textAlignment
        hintLabel.lineBreakMode = .byWordWrapping
        hintLabel.numberOfLines = 0
    }
    
    private func updateHintVisibility() {
        
        if layoutAlwaysIncludesHint || hint != nil {
            hintLabel.isHidden = false
        } else {
            hintLabel.isHidden = true
        }
    }
    
    private func hintFrame(forBounds bounds: CGRect) -> CGRect {
        
        let w = bounds.width - textPadding.left - textPadding.right
        let h = measureHintSize(availableWidth: w).height
        let x = userInterfaceDirectionAwareTextPadding.left
        
        var y = bounds.height - h
        if [.textAndHint, .textAndPlaceholderAndHint].contains(textPaddingMode) {
            y -= textPadding.bottom
        }
        
        let frame = CGRect(x: x, y: y, width: w, height: h)
        
        return frame
    }
    
    private func measureHintSize(availableWidth: CGFloat? = nil) -> CGSize {
        
        guard let font = hintLabel.font else { return .zero }
        
        let availableWidth = availableWidth ?? bounds.width - textPadding.left - textPadding.right
        let size = (hint ?? "").size(using: font, availableWidth: availableWidth)
        
        return size
    }
    
    // MARK: - Placeholder
    
    private func setupPlaceholderView() {
        
        placeholderLabel.font = font
        
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.textAlignment = textAlignment
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
        case .scalesAlways:
            result = true
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
        case .scalesAlways:
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
        let x = userInterfaceDirectionAwareTextPadding.left
        let y = computeTopInsetToText() + 0.5 * (measureTextHeight() - size.height)
        let rect = CGRect(origin: CGPoint(x: x, y: y), size: size)
        
        return rect
    }
    
    open override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        
        let superValue = super.rightViewRect(forBounds: bounds)
        let size = superValue.size
        let x = bounds.width - userInterfaceDirectionAwareTextPadding.right - size.width
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
        let inset = ceil(scaledPlaceholderHeight() + placeholderOffset + textPadding.top)
        
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
            inset = userInterfaceDirectionAwareTextPadding.left
        }
        
        return inset
    }
    
    private func computeBottomInsetToText() -> CGFloat {
        
        let inset = textPadding.bottom + (hintLabel.isHidden ? 0.0 : measureHintSize().height + hintOffset)
        
        return ceil(inset)
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
            inset = userInterfaceDirectionAwareTextPadding.right
        }
        
        return inset
    }
    
    open override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        
        let superValue = super.clearButtonRect(forBounds: bounds)
        let size = superValue.size
        let y = computeTopInsetToText() + 0.5 * (measureTextHeight() - size.height)
        
        let x: CGFloat
        if clearButtonPosition == .left {
            x = userInterfaceDirectionAwareTextPadding.left
        } else {
            x = bounds.width - size.width - userInterfaceDirectionAwareTextPadding.right
        }
        
        let clearButtonRect = CGRect(x: x, y: y, width: size.width, height: size.height)
        
        return clearButtonRect
    }
    
    // MARK: - UIResponder
    
    open override func becomeFirstResponder() -> Bool {
        defer {
            updatePlaceholderTransform(animated: true)
            updatePlaceholderColor()
        }
        
        return super.becomeFirstResponder()
    }
    
    open override func resignFirstResponder() -> Bool {
        defer {
            updatePlaceholderTransform(animated: true)
            updatePlaceholderColor()
        }
        
        return super.resignFirstResponder()
    }
    
    // MARK: - Animations
    
    private func updatePlaceholderTransform(animated: Bool = false) {
        
        var updated = false
        let duration = placeholderAnimationDuration ?? Constants.defaultPlaceholderAnimationDuration
        
        switch (shouldDisplayScaledPlaceholder(), isPlaceholderTransformedToScaledPosition) {
        case (true, false):
            placeholderView.scaleLabel(to: placeholderScaleWhenEditing, animated: animated, duration: duration)
            isPlaceholderTransformedToScaledPosition = true
            updated = true
        case (false, true):
            placeholderView.scaleLabel(to: 1.0, animated: animated, duration: duration)
            isPlaceholderTransformedToScaledPosition = false
            updated = true
        default:
            break
        }
        
        if updated {
            if animated {
                animatePlaceholder(scaled: isPlaceholderTransformedToScaledPosition, duration: duration)
            } else {
                updatePlaceholderConstraints(scaled: isPlaceholderTransformedToScaledPosition)
            }
        }
        
        // Update the general visibility of the placeholder
        if shouldDisplayPlaceholder() != !placeholderView.isHidden {
            placeholderView.isHidden.toggle()
        }
    }
    
    private func updatePlaceholderColor() {
        
        let color: UIColor?
        if isFirstResponder && isPlaceholderTransformedToScaledPosition {
            color = transformedPlaceholderColor ?? placeholderColor ?? textColor
        } else {
            color = placeholderColor ?? textColor
        }
        
        if color != placeholderLabel.textColor {
            placeholderLabel.textColor = color
        }
    }
    
    private func animatePlaceholder(scaled: Bool, duration: TimeInterval) {
        
        UIView.animate(withDuration: duration) { [unowned self] in
            self.updatePlaceholderConstraints(scaled: scaled)
            self.placeholderContainerView.layoutIfNeeded()
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
        } else if needsUpdateOfHorizontalPlaceholderConstraints {
            placeholderConstraints.normalX?.constant = normalHorizontalPlaceholderConstraintConstant(for: textAlignment)
            placeholderConstraints.normalX?.isActive = !isPlaceholderTransformedToScaledPosition
        }
        
        if placeholderConstraints.normalY == nil {
            placeholderConstraints.normalY = makeNormalVerticalPlaceholderConstraint()
            placeholderConstraints.normalY?.isActive = !isPlaceholderTransformedToScaledPosition
        } else if needsUpdateOfVerticalPlaceholderConstraints {
            placeholderConstraints.normalY?.constant = normalVerticalPlaceholderConstraintConstant()
            placeholderConstraints.normalY?.isActive = !isPlaceholderTransformedToScaledPosition
        }
        
        if placeholderConstraints.scaledX == nil {
            placeholderConstraints.scaledX = makeScaledHorizontalPlaceholderConstraint(textAlignment: textAlignment)
            placeholderConstraints.scaledX?.isActive = isPlaceholderTransformedToScaledPosition
        } else if needsUpdateOfHorizontalPlaceholderConstraints {
            placeholderConstraints.scaledX?.constant = scaledHorizontalPlaceholderConstraintConstant(for: textAlignment)
            placeholderConstraints.scaledX?.isActive = isPlaceholderTransformedToScaledPosition
        }
        
        if placeholderConstraints.scaledY == nil {
            placeholderConstraints.scaledY = makeScaledVerticalPlaceholderConstraint()
            placeholderConstraints.scaledY?.isActive = isPlaceholderTransformedToScaledPosition
        } else if needsUpdateOfVerticalPlaceholderConstraints {
            placeholderConstraints.scaledY?.constant = scaledVerticalPlaceholderConstraintConstant()
            placeholderConstraints.scaledY?.isActive = isPlaceholderTransformedToScaledPosition
        }
        
        needsUpdateOfHorizontalPlaceholderConstraints = false
        needsUpdateOfVerticalPlaceholderConstraints = false
        
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
        
        let height = ceil(computeTopInsetToText() + measureTextHeight() + computeBottomInsetToText())
        let size = CGSize(width: intrinsicWidth(), height: height)
        
        return size
    }
    
    private func intrinsicWidth() -> CGFloat {
        
        let textWidth = (text ?? "").size(using: font!).width
        let placeholderWidth = (placeholder ?? "").size(using: placeholderLabel.font).width
        let width = computeLeftInsetToText() + max(textWidth, placeholderWidth) + computeRightInsetToText()
        
        return ceil(width)
    }
    
    // MARK: - Constraints
    
    private func makeNormalHorizontalPlaceholderConstraint(textAlignment: NSTextAlignment) -> NSLayoutConstraint {
        
        let constraint: NSLayoutConstraint
        
        switch (textAlignment, UIApplication.shared.userInterfaceLayoutDirection) {
        case (.left, .leftToRight), (.right, .rightToLeft), (.justified, _), (.natural, _):
            constraint = placeholderView.leadingAnchor.constraint(equalTo: placeholderContainerView.leadingAnchor)
        case (.left, .rightToLeft), (.right, .leftToRight):
            constraint = placeholderContainerView.trailingAnchor.constraint(equalTo: placeholderView.trailingAnchor)
        case (.center, _):
            constraint = placeholderView.centerXAnchor.constraint(equalTo: placeholderContainerView.centerXAnchor)
        @unknown default:
            // Use left-to-right constraint
            constraint = placeholderView.leadingAnchor.constraint(equalTo: placeholderContainerView.leadingAnchor)
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
        @unknown default:
            // Use left-to-right value
            return computeLeftInsetToText()
        }
    }
    
    private func normalVerticalPlaceholderConstraintConstant() -> CGFloat {
        
        return computeTopInsetToText() + 0.5 * measureTextHeight()
    }
    
    private func makeScaledHorizontalPlaceholderConstraint(textAlignment: NSTextAlignment) -> NSLayoutConstraint {
        
        let constraint: NSLayoutConstraint
        
        switch (textAlignment, UIApplication.shared.userInterfaceLayoutDirection) {
        case (.left, .leftToRight), (.right, .rightToLeft), (.justified, _), (.natural, _):
            constraint = placeholderView.leadingAnchor.constraint(equalTo: placeholderContainerView.leadingAnchor)
        case (.left, .rightToLeft), (.right, .leftToRight):
            constraint = placeholderContainerView.trailingAnchor.constraint(equalTo: placeholderView.trailingAnchor)
        case (.center, _):
            constraint = placeholderView.centerXAnchor.constraint(equalTo: placeholderContainerView.centerXAnchor)
        @unknown default:
            // Use left-to-right constraint
            constraint = placeholderView.leadingAnchor.constraint(equalTo: placeholderContainerView.leadingAnchor)
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
        
        return (textAlignment == .center) ? 0.0 : textPadding.left
    }
    
    private func scaledVerticalPlaceholderConstraintConstant() -> CGFloat {
        
        let additionalTopInset = [.textAndPlaceholder, .textAndPlaceholderAndHint].contains(textPaddingMode) ? textPadding.top : 0.0
        let scaledHeight = placeholderScaleWhenEditing * measureTextHeight(using: placeholderLabel.font)
        return computeTopInsetToText() - textPadding.top - scaledPlaceholderOffset - 0.5 * scaledHeight + additionalTopInset
    }
}
