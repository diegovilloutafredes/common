//
//  CACornerMask+All.swift
//

import UIKit

extension CACornerMask {
    
    /// Returns a mask containing all four corners.
    public static var all: Self {
        [
            .layerMinXMinYCorner,
            .layerMinXMaxYCorner,
            .layerMaxXMinYCorner,
            .layerMaxXMaxYCorner
        ]
    }
}
