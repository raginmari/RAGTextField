import UIKit

extension UIColor {
    
    /// Creates a color from the given hex value.
    ///
    /// - parameter hex: A 6-digit hex value, e.g. 0xff0000.
    ///
    /// - returns: The color corresponding to the given hex value
    convenience init(hex: Int) {
        let r = CGFloat((hex >> 16) & 0xff) / 255.0
        let g = CGFloat((hex >>  8) & 0xff) / 255.0
        let b = CGFloat((hex >>  0) & 0xff) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
