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
                hintLabel.font = hintFont ?? font
            }
            
            if placeholderFont == nil {
                placeholderLabel.font = font
            }
            
            setNeedsUpdateConstraints()
        }
    }
    
    /// The text alignment of the text field. The given value is applied to
    /// the hint and the placeholder as well.
    open override var textAlignment: NSTextAlignment {
        didSet {
            hintLabel.textAlignment = textAlignment
            placeholderLabel.textAlignment = textAlignment
            updatePlaceholderTransform()
        }
    }
    
    /// The text value of the text field. Updates the position of the
    /// placeholder.
    open override var text: String? {
        didSet {
            updatePlaceholderTransform()
        }
    }
    
    /// A copy of the most recently computed editing rect. Used to avoid
    /// infinite loops in `clearButtonRect(forBounds:)`.
    private var cachedTextRect = CGRect.zero
    
    // MARK: Hint
    
    private let hintLabel = UILabel()
    
    /// The text value of the hint. If `nil`, the hint label is removed
    /// from the layout. Otherwise, the hint label is considered in the layout.
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
    
    /// The font used for the hint. If `nil`, the font of the text field is used
    /// instead.
    open var hintFont: UIFont? {
        set {
            if newValue == nil {
                hintLabel.font = font
            } else {
                hintLabel.font = newValue
            }
        }
        get {
            return hintLabel.font
        }
    }
    
    /// The text color of the hint. If `nil`, the text color of the text field
    /// is used instead.
    @IBInspectable open var hintColor: UIColor? {
        set {
            if newValue == nil {
                hintLabel.textColor = textColor
            } else {
                hintLabel.textColor = newValue
            }
        }
        get {
            return hintLabel.textColor
        }
    }
    
    private var hintHeight: CGFloat {
        if hintLabel.isHidden {
            return 0
        }
        
        return measureHeight(of: Constants.textSizeMeasurementString, using: hintLabel.font)
    }
    
    private var hintConstraints = [NSLayoutConstraint]()
    
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
    
    /// The font used for the placeholder. If `nil`, the font of the text field
    /// is used instead.
    open var placeholderFont: UIFont? {
        set {
            if newValue == nil {
                placeholderLabel.font = font
            } else {
                placeholderLabel.font = newValue
            }
        }
        get {
            return placeholderLabel.font
        }
    }
    
    /// The text color of the placeholder. If `nil`, the text color of the text
    /// field is used instead.
    @IBInspectable open var placeholderColor: UIColor? {
        set {
            if newValue == nil {
                placeholderLabel.textColor = textColor
            } else {
                placeholderLabel.textColor = newValue
            }
        }
        get {
            return placeholderLabel.textColor
        }
    }
    
    /// The scale applied to the placeholder when it is moved to the scaled
    /// position. Must be in `[0,1]`.
    @IBInspectable open var placeholderScaleWhenEditing: CGFloat = 1.0 {
        didSet {
            // Clamp value to [0,1]
            switch placeholderScaleWhenEditing {
            case let val where val < 0.0:
                placeholderScaleWhenEditing = 0.0
            case let val where val > 1.0:
                placeholderScaleWhenEditing = 1.0
            default:
                break
            }
            
            needsUpdateOfPlaceholderTransformAfterLayout = true
            invalidateIntrinsicContentSize()
        }
    }
    
    /// The offset of the scaled placeholder from the top of the (possibly
    /// expanded) text rectangle. Can be used to put a little distance between
    /// the placeholder and the text.
    @IBInspectable open var scaledPlaceholderOffset: CGFloat = 0.0 {
        didSet {
            needsUpdateOfPlaceholderTransformAfterLayout = true
            invalidateIntrinsicContentSize()
        }
    }
    
    /// Controls how the placeholder is being displayed, whether it is scaled
    /// and whether the scaled placeholder is taken into consideration when the
    /// view is layed out. The default is `.scalesWhenNotEmpty`.
    open var placeholderMode: RAGTextFieldPlaceholderMode = .scalesWhenNotEmpty {
        didSet {
            needsUpdateOfPlaceholderTransformAfterLayout = true
            invalidateIntrinsicContentSize()
        }
    }
    
    private var placeholderHeight: CGFloat {
        return measureHeight(of: Constants.textSizeMeasurementString, using: placeholderLabel.font)
    }
    
    private var placeholderConstraints = [NSLayoutConstraint]()
    
    /// The duration of the animation transforming the placeholder to and from
    /// the scaled position. If `nil`, a default duration is used. Set to 0 to
    /// disable the animation.
    open var placeholderAnimationDuration: CFTimeInterval? = nil
    
    private var animatesPlaceholder: Bool {
        let duration = placeholderAnimationDuration ?? Constants.defaultPlaceholderAnimationDuration
        let result = duration > CFTimeInterval(0)
        
        return result
    }
    
    /// Whether the placeholder transform should be set after the next
    /// `layoutSubviews`. Does not trigger `layoutSubviews`.
    private var needsUpdateOfPlaceholderTransformAfterLayout = true
    
    /// Keeps track of whether the placeholder is currently in the scaled
    /// position. Used to prevent unnecessary animations or updates of the
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
            view.frame = textBackgroundViewFrame
            
            addSubview(view)
            sendSubviewToBack(view)
        }
    }
    
    /// The frame of the text background view. Equals the value of
    /// `textRect(forBounds:)` expanded by the horizontal and vertical text
    /// padding.
    private var textBackgroundViewFrame: CGRect {
        let insetX = -horizontalTextPadding
        let insetY = -verticalTextPadding
        let result = textRect(forBounds: bounds).insetBy(dx: insetX, dy: insetY)
        
        return result
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
    ///   - text: the text whose height is measured
    ///   - font: the font to use
    /// - Returns: the height of the given string
    private func measureHeight(of text: String, using font: UIFont) -> CGFloat {
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
        
        addConstraint(hintLabel.bottomAnchor.constraint(equalTo: bottomAnchor))
        
        hintConstraints = [
            hintLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            hintLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ]
        
        addConstraints(hintConstraints)
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
            placeholderLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
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
    
    /// Computes the rectangle of the displayed text. Fetches the super value
    /// and applies the text padding and the hint height.
    ///
    /// - Parameter bounds: the bounds based on which the text rect should be computed
    /// - Returns: the text rect
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        let result = insettingRect(super.textRect(forBounds: bounds))
        
        return result
    }
    
    /// Computes the rectangle of the edited text. Fetches the super value and
    /// applies the text padding and the hint height.
    ///
    /// - Parameter bounds: the bounds based on which the text rect should be computed
    /// - Returns: the text rect
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let result = insettingRect(super.editingRect(forBounds: bounds))
        
        cachedTextRect = result
        
        return result
    }
    
    private func insettingRect(_ rect: CGRect) -> CGRect {
        let placeholderOffset = placeholderMode.scalesPlaceholder ? scaledPlaceholderOffset : 0.0
        let topInset = scaledPlaceholderHeight() + placeholderOffset + verticalTextPadding
        let bottomInset = hintHeight + verticalTextPadding
        let insets = UIEdgeInsets(top: topInset, left: horizontalTextPadding, bottom: bottomInset, right: horizontalTextPadding)
        let result = rect.inset(by: insets)
        
        return result
    }
    
    open override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        var superRect = super.clearButtonRect(forBounds: bounds)
        
        // Center the clear button vertically with respect to the text
        let offsetY = cachedTextRect.midY - superRect.midY
        superRect.origin.y += offsetY
        
        return superRect
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
        
        // -(1.0 - 0.5 * (1.0 - placeholderScaleWhenEditing)) * height ...
        let ty = -(0.5 + 0.5 * placeholderScaleWhenEditing) * textRect(forBounds: bounds).height - verticalTextPadding - scaledPlaceholderOffset
        let translation = CATransform3DMakeTranslation(tx, ty, 0)
        
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
    
    /// Returns the transform to apply to the placeholder label in the default
    /// position.
    ///
    /// - Returns: the transform
    private func placeholderTransformForBasePosition() -> CATransform3D {
        return CATransform3DIdentity
    }
    
    // MARK: - UIView
    
    open override func updateConstraints() {
        super.updateConstraints()
        
        updateHintConstraints()
        updatePlaceholderConstraints()
    }
    
    private func updateHintConstraints() {
        let leadingConstant = horizontalTextPadding
        updateHintConstraint(.leading, to: leadingConstant)
        
        let trailingConstant = -leadingConstant
        updateHintConstraint(.trailing, to: trailingConstant)
    }
    
    private func updateHintConstraint(_ attribute: NSLayoutConstraint.Attribute, to constant: CGFloat) {
        updateConstraint(attribute, in: hintConstraints, to: constant)
    }
    
    private func updatePlaceholderConstraints() {
        let topConstant = topInsetToText()
        updatePlaceholderConstraint(.top, to: topConstant)
        
        let bottomConstant = -bottomInsetToText()
        updatePlaceholderConstraint(.bottom, to: bottomConstant)
        
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
        textBackgroundView?.frame = textBackgroundViewFrame
    }
    
    // MARK: - Text insets
    
    /// Computes the distance from the top of the view to the top of the text
    /// rectangle.
    ///
    /// - Returns: the computed inset
    private func topInsetToText() -> CGFloat {
        let result = textRect(forBounds: bounds).minY
        
        return result
    }
    
    /// Computes the distance from the bottom of the view to the bottom of the
    /// text rectangle.
    ///
    /// - Returns: the computed inset
    private func bottomInsetToText() -> CGFloat {
        let result = bounds.height - textRect(forBounds: bounds).maxY
        
        return result
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
