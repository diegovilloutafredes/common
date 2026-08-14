//
//  GradientViewTests.swift
//

import UIKit
import XCTest
@testable import Common

@MainActor
final class GradientViewTests: XCTestCase {

    private let dynamicColor = UIColor { traits in
        traits.userInterfaceStyle == .dark ? .white : .black
    }

    /// Trait changes propagate through the view hierarchy — a standalone view's
    /// traitCollection does not update from traitOverrides until it participates
    /// in one, so tests host the view in a window (no layout pass is run).
    private func hosted(_ view: GradientView) -> GradientView {
        let window = UIWindow(frame: .init(x: 0, y: 0, width: 100, height: 100))
        window.makeKeyAndVisible()
        window.addSubview(view)
        windows.append(window)
        return view
    }

    /// Flips the hosting window's appearance — propagates a trait change to the
    /// hosted view without running a layout pass on it.
    private func setAppearance(_ style: UIUserInterfaceStyle, for view: GradientView) {
        view.window?.overrideUserInterfaceStyle = style
    }

    private var windows: [UIWindow] = []

    override func tearDown() async throws {
        windows.forEach { $0.isHidden = true }
        windows = []
    }

    private func firstGradientColor(of view: GradientView) throws -> UIColor {
        let colors = try XCTUnwrap(view.gradientLayer.colors as? [Any])
        let first = try XCTUnwrap(colors.first)
        return UIColor(cgColor: first as! CGColor)
    }

    private func assertColorEqual(_ color: UIColor, _ expected: UIColor,
                                  _ message: String, file: StaticString = #filePath, line: UInt = #line) {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0
        color.getRed(&r1, green: &g1, blue: &b1, alpha: nil)
        expected.getRed(&r2, green: &g2, blue: &b2, alpha: nil)
        XCTAssertEqual(r1, r2, accuracy: 0.01, message, file: file, line: line)
        XCTAssertEqual(g1, g2, accuracy: 0.01, message, file: file, line: line)
        XCTAssertEqual(b1, b2, accuracy: 0.01, message, file: file, line: line)
    }

    // MARK: - Dynamic color re-resolution (G1)

    func test_darkModeFlip_reResolvesDynamicColors() throws {
        let view = hosted(GradientView()
            .colors(startColor: dynamicColor, endColor: dynamicColor))

        setAppearance(.dark, for: view)

        // Trait propagation from the window runs on the UIKit update cycle —
        // give it one pass. (No layout is run on the view itself.)
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        XCTAssertEqual(view.traitCollection.userInterfaceStyle, .dark,
                       "precondition: the trait must reach the view before the hook can be judged")

        let resolved = try firstGradientColor(of: view)
        assertColorEqual(resolved, .white,
                         "a dark/light flip must re-resolve dynamic colors without waiting for an incidental relayout")
    }

    func test_lightAppearance_resolvesLightVariant() throws {
        let view = hosted(GradientView()
            .colors(startColor: dynamicColor, endColor: dynamicColor))

        setAppearance(.light, for: view)

        let resolved = try firstGradientColor(of: view)
        assertColorEqual(resolved, .black, "light appearance must resolve the light variant")
    }

    func test_staticColors_unaffectedByTraitChange() throws {
        let view = hosted(GradientView()
            .colors(startColor: .red, endColor: .blue))

        setAppearance(.dark, for: view)

        let resolved = try firstGradientColor(of: view)
        assertColorEqual(resolved, .red, "static colors must render identically under any appearance")
    }
}
