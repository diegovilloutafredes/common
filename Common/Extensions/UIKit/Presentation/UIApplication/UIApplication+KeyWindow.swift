//
//  UIApplication+KeyWindow.swift
//

import UIKit

// MARK: - KeyWindow
extension UIApplication {

    /// Returns the key window of the most active connected window scene.
    ///
    /// A foreground-active scene is preferred, then a foreground-inactive one — the state a scene is in during launch,
    /// permission prompts, Face ID and Control Center — then any other connected window scene. Among scenes in the same
    /// state, the app's current key window wins. Returns `nil` only when no connected window scene has a key window.
    public var keyWindow: UIWindow? {
        // UIApplication, not Self: `Self` reads the dynamic type of `self`, which crashes where `shared` is a nil
        // object (a process with no UIApplication instance, such as a hostless test bundle).
        UIApplication.preferredKeyWindow(
            among: connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .map { (activationState: $0.activationState, keyWindow: $0.keyWindow) }
        )
    }

    /// Picks the key window of the most active candidate scene: foreground-active, then foreground-inactive, then any
    /// other state; within a state, a window that is the app's key window first.
    static func preferredKeyWindow(
        among candidates: [(activationState: UIScene.ActivationState, keyWindow: UIWindow?)]
    ) -> UIWindow? {
        func rank(_ state: UIScene.ActivationState, _ window: UIWindow) -> Int {
            let stateRank = switch state {
            case .foregroundActive: 0
            case .foregroundInactive: 1
            default: 2
            }
            return stateRank * 2 + (window.isKeyWindow ? 0 : 1)
        }

        return candidates
            .compactMap { candidate in candidate.keyWindow.map { (rank: rank(candidate.activationState, $0), window: $0) } }
            .min { $0.rank < $1.rank }?
            .window
    }
}
