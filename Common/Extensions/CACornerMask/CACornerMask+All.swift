//
//  CACornerMask+All.swift
//

import UIKit

extension CACornerMask {
    public static var all: Self {
        [
            .layerMinXMinYCorner,
            .layerMinXMaxYCorner,
            .layerMaxXMinYCorner,
            .layerMaxXMaxYCorner
        ]
    }
}
