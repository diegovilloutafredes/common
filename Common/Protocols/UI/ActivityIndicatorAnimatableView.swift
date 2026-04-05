//
//  ActivityIndicatorAnimatableView.swift
//

import UIKit

// MARK: - ActivityIndicatorAnimatableView
// MARK: - ActivityIndicatorAnimatableView
/// A protocol for views that can start and stop an activity indicator animation.
protocol ActivityIndicatorAnimatableView: UIView {
    
    /// Starts the activity indicator animation.
    func startAnimating()
    
    /// Stops the activity indicator animation.
    func stopAnimating()
}
