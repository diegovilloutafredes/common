import UIKit

// MARK: - AppFontRegistry
private enum AppFontRegistry {
    nonisolated(unsafe) static var primaryFamily: AppFontFamily?
}

// MARK: - UIFont + AppFont
public extension UIFont {

    /// Registers the app's primary font family, used by `appFont(style:size:)`.
    /// Call once at app startup (e.g. in SceneDelegate). Pass `nil` to clear.
    static func setPrimaryFamily(_ family: AppFontFamily?) {
        AppFontRegistry.primaryFamily = family
    }

    /// Returns the app font for an explicit family, style, and size.
    /// PostScript name is derived as `"\(family)-\(style)"` (e.g. `"Montserrat-Bold"`).
    /// Falls back to the system font when the PostScript name cannot be resolved.
    static func appFont(_ family: AppFontFamily, style: FontStyle = .regular, size: CGFloat) -> UIFont {
        font(family, with: style, size: size)
    }

    /// Returns the app font for the registered primary family.
    /// Falls back to the system font when no primary family has been set.
    static func appFont(style: FontStyle = .regular, size: CGFloat) -> UIFont {
        guard let primary = AppFontRegistry.primaryFamily else {
            return systemFallback(for: style, size: size)
        }
        return appFont(primary, style: style, size: size)
    }

    /// Registers font files for the given `AppFontFamily` values.
    /// Convenience overload of `register(fonts:styles:type:on:)` — avoids explicit `[any Uppercaseable]` casting.
    static func register(
        fonts names: [AppFontFamily],
        styles: [FontStyle] = FontStyle.allCases,
        type: String = "ttf",
        on bundle: Bundle = .main
    ) {
        register(fonts: names as [any Uppercaseable], styles: styles, type: type, on: bundle)
    }
}
