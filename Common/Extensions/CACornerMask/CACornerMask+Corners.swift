//
//  CACornerMask+Corners.swift
//

import UIKit

extension CACornerMask {
    
    /// Top-left corner mask.
    public static var topLeft: CACornerMask { .layerMinXMinYCorner }
    
    /// Top-right corner mask.
    public static var topRight: CACornerMask { .layerMaxXMinYCorner }
    
    /// Bottom-left corner mask.
    public static var bottomLeft: CACornerMask { .layerMinXMaxYCorner }
    
    /// Bottom-right corner mask.
    public static var bottomRight: CACornerMask { .layerMaxXMaxYCorner }
}
