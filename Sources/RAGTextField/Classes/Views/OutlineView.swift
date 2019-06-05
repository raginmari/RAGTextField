//
// Copyright (c) 2019 Reimar Twelker
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

/// Draws an outline along its bounds.
///
/// The outline can be inset and its corners can be rounded. The inside of the outline can be filled.
open class OutlineView: UIView {
    
    /// Uses a shape layer instead of the default one.
    override open class var layerClass : AnyClass {
        
        return CAShapeLayer.self
    }
    
    /// Convenience method force casts the layer to `CAShapeLayer`.
    private var shapeLayer: CAShapeLayer {
        
        return layer as! CAShapeLayer
    }
    
    /// The padding around the outline.
    open var outlineInsets: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// The width of the outline in points.
    @IBInspectable open var lineWidth: CGFloat = 1.0 {
        didSet {
            shapeLayer.lineWidth = lineWidth
        }
    }
    
    /// The color of the outline.
    @IBInspectable open var lineColor: UIColor? = .black {
        didSet {
            shapeLayer.strokeColor = lineColor?.cgColor
        }
    }
    
    /// The color of the inside of the outline.
    @IBInspectable open var fillColor: UIColor? = .clear {
        didSet {
            shapeLayer.fillColor = fillColor?.cgColor
        }
    }
    
    /// The corner radius of the outline.
    @IBInspectable open var cornerRadius: CGFloat = 0.0 {
        didSet {
            shapeLayer.cornerRadius = cornerRadius
            setNeedsLayout()
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
        
        backgroundColor = .clear
        shapeLayer.fillColor = nil
    }
    
    open override func layoutSubviews() {
        
        super.layoutSubviews()
        
        shapeLayer.path = makePath().cgPath
    }
    
    /// Creates the path of the outline.
    ///
    /// - Returns: The new path.
    private func makePath() -> UIBezierPath {
        
        let rect: CGRect
        if outlineInsets != .zero {
            rect = bounds.inset(by: outlineInsets)
        } else {
            rect = bounds
        }
        
        let path: UIBezierPath
        if cornerRadius != 0.0 {
            path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        } else {
            path = UIBezierPath(rect: rect)
        }
        
        return path
    }
}
