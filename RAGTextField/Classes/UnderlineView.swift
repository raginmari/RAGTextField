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

/// Draws two colored lines at the bottom on top of one another that extend from the left to the right edge.
///
/// The foreground line is initially not visible. It can be expanded to fully cover the background line.
/// The expansion can be animated in different ways.
///
/// - Note
/// The view is meant to be used with `RAGTextField`. Set it as the `textBackgroundView` to approximate the look and feel of a
/// Material text field. The expansion of the line has to be controlled manually, for example from the text field delegate.
open class UnderlineView: UIView {

    /// The different ways in which the expanding line is animated.
    public enum Mode {
        
        /// The line equally expands from the center of the view to its left and right edges.
        case expandsFromCenter
        
        /// The line expands from the right edge of the view to the left.
        case expandsFromRight
        
        /// The line expands from the left edge of the view to the right.
        case expandsFromLeft
        
        /// The line expands from the leading edge of the view to the trailing one.
        case expandsInUserInterfaceDirection
        
        /// The line is not animated.
        case notAnimated
    }
    
    /// The width of both lines in points.
    @IBInspectable open var lineWidth: CGFloat = 1.0 {
        didSet {
            heightConstraint?.constant = lineWidth
        }
    }
    
    /// The color of the background line.
    @IBInspectable open var backgroundLineColor: UIColor = .clear {
        didSet {
            underlineBackgroundView.backgroundColor = backgroundLineColor
        }
    }
    
    /// The color of the foreground line.
    @IBInspectable open var foregroundLineColor: UIColor = .black {
        didSet {
            underlineView.backgroundColor = foregroundLineColor
        }
    }
    
    /// The way the foreground line is expanded.
    open var expandMode: Mode = .expandsFromCenter {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    /// The duration of the animation of the foreground line.
    open var expandDuration: TimeInterval = 0.2
    
    private let underlineView = UIView()
    private let underlineBackgroundView = UIView()
    
    /// Used to pin the foreground line to the leading edge of the view.
    ///
    /// Enabled and disabled depending on the `expandMode` value.
    private var leadingConstraint: NSLayoutConstraint?
    
    /// Used to pin the foreground line to the trailing edge of the view.
    ///
    /// Enabled and disabled depending on the `expandMode` value.
    private var trailingConstraint: NSLayoutConstraint?
    
    /// Used to animate the foreground line.
    private var widthConstraint: NSLayoutConstraint?
    
    /// Updated when `lineWidth` is changed.
    private var heightConstraint: NSLayoutConstraint?
    
    /// If `true`, the foreground line is currently expanded.
    private var isExpanded = false
    
    /// The tint color of the `UIView` overwrites the current `expandedLineColor`.
    open override var tintColor: UIColor! {
        didSet {
            foregroundLineColor = tintColor
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        addSubview(underlineBackgroundView)
        addSubview(underlineView)
        setUpUnderlineBackground()
        setUpUnderline()
    }
    
    /// Sets up the underline background view. Sets properties and configures constraints.
    private func setUpUnderlineBackground() {
        
        underlineBackgroundView.backgroundColor = backgroundLineColor
        underlineBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["v": underlineBackgroundView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v]|", options: [], metrics: nil, views: views))
        
        // Cling to the bottom of the view
        underlineBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        // Always be as high as the underline
        underlineBackgroundView.heightAnchor.constraint(equalTo: underlineView.heightAnchor).isActive = true
    }
    
    /// Sets up the underline view. Sets properties and configures constraints.
    private func setUpUnderline() {
        
        underlineView.backgroundColor = foregroundLineColor
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        
        // Cling to the bottom of the view
        underlineView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        heightConstraint = underlineView.heightAnchor.constraint(equalToConstant: lineWidth)
        heightConstraint?.isActive = true
        
        // (De)activating the higher priority width constraint animates the underline
        widthConstraint = underlineView.widthAnchor.constraint(equalTo: widthAnchor)
        widthConstraint?.priority = .defaultHigh
        
        let zeroWidthConstraint = underlineView.widthAnchor.constraint(equalToConstant: 0.0)
        zeroWidthConstraint.priority = .defaultHigh - 1
        zeroWidthConstraint.isActive = true
        
        leadingConstraint = underlineView.leadingAnchor.constraint(equalTo: leadingAnchor)
        // Do not activate just yet
        
        trailingConstraint = underlineView.trailingAnchor.constraint(equalTo: trailingAnchor)
        // Do not activate just yet
        
        // Center with low priority
        let centerConstraint = underlineView.centerXAnchor.constraint(equalTo: centerXAnchor)
        centerConstraint.priority = .defaultLow
        centerConstraint.isActive = true
        
        setNeedsUpdateConstraints()
    }
    
    open override func updateConstraints() {
        
        // Enable the leading and trailing constraints depending on the `expandMode`.
        switch expandMode {
        case .expandsFromCenter, .notAnimated:
            leadingConstraint?.isActive = false
            trailingConstraint?.isActive = false
        case .expandsFromRight where UIApplication.shared.userInterfaceLayoutDirection == .leftToRight:
            leadingConstraint?.isActive = false
            trailingConstraint?.isActive = true
        case .expandsFromRight:
            leadingConstraint?.isActive = true
            trailingConstraint?.isActive = false
        case .expandsFromLeft where UIApplication.shared.userInterfaceLayoutDirection == .leftToRight:
            leadingConstraint?.isActive = true
            trailingConstraint?.isActive = false
        case .expandsFromLeft:
            leadingConstraint?.isActive = false
            trailingConstraint?.isActive = true
        case .expandsInUserInterfaceDirection:
            leadingConstraint?.isActive = true
            trailingConstraint?.isActive = false
        }
        
        super.updateConstraints()
    }
    
    /// Sets the foreground line to its expanded or contracted state depending on the given parameter. Optionally, the change is animated.
    ///
    /// - Parameters:
    ///   - expanded: If `true`, the line is expanded.
    ///   - animated: If `true`, the change is animated.
    open func setExpanded(_ expanded: Bool, animated: Bool) {
        
        guard expanded != isExpanded else {
            return
        }
        
        widthConstraint?.isActive = expanded
        
        if animated && expandMode != .notAnimated {
            UIView.animate(withDuration: expandDuration) { [unowned self] in
                self.layoutIfNeeded()
            }
        }
        
        isExpanded = expanded
    }
}
