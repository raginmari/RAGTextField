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
    
    /// The duration of the placeholder animation if no duration is set by the
    /// user.
    static let defaultPlaceholderAnimationDuration = CFTimeInterval(0.2)
}

/// The different modes of the placeholder
public enum RAGTextFieldPlaceholderMode {
    
    /// The default behavior of `UITextField`
    case simple
    
    /// The placeholder scales when it is not empty and when the text field is being edited
    case scalesWhenEditing
    
    /// The placeholder scales when it is not empty
    case scalesWhenNotEmpty
    
    var scalesPlaceholder: Bool {
        switch self {
        case .scalesWhenEditing:
            return true
        case .scalesWhenNotEmpty:
            return true
        case .simple:
            return false
        }
    }
}

open class RAGTextField: UITextField {
    
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
            
            setNeedsUpdateConstraints()
        }
    }
    
    /// The text alignment of the text field.
    ///
    /// The given value is applied to the hint and the placeholder as well.
    open override var textAlignment: NSTextAlignment {
        didSet {
            hintLabel.textAlignment = textAlignment
            placeholderLabel.textAlignment = textAlignment
            
            needsUpdateOfPlaceholderTransformAfterLayout = true
            setNeedsLayout()
        }
    }
    
    /// The text value of the text field. Updates the position of the placeholder.
    open override var text: String? {
        didSet {
            updatePlaceholderTransform()
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
            
            needsUpdateOfPlaceholderTransformAfterLayout = true
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
    
    private let placeholderLabel = UILabel()
    
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
            if placeholderScaleWhenEditing < 0.0 {
                placeholderScaleWhenEditing = 0.0
            }
            
            needsUpdateOfPlaceholderTransformAfterLayout = true
            invalidateIntrinsicContentSize()
        }
    }
    
    /// The vertical offset of the scaled placeholder from the top of the text.
    ///
    /// Can be used to put a little distance between the placeholder and the text.
    @IBInspectable open var scaledPlaceholderOffset: CGFloat = 0.0 {
        didSet {
            needsUpdateOfPlaceholderTransformAfterLayout = true
            invalidateIntrinsicContentSize()
        }
    }
    
    /// Controls how the placeholder is being displayed, whether it is scaled
    /// and whether the scaled placeholder is taken into consideration when the
    /// view is layed out.
    ///
    /// The default value is `.scalesWhenNotEmpty`.
    open var placeholderMode: RAGTextFieldPlaceholderMode = .scalesWhenNotEmpty {
        didSet {
            needsUpdateOfPlaceholderTransformAfterLayout = true
            invalidateIntrinsicContentSize()
        }
    }
    
    /// The computed height of the untransformed placeholder in points.
    private var placeholderHeight: CGFloat {
        
        return measureTextHeight(using: placeholderLabel.font)
    }
    
    private var placeholderConstraints = [NSLayoutConstraint]()
    
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
    
    /// Whether the placeholder transform should be set after the next
    /// `layoutSubviews`.
    ///
    /// Does not trigger `layoutSubviews`.
    private var needsUpdateOfPlaceholderTransformAfterLayout = true
    
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
    
    /// Whether the text background view contains the clear button or not.
    ///
    /// Depending on the kind of text background view, the clear button should be
    /// displayed inside of or outside of the text background. The default value is `true`.
    ///
    /// - Note
    /// If the `textBackgroundView` is `nil`, this property has no effect.
    open var textBackgroundViewContainsClearButton = true {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// Represents a horizontal position. Either left or right.
    private enum HorizontalPosition {
        case left, right
    }
    
    /// Whether the clear button is displayed to the left or to the right of the text.
    private var clearButtonPosition: HorizontalPosition {
        
        if textAlignment == .natural && UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            return .left
        } else {
            return .right
        }
    }
    
    /// Computes the frame of the text background view.
    ///
    /// If `textBackgroundViewContainsClearButton` is `true`, the clear button will be included in the frame.
    ///
    /// - Returns: The frame
    private func computeTextBackgroundViewFrame() -> CGRect {
        
        let insetX = -horizontalTextPadding
        let insetY = -verticalTextPadding
        let textRect = textAndEditingRect(forBounds: bounds)
        let frame: CGRect
        
        if textBackgroundViewContainsClearButton {
            let clearButtonRect = self.clearButtonRect(forBounds: bounds)
            frame = textRect.union(clearButtonRect).insetBy(dx: insetX, dy: insetY)
        } else {
            frame = textRect.insetBy(dx: insetX, dy: insetY)
        }
        
        return frame
    }
    
    /// The padding applied to the left and right of the text rectangle. Can be
    /// used to reserve more space for the `textBackgroundView`.
    @IBInspectable open var horizontalTextPadding: CGFloat = 0.0 {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    /// The padding applied to the top and bottom of the text rectangle. Can be
    /// used to reserve more space for the `textBackgroundView`.
    @IBInspectable open var verticalTextPadding: CGFloat = 0.0 {
        didSet {
            setNeedsUpdateConstraints()
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
        
        addSubview(placeholderLabel)
        setupPlaceholderLabel()
        
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
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
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
    
    /// Sets initial properties and constraints of the placeholder label.
    private func setupPlaceholderLabel() {
        placeholderLabel.text = ""
        placeholderLabel.font = font
        placeholderLabel.textAlignment = textAlignment
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        placeholderConstraints = [
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ]
        
        addConstraints(placeholderConstraints)
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
        
        if clearButtonPosition == .left {
            return horizontalTextPadding + clearButtonRect(forBounds: bounds).maxX
        } else {
            return horizontalTextPadding
        }
    }
    
    private func computeBottomInsetToText() -> CGFloat {
        
        let inset = ceil(hintHeight + verticalTextPadding)
        
        return inset
    }
    
    private func computeRightInsetToText() -> CGFloat {
        
        if clearButtonPosition == .left {
            return horizontalTextPadding
        } else {
            return horizontalTextPadding + bounds.width - clearButtonRect(forBounds: bounds).minX
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
    
    private func animatePlaceholderToScaledPosition() {
        let transform = placeholderTransformForScaledPosition()
        animatePlaceholderTransform(to: transform)
    }
    
    private func animatePlaceholderToBasePosition() {
        let transform = placeholderTransformForBasePosition()
        animatePlaceholderTransform(to: transform)
    }
    
    private func animatePlaceholderTransform(to transform: CATransform3D) {
        placeholderLabel.layer.removeAllAnimations()
        
        let animation = CABasicAnimation(keyPath: "transform")
        let duration = placeholderAnimationDuration ?? Constants.defaultPlaceholderAnimationDuration
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        let fromValue = placeholderLabel.layer.presentation()?.transform ?? placeholderLabel.layer.transform
        animation.fromValue = fromValue
        animation.toValue = transform
        placeholderLabel.layer.add(animation, forKey: "scale")
        
        // Update the transform of the model layer
        placeholderLabel.layer.transform = transform
    }
    
    private func updatePlaceholderTransform(animated: Bool = false) {
        // Make sure the layout is up to date
        layoutIfNeeded()
        
        guard animatesPlaceholder else {
            let transform = expectedPlaceholderTransform()
            placeholderLabel.layer.transform = transform
            
            return
        }
        
        switch (animated, shouldDisplayScaledPlaceholder(), isPlaceholderTransformedToScaledPosition) {
        case (true, true, false):
            animatePlaceholderToScaledPosition()
            isPlaceholderTransformedToScaledPosition = true
        case (true, false, true):
            animatePlaceholderToBasePosition()
            isPlaceholderTransformedToScaledPosition = false
        default:
            let transform = expectedPlaceholderTransform()
            placeholderLabel.layer.transform = transform
        }
        
        // Update the general visibility of the placeholder
        placeholderLabel.isHidden = !shouldDisplayPlaceholder()
    }
    
    /// Returns the transform that should be applied to the placeholder.
    ///
    /// - Returns: the transform
    private func expectedPlaceholderTransform() -> CATransform3D {
        let transform: CATransform3D
        
        if shouldDisplayScaledPlaceholder() {
            transform = placeholderTransformForScaledPosition()
        } else {
            transform = placeholderTransformForBasePosition()
        }
        
        return transform
    }
    
    /// Returns the transform to apply to the placeholder label in the scaled
    /// position.
    ///
    /// - Returns: the transform
    private func placeholderTransformForScaledPosition() -> CATransform3D {
        let tx: CGFloat
        
        // Two options to account for text alignment:
        //
        // 1) Change the anchor point of the layer
        // 2) Translate the layer horizontally
        //
        // Option 1 affects auto layout, so option 2 has been implemented.
        switch placeholderLabel.textAlignment {
        case .left:
            tx = leftAlignedPlaceholderTranslation()
        case .right:
            tx = rightAlignedPlaceholderTranslation()
        case .center:
            tx = 0
        case .justified, .natural:
            if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
                tx = leftAlignedPlaceholderTranslation()
            } else {
                tx = rightAlignedPlaceholderTranslation()
            }
        }
        
        let ty = -(0.5 + 0.5 * placeholderScaleWhenEditing) * measureTextHeight() - verticalTextPadding - scaledPlaceholderOffset
        let translation = CATransform3DMakeTranslation(ceil(tx), ceil(ty), 0)
        
        let scale = placeholderScaleWhenEditing
        let scaling = CATransform3DMakeScale(scale, scale, 1)
        
        let transform = CATransform3DConcat(scaling, translation)
        
        return transform
    }
    
    private func leftAlignedPlaceholderTranslation() -> CGFloat {
        
        return 0.5 * (1.0 - placeholderScaleWhenEditing) * placeholderLabel.bounds.width * -1.0
    }
    
    private func rightAlignedPlaceholderTranslation() -> CGFloat {
        
        return 0.5 * (1.0 - placeholderScaleWhenEditing) * placeholderLabel.bounds.width
    }
    
    private func placeholderTransformForBasePosition() -> CATransform3D {
        return CATransform3DIdentity
    }
    
    // MARK: - UIView
    
    open override func updateConstraints() {
        
        updatePlaceholderConstraints()
        
        super.updateConstraints()
    }
    
    private func updatePlaceholderConstraints() {
        let topConstant = computeTopInsetToText()
        updatePlaceholderConstraint(.top, to: topConstant)
        
        let leadingConstant = horizontalTextPadding
        updatePlaceholderConstraint(.leading, to: leadingConstant)
        
        let trailingConstant = -leadingConstant
        updatePlaceholderConstraint(.trailing, to: trailingConstant)
    }
    
    private func updatePlaceholderConstraint(_ attribute: NSLayoutConstraint.Attribute, to constant: CGFloat) {
        updateConstraint(attribute, in: placeholderConstraints, to: constant)
    }
    
    private func updateConstraint(_ attribute: NSLayoutConstraint.Attribute, in constraints: [NSLayoutConstraint], to constant: CGFloat) {
        for constraint in constraints where constraint.firstAttribute == attribute {
            constraint.constant = constant
            break
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if needsUpdateOfPlaceholderTransformAfterLayout {
            updatePlaceholderTransform()
            needsUpdateOfPlaceholderTransformAfterLayout = false
        }
        
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
}

private extension String {
    
    func size(using font: UIFont) -> CGSize {
        let infinite = CGFloat.greatestFiniteMagnitude
        let infiniteSize = CGSize(width: infinite, height: infinite)
        let boundingRect = self.boundingRect(with: infiniteSize, options: [], attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]), context: nil)
        
        return boundingRect.size
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
