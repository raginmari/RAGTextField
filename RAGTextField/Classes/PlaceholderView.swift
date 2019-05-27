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
    
    static let scaleAnimationKey = "scale"
}

/// Used to animate and transform a placeholder label using Core Animation in a view hierarchy that otherwise uses Auto Layout.
final class PlaceholderView: UIView {
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        isUserInteractionEnabled = false
    }
    
    /// The embedded label.
    ///
    /// Its layout does not use Auto Layout so that Core Animation can be used to transform the label.
    private(set) lazy var label: UILabel = {
        
        let label = UILabel()
        label.textColor = UIColor(white: 0.75, alpha: 1.0)
        addSubview(label)
        
        return label
    }()
    
    /// Updates the text alignment property of the label.
    ///
    /// - Warning
    /// Must be used instead of setting the property of the label directly.
    var textAlignment: NSTextAlignment {
        get {
            return label.textAlignment
        }
        set {
            label.textAlignment = newValue
            updateAnchorPoint(of: label, textAlignment: newValue)
        }
    }
    
    private func updateAnchorPoint(of view: UIView, textAlignment: NSTextAlignment) {
        
        switch (textAlignment, UIApplication.shared.userInterfaceLayoutDirection) {
        case (.natural, .leftToRight), (.justified, .leftToRight), (.left, _):
            view.layer.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        case (.natural, .rightToLeft), (.justified, .rightToLeft), (.right, _):
            view.layer.anchorPoint = CGPoint(x: 1.0, y: 0.5)
        case (.center, _):
            view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        @unknown default:
            // Use left-to-right value
            view.layer.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        }
        
        view.frame = bounds
    }
    
    func scaleLabel(to scale: CGFloat, animated: Bool, duration: TimeInterval) {
        
        layoutIfNeeded()
        label.layer.removeAllAnimations()
        
        let transform = CATransform3DMakeScale(scale, scale, 1.0)
        
        if animated {
            let animation = CABasicAnimation(keyPath: "transform")
            let currentTransform = label.layer.presentation()?.transform ?? label.layer.transform
            animation.fromValue = currentTransform
            animation.toValue = transform
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.duration = duration
            label.layer.add(animation, forKey: Constants.scaleAnimationKey)
        }
        
        label.layer.transform = transform
    }
    
    override var intrinsicContentSize: CGSize {
        
        let infinite = CGFloat.greatestFiniteMagnitude
        let size = label.systemLayoutSizeFitting(CGSize(width: infinite, height: infinite))
        
        return size
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        if !isAnimating() {
            label.frame = bounds
        }
    }
    
    private func isAnimating() -> Bool {
        
        return label.layer.animation(forKey: Constants.scaleAnimationKey) != nil
    }
}
