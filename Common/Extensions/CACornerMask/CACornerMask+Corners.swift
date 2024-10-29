//
//  CACornerMask+Corners.swift
//

import UIKit

extension CACornerMask {
    public static var topLeft: CACornerMask { .layerMinXMinYCorner }
    public static var topRight: CACornerMask { .layerMaxXMinYCorner }
    public static var bottomLeft: CACornerMask { .layerMinXMaxYCorner }
    public static var bottomRight: CACornerMask { .layerMaxXMaxYCorner }
}
