//
//  UIView+AddFrameInfo.swift
//

import UIKit

extension UIView {
    @discardableResult public func addFrameInfo() -> Self {
        onLayoutSubviews { view in
            switch view {
            case is UIStackView:
                view.addSubview(
                    VStack {
                        [
                            UILabel("X: \(Int(view.frame.origin.x)) Y: \(Int(view.frame.origin.y))"),
                            UILabel("W: \(Int(view.frame.size.width)) H: \(Int(view.frame.size.height))")
                        ].map {
                            $0
                                .adjustsFontSizeToFitWidth()
                                .font(.boldSystemFont(ofSize: 16))
                                .textColor(.randomColor)
                        }
                    }
                    .bringSelfToFront()
                    .setConstraints { $0.snapLeadBottomTrail(to: $1) }
                )
            default:
                view.subviews {
                    VStack {
                        [
                            UILabel("X: \(Int(view.frame.origin.x)) Y: \(Int(view.frame.origin.y))"),
                            UILabel("W: \(Int(view.frame.size.width)) H: \(Int(view.frame.size.height))")
                        ].map {
                            $0
                                .adjustsFontSizeToFitWidth()
                                .font(.boldSystemFont(ofSize: 16))
                                .textColor(.randomColor)
                        }
                    }
                    .bringSelfToFront()
                    .setConstraints { $0.snapLeadBottomTrail(to: $1) }
                }
            }
        }
    }
}
