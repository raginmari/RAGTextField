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

final class UnderlineView: UIView {
    
    enum Mode {
        
        case expandsFromCenter
        
        case expandsFromRight
        
        case expandsFromLeft
        
        case expandsInUserInterfaceDirection
        
        case notAnimated
    }
    
    @IBInspectable var lineWidth: CGFloat = 1.0 {
        didSet {
            heightConstraint?.constant = lineWidth
        }
    }
    
    @IBInspectable var normalLineColor: UIColor = .clear {
        didSet {
            underlineBackgroundView.backgroundColor = normalLineColor
        }
    }
    
    @IBInspectable var expandedLineColor: UIColor = .black {
        didSet {
            underlineView.backgroundColor = expandedLineColor
        }
    }
    
    var expandMode: Mode = .expandsFromCenter {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    var expandDuration: TimeInterval = 0.2
    
    private let underlineView = UIView()
    private let underlineBackgroundView = UIView()
    
    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?
    private var widthConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?
    
    private var isExpanded = false
    
    override var tintColor: UIColor! {
        didSet {
            expandedLineColor = tintColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        addSubview(underlineBackgroundView)
        addSubview(underlineView)
        setUpUnderlineBackground()
        setUpUnderline()
    }
    
    private func setUpUnderlineBackground() {
        
        underlineBackgroundView.backgroundColor = normalLineColor
        underlineBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["v": underlineBackgroundView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v]|", options: [], metrics: nil, views: views))
        
        // Cling to the bottom of the view
        underlineBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        // Always be as high as the underline
        underlineBackgroundView.heightAnchor.constraint(equalTo: underlineView.heightAnchor).isActive = true
    }
    
    private func setUpUnderline() {
        
        underlineView.backgroundColor = expandedLineColor
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
    
    override func updateConstraints() {
        
        switch expandMode {
        case .expandsFromCenter:
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
        case .notAnimated:
            leadingConstraint?.isActive = true
            trailingConstraint?.isActive = true
        }
        
        super.updateConstraints()
    }
    
    func setExpanded(_ expanded: Bool, animated: Bool) {
        
        guard expanded != isExpanded else {
            return
        }
        
        widthConstraint?.isActive = expanded
        
        if animated {
            UIView.animate(withDuration: expandDuration) { [unowned self] in
                self.layoutIfNeeded()
            }
        }
        
        isExpanded = expanded
    }
}
